import 'dart:async';
import 'package:flutter/material.dart';
import 'transaction_service.dart';
import 'database_helper.dart';

/// PollingService - Periodically fetch data from server
/// Equivalent to PollingServer timer in B4A (60 seconds interval)
class PollingService {
  static Timer? _pollingTimer;
  static bool _isRunning = false;
  static DateTime? _lastPoll;

  /// Start polling server every 60 seconds
  static void start() {
    if (_isRunning) {
      debugPrint('PollingService already running');
      return;
    }

    debugPrint('PollingService: Starting server polling (60s interval)');
    _isRunning = true;

    // Poll every 60 seconds like B4A
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _pollServer();
    });

    // Initial poll
    _pollServer();
  }

  /// Stop polling timer
  static void stop() {
    debugPrint('PollingService: Stopping server polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isRunning = false;
  }

  /// Poll server for transactions
  static Future<void> _pollServer() async {
    _lastPoll = DateTime.now();
    debugPrint('PollingService: Polling server for new data');

    try {
      // Get Transaksi data (equivalent to GetTransaksi job in B4A)
      final transaksiList = await TransactionService.getTransaksiFromServer();
      if (transaksiList.isNotEmpty) {
        debugPrint('PollingService: Received ${transaksiList.length} transactions');
        for (var transaction in transaksiList) {
          await DatabaseHelper.instance.insertOrUpdateTransaction(transaction);
        }
      }

      // Get QRIS data (equivalent to GetQris job in B4A)
      final qrisList = await TransactionService.getQrisFromServer();
      if (qrisList.isNotEmpty) {
        debugPrint('PollingService: Received ${qrisList.length} QRIS transactions');
        for (var transaction in qrisList) {
          await DatabaseHelper.instance.insertOrUpdateTransaction(transaction);
        }
      }

      debugPrint('PollingService: Poll completed successfully');
    } catch (e) {
      debugPrint('PollingService: Error polling server: $e');
    }
  }

  /// Manual trigger poll
  static Future<void> pollNow() async {
    if (_isRunning) {
      await _pollServer();
    } else {
      debugPrint('PollingService: Not running, cannot poll');
    }
  }

  /// Check if polling is running
  static bool get isRunning => _isRunning;

  /// Get last poll time
  static DateTime? get lastPollTime => _lastPoll;
}
