import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;
import 'notification_service.dart';
import 'watchdog_service.dart';
import 'transaction_service.dart';

/// Foreground Task Handler - Menjaga aplikasi tetap berjalan di background
/// Equivalent dengan NotificationService + WatchdogService di B4A
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(NotifListenerTaskHandler());
}

class NotifListenerTaskHandler extends TaskHandler {
  Timer? _watchdogTimer;
  Timer? _refreshTimer;
  Timer? _retryTimer;
  int _runCount = 0;
  int _refreshCounter = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('🚀 Foreground Task Started at $timestamp');
    
    // Initialize NotificationService
    await NotificationService.initialize();
    print('✅ NotificationService initialized');
    
    // Start watchdog timer (check every 30 seconds)
    _watchdogTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNotificationListener();
    });
    print('✅ Watchdog timer started');
    
    // Start refresh timer (every 2 minutes) - BERJALAN DI BACKGROUND!
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      _refreshCounter++;
      
      // Tiap 2 menit: ambil transaksi & QRIS
      if (_refreshCounter % 2 == 0) {
        print('🔄 [Background] RefreshTimer: Ambil transaksi & QRIS');
        await _getTransaksiData();
        await _getTrxQris();
      }
      
      // Tiap 6 menit: cek pending (counter % 3 karena timer 2 menit)
      if (_refreshCounter % 3 == 0) {
        print('🔄 [Background] RefreshTimer: Cek pending');
        await _cekPending();
      }
      
      // Reset counter
      if (_refreshCounter > 10000) _refreshCounter = 0;
    });
    print('✅ Refresh timer started (2 minutes interval)');
    
    // Start retry timer (every 10 minutes) - RETRY TRANSAKSI GAGAL
    _retryTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      print('🔄 [Background] RetryTimer: Checking for unsynced transactions...');
      try {
        final result = await NotificationService.retryUnsyncedTransactions();
        final processed = result['processed'] ?? 0;
        final success = result['success'] ?? 0;
        final failed = result['failed'] ?? 0;
        
        if (processed > 0) {
          print('✅ [Background] Retry completed: $success succeeded, $failed failed');
        } else {
          print('ℹ️ [Background] No unsynced transactions to retry');
        }
      } catch (e) {
        print('❌ [Background] Error in retry timer: $e');
      }
    });
    print('✅ Retry timer started (10 minutes interval)');
    
    // Load data awal
    await _getTransaksiData();
    await _getTrxQris();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Dipanggil setiap interval (default 5 detik)
    _runCount++;
    
    // Update notification setiap 1 menit (12 x 5 detik)
    if (_runCount % 12 == 0) {
      final minutes = _runCount ~/ 12;
      FlutterForegroundTask.updateService(
        notificationTitle: 'NotifListener Aktif',
        notificationText: 'Mendengarkan notifikasi... ($minutes menit)',
      );
    }
    
    // Log setiap 5 menit untuk monitoring
    if (_runCount % 60 == 0) {
      print('⏰ Foreground service running: ${_runCount ~/ 60} x 5 menit');
      print('   Listener active: ${NotificationService.isListening}');
      print('   Refresh counter: $_refreshCounter');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('🛑 Foreground Task Stopped at $timestamp');
    
    // Cancel all timers
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    
    _refreshTimer?.cancel();
    _refreshTimer = null;
    
    _retryTimer?.cancel();
    _retryTimer = null;
    
    // Stop notification service
    await NotificationService.stopListening();
  }

  /// Check if notification listener is still active
  void _checkNotificationListener() {
    if (!NotificationService.isListening) {
      print('⚠️ Notification listener not active, restarting...');
      NotificationService.startListening();
    } else {
      print('✅ Notification listener is active');
    }
  }

  /// Get transaksi data from server (Background)
  Future<void> _getTransaksiData() async {
    try {
      await TransactionService.getTransaksiFromServer();
      print('✅ [Background] Transaksi data refreshed');
    } catch (e) {
      print('❌ [Background] Error getting transaksi: $e');
    }
  }

  /// Get QRIS data from server (Background)
  Future<void> _getTrxQris() async {
    try {
      await TransactionService.getQrisFromServer();
      print('✅ [Background] QRIS data refreshed');
    } catch (e) {
      print('❌ [Background] Error getting QRIS: $e');
    }
  }

  /// Cek pending di server (Background)
  Future<void> _cekPending() async {
    try {
      // Use TransactionService.cekPending() yang sudah pakai dynamic URLs
      final result = await TransactionService.cekPending();
      final successCount = result['success'] ?? 0;
      print('✅ [Background] Cek pending selesai: $successCount berhasil');
    } catch (e) {
      print('❌ [Background] Error cek pending: $e');
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button press if needed
    print('Notification button pressed: $id');
  }

  @override
  void onNotificationPressed() {
    // Handle notification press - open app
    FlutterForegroundTask.launchApp('/');
    print('Notification pressed, launching app');
  }
}
