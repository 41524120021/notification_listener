import 'dart:async';
import 'dart:collection';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';
import '../services/rules_manager.dart';
import '../services/transaction_service.dart';
import '../services/app_event_manager.dart';
import '../utils/text_extractor.dart';

class NotificationService {
  static StreamSubscription? _subscription;
  static bool _isListening = false;
  
  // Queue untuk memastikan notifikasi diproses satu per satu
  static final Queue<NotificationEvent> _notificationQueue = Queue<NotificationEvent>();
  static bool _isProcessing = false;

  // StreamController untuk broadcast event saat transaksi berhasil dipost
  // Event ini akan di-listen oleh UI untuk auto-refresh
  static final StreamController<String> _transactionPostedController = 
      StreamController<String>.broadcast();
  
  // Stream untuk listen event transaksi berhasil dipost
  static Stream<String> get onTransactionPosted => _transactionPostedController.stream;

  // DUPLICATE PREVENTION: Track processed notifications by UID and content hash
  // Ini mencegah notifikasi yang sama diproses berkali-kali
  static final Set<String> _processedNotificationIds = {};
  static const int _maxProcessedIds = 1000; // Limit untuk mencegah memory leak

  static bool get isListening => _isListening;

  static Future<void> initialize() async {
    // Initialize the plugin first (PENTING untuk MethodChannel)
    await NotificationsListener.initialize();
    
    // Check if we have permission
    final hasPermission = await checkPermission();
    if (hasPermission) {
      await startListening();
    }
  }

  static Future<bool> checkPermission() async {
    try {
      final status = await NotificationsListener.isRunning ?? false;
      return status;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      await NotificationsListener.openPermissionSettings();
      // Give user time to enable permission, then check
      await Future.delayed(const Duration(seconds: 1));
      final hasPermission = await checkPermission();
      if (hasPermission) {
        await startListening();
      }
      return hasPermission;
    } catch (e) {
      return false;
    }
  }

  static Future<void> startListening() async {
    if (_subscription != null) {
      return; // Already listening
    }

    // Start the notification listener service
    final started = await NotificationsListener.startService(
      foreground: true,
      title: 'NotifListener Service',
      description: 'Mendengarkan notifikasi untuk transaksi',
      showWhen: false,
    ) ?? false; // Handle nullable bool

    if (!started) {
      print('❌ Failed to start NotificationsListener service');
      return;
    }

    print('✅ NotificationsListener service started in foreground');

    _isListening = true;
    _subscription = NotificationsListener.receivePort?.listen(
      (dynamic data) {
        try {
          // Data dari plugin sekarang adalah Map, bukan NotificationEvent
          print("📥 RAW DATA RECEIVED: $data"); // Debug print
          
          NotificationEvent event;
          if (data is Map) {
            // Deserialize Map to NotificationEvent
            event = NotificationEvent.fromMap(data);
            print("✅ Converted Map to NotificationEvent: ${event.title}");
          } else if (data is NotificationEvent) {
            // Fallback jika sudah NotificationEvent
            event = data;
            print("✅ Already NotificationEvent: ${event.title}");
          } else {
            print("❌ Unknown data type: ${data.runtimeType}");
            return;
          }
          
          // Tambahkan ke queue dan proses
          _notificationQueue.add(event);
          _processQueue();
        } catch (e, stack) {
          print("❌ Error processing notification data: $e");
          print("Stack: $stack");
        }
      },
      onError: (error) {
        print('❌ Error in notification stream: $error');
        // Auto-restart jika stream error
        _isListening = false;
        _subscription?.cancel();
        _subscription = null;
        Future.delayed(const Duration(seconds: 5), () {
          print('🔄 Auto-restarting notification listener after stream error...');
          startListening();
        });
      },
      cancelOnError: false, // Jangan cancel stream saat error
    );
  }

  static Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  /// Process notification queue satu per satu
  static Future<void> _processQueue() async {
    if (_isProcessing) {
      // Sudah ada yang sedang diproses, tunggu giliran
      return;
    }

    _isProcessing = true;

    while (_notificationQueue.isNotEmpty) {
      final event = _notificationQueue.removeFirst();
      await _handleNotification(event);
    }

    _isProcessing = false;
  }

  /// Generate unique ID untuk notifikasi berdasarkan konten
  /// Kombinasi: packageName + amount + timestamp (rounded to minute)
  static String _generateNotificationId(String packageName, String text, String? uid) {
    // Gunakan UID jika ada
    if (uid != null && uid.isNotEmpty) {
      return uid;
    }
    
    // Fallback: hash dari package + text (first 200 chars untuk performa)
    final textSnippet = text.length > 200 ? text.substring(0, 200) : text;
    final combined = '$packageName|$textSnippet';
    return combined.hashCode.toString();
  }

  /// Cek apakah notifikasi sudah pernah diproses
  static bool _isAlreadyProcessed(String notificationId) {
    return _processedNotificationIds.contains(notificationId);
  }

  /// Tandai notifikasi sebagai sudah diproses
  static void _markAsProcessed(String notificationId) {
    _processedNotificationIds.add(notificationId);
    
    // Cleanup jika sudah terlalu banyak (FIFO - hapus yang paling lama)
    if (_processedNotificationIds.length > _maxProcessedIds) {
      final toRemove = _processedNotificationIds.take(100).toList();
      _processedNotificationIds.removeAll(toRemove);
      print('🧹 Cleaned up ${toRemove.length} old processed notification IDs');
    }
  }

  static Future<void> _handleNotification(NotificationEvent event) async {
    try {
      // Get notification details
      final packageName = event.packageName ?? '';
      final title = event.title ?? '';
      final text = event.text ?? '';
      final uid = event.uniqueId ?? '';

      // DEBUG: Log semua notifikasi yang masuk
      print('\n=== NOTIFICATION RECEIVED ===');
      print('Package: $packageName');
      print('Title: $title');
      print('Text: $text');
      print('UID: $uid');

      // DUPLICATE CHECK: Cek apakah notifikasi ini sudah pernah diproses
      final notificationId = _generateNotificationId(packageName, text, uid);
      if (_isAlreadyProcessed(notificationId)) {
        print('⚠️ DUPLICATE DETECTED! Notification already processed: $notificationId');
        print('=== SKIPPING DUPLICATE NOTIFICATION ===\n');
        return;
      }

      // Tandai sebagai sedang diproses (mark early untuk mencegah race condition)
      _markAsProcessed(notificationId);
      print('✅ Notification marked as processed: $notificationId');

      // Match dengan rules yang ada
      final matchedRule = await RulesManager.matchNotification(
        packageName,
        title,
        text,
      );

      if (matchedRule == null) {
        // Tidak match dengan rule manapun, skip
        print('❌ No matching rule found for this notification');
        print('=== END NOTIFICATION HANDLING ===\n');
        return;
      }

      print('✅ Matched Rule: ${matchedRule.bankName}');
      print('Extract Method: ${matchedRule.extractMethod}');

      // Extract amount menggunakan method yang sesuai
      final extractedAmount = TextExtractor.extract(
        text,
        matchedRule.extractMethod,
      );

      print('Extracted Amount: $extractedAmount');

      // Simpan ke database dengan status belum terkirim
      final transaction = Transaction(
        bankName: matchedRule.bankName,
        detail: text,
        amount: extractedAmount,
        timestamp: DateTime.now(),
        isSynced: false, // Belum terkirim
        retryCount: 0,
      );

      final transactionId = await DatabaseHelper.instance.insertTransaction(transaction);
      print('💾 Transaction saved to database (ID: $transactionId, isSynced: false)');
      
      // Post ke server (seperti B4A) - HANYA jika ada amount valid
      if (extractedAmount != null && extractedAmount.isNotEmpty) {
        final amountInt = TextExtractor.parseAmount(extractedAmount)?.toInt() ?? 0;
        
        if (amountInt > 0) {
          print('📤 Posting to 3 servers: Rp $amountInt');
          
          // Post ke 3 server secara sequential
          final result = await TransactionService.postTransaction(
            amount: amountInt,
            text: text,
            packageName: packageName,
          );
          
          final allSuccess = result['success'] as bool;
          final shouldShowDonation = result['shouldShowDonation'] as bool;
          
          if (allSuccess) {
            // Update status: berhasil terkirim
            await DatabaseHelper.instance.updateTransactionSyncStatus(
              id: transactionId,
              isSynced: true,
            );
            print('✅ Transaction synced successfully (isSynced: true)');
            
            // Clear notification setelah post sukses (seperti B4A: listener.ClearNotification)
            if (uid.isNotEmpty) {
              try {
                await NotificationsListener.cancelNotification(uid);
                print('🗑️ Notification cleared: $uid');
              } catch (e) {
                // MissingPluginException bisa terjadi saat app di-minimize
                // Ini tidak critical karena transaksi sudah sukses dipost
                if (e.toString().contains('MissingPluginException')) {
                  print('⚠️ Cannot clear notification (app minimized): $uid');
                  // Notification akan tetap di status bar, tidak masalah
                } else {
                  print('❌ Error clearing notification: $e');
                }
              }
            }
            
            // Cek pending di 3 server setelah posting sukses (seperti B4A)
            // Ini untuk trigger proses pending di server sebelum refresh UI
            print('🔍 Running cekPending after successful post...');
            await TransactionService.cekPending();
            
            // Broadcast event: transaksi berhasil dipost
            // UI akan listen event ini untuk auto-refresh
            _transactionPostedController.add('transaction_posted');
            print('📢 Event broadcasted: transaction_posted');
            
            // Trigger donation event if needed
            if (shouldShowDonation) {
              AppEventManager().triggerDonationEvent();
            }
          } else {
            // Gagal post, increment retry count
            await DatabaseHelper.instance.updateTransactionSyncStatus(
              id: transactionId,
              isSynced: false,
              retryCount: 1,
            );
            print('⚠️ Failed to post to servers (retryCount: 1)');
          }
        } else {
          print('⚠️ Amount is 0 or invalid, skipping server post');
        }
      } else {
        print('⚠️ No amount extracted, skipping server post');
      }
      
      print('=== END NOTIFICATION HANDLING ===\n');
    } catch (e, stackTrace) {
      print('❌ Error handling notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Retry sending unsynced transactions
  static Future<Map<String, int>> retryUnsyncedTransactions() async {
    int processedCount = 0;
    int successCount = 0;
    int failedCount = 0;

    try {
      print('\n=== RETRY UNSYNCED TRANSACTIONS STARTED ===');
      
      // Get transaksi yang belum terkirim
      final unsyncedTransactions = await DatabaseHelper.instance.getUnsyncedTransactions();
      print('Total unsynced transactions: ${unsyncedTransactions.length}');
      
      if (unsyncedTransactions.isEmpty) {
        return {
          'processed': 0,
          'success': 0,
          'failed': 0,
        };
      }
      
      // Load current rules
      final rules = await RulesManager.loadRules();
      
      // Process each unsynced transaction
      for (var transaction in unsyncedTransactions) {
        print('\n--- Retrying Transaction ID: ${transaction.id} ---');
        print('Bank: ${transaction.bankName}');
        print('Amount: ${transaction.amount}');
        print('Retry Count: ${transaction.retryCount}');
        
        // Find matching rule
        var matchedRule = rules.cast<dynamic>().firstWhere(
          (rule) => rule.bankName.toLowerCase() == transaction.bankName.toLowerCase(),
          orElse: () => null,
        );
        
        if (matchedRule == null) {
          print('❌ No matching rule for ${transaction.bankName}');
          failedCount++;
          continue;
        }
        
        // Post to server
        if (transaction.amount != null && transaction.amount!.isNotEmpty) {
          final amountInt = TextExtractor.parseAmount(transaction.amount)?.toInt() ?? 0;
          
          if (amountInt > 0) {
            print('📤 Retrying post to 3 servers: Rp $amountInt');
            
            final result = await TransactionService.postTransaction(
              amount: amountInt,
              text: transaction.detail,
              packageName: matchedRule.packageName,
            );
            
            final success = result['success'] as bool;
            final shouldShowDonation = result['shouldShowDonation'] as bool;
            
            if (success) {
              // Update status: berhasil terkirim
              await DatabaseHelper.instance.updateTransactionSyncStatus(
                id: transaction.id!,
                isSynced: true,
              );
              successCount++;
              print('✅ Retry successful (isSynced: true)');
              
              // Cek pending setelah retry sukses
              print('🔍 Running cekPending after retry success...');
              await TransactionService.cekPending();
              
              // Broadcast event untuk auto-refresh UI
              _transactionPostedController.add('transaction_posted');
              print('📢 Event broadcasted: transaction_posted (retry)');
              
              // Trigger donation event if needed
              if (shouldShowDonation) {
                AppEventManager().triggerDonationEvent();
              }
            } else {
              // Gagal lagi, increment retry count
              await DatabaseHelper.instance.updateTransactionSyncStatus(
                id: transaction.id!,
                isSynced: false,
                retryCount: transaction.retryCount + 1,
              );
              failedCount++;
              print('⚠️ Retry failed (retryCount: ${transaction.retryCount + 1})');
            }
            
            processedCount++;
          }
        }
        
        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      print('\n=== RETRY UNSYNCED TRANSACTIONS COMPLETED ===');
      print('Processed: $processedCount');
      print('Success: $successCount');
      print('Failed: $failedCount');
      
      return {
        'processed': processedCount,
        'success': successCount,
        'failed': failedCount,
      };
    } catch (e, stackTrace) {
      print('❌ Error in retryUnsyncedTransactions: $e');
      print('Stack trace: $stackTrace');
      
      return {
        'processed': processedCount,
        'success': successCount,
        'failed': failedCount,
      };
    }
  }

  /// Get active notifications from status bar and process them
  /// This reads notifications that are still in the status bar (not cleared yet)
  static Future<Map<String, int>> getActiveNotifications() async {
    int processedCount = 0;
    int successCount = 0;
    int skippedCount = 0;

    try {
      print('\n=== GET ACTIVE NOTIFICATIONS STARTED ===');
      
      // Check if service is running
      final isRunning = await NotificationsListener.isRunning ?? false;
      print('Service running status: $isRunning');
      
      if (!isRunning) {
        print('⚠️ Service is not running! Trying to start...');
        await startListening();
        // Wait a bit for service to start
        await Future.delayed(const Duration(seconds: 1));
      }
      
      // Get active notifications from status bar using our custom method
      print('Calling NotificationsListener.getActiveNotifications()...');
      List<NotificationEvent>? activeNotifications;
      
      try {
        activeNotifications = await NotificationsListener.getActiveNotifications();
        print('✅ getActiveNotifications() returned: ${activeNotifications?.length ?? 0} notifications');
      } catch (e) {
        print('❌ Error calling getActiveNotifications(): $e');
        
        // Jika error MissingPluginException, coba re-initialize plugin untuk update engine reference
        if (e.toString().contains('MissingPluginException')) {
          print('⚠️ MissingPluginException detected. Re-initializing plugin to update engine reference...');
          
          try {
            await NotificationsListener.initialize();
            await Future.delayed(const Duration(milliseconds: 500));
            
            // Retry
            print('Retrying NotificationsListener.getActiveNotifications()...');
            activeNotifications = await NotificationsListener.getActiveNotifications();
            print('✅ Retry successful: ${activeNotifications?.length ?? 0} notifications');
          } catch (retryError) {
            print('❌ Retry also failed: $retryError');
            // Return empty jika retry juga gagal
            activeNotifications = [];
          }
        } else {
          // Error lain, set empty
          activeNotifications = [];
        }
      }
      
      print('Total active notifications in status bar: ${activeNotifications?.length ?? 0}');
      
      if (activeNotifications == null || activeNotifications.isEmpty) {
        print('No active notifications found');
        return {
          'processed': 0,
          'success': 0,
          'skipped': 0,
        };
      }
      
      // Load current rules
      final rules = await RulesManager.loadRules();
      print('Total rules loaded: ${rules.length}');
      
      // Process each active notification
      for (var event in activeNotifications) {
        final packageName = event.packageName ?? '';
        final title = event.title ?? '';
        final text = event.text ?? '';
        final uid = event.uniqueId ?? '';
        
        print('\n--- Processing Active Notification ---');
        print('Package: $packageName');
        print('Title: $title');
        print('Text: ${text.length > 100 ? text.substring(0, 100) + "..." : text}');
        print('UID: $uid');
        
        // DUPLICATE CHECK: Skip jika sudah pernah diproses
        final notificationId = _generateNotificationId(packageName, text, uid);
        if (_isAlreadyProcessed(notificationId)) {
          print('⚠️ DUPLICATE DETECTED! Already processed: $notificationId');
          print('Skipping this active notification');
          skippedCount++;
          continue;
        }
        
        // Tandai sebagai sedang diproses
        _markAsProcessed(notificationId);
        print('✅ Notification marked as processed: $notificationId');
        
        // Match dengan rules yang ada
        final matchedRule = await RulesManager.matchNotification(
          packageName,
          title,
          text,
        );
        
        if (matchedRule == null) {
          print('❌ No matching rule found');
          skippedCount++;
          continue;
        }
        
        print('✅ Matched Rule: ${matchedRule.bankName}');
        print('Extract Method: ${matchedRule.extractMethod}');
        
        // Extract amount
        final extractedAmount = TextExtractor.extract(
          text,
          matchedRule.extractMethod,
        );
        
        print('Extracted Amount: $extractedAmount');
        
        if (extractedAmount == null || extractedAmount.isEmpty) {
          print('⚠️ No amount extracted, skipping');
          skippedCount++;
          continue;
        }
        
        final amountInt = TextExtractor.parseAmount(extractedAmount)?.toInt() ?? 0;
        
        if (amountInt <= 0) {
          print('⚠️ Amount is 0 or invalid, skipping');
          skippedCount++;
          continue;
        }
        
        // Save to database first with isSynced=false
        final transaction = Transaction(
          bankName: matchedRule.bankName,
          detail: text,
          amount: extractedAmount,
          timestamp: DateTime.now(),
          isSynced: false,
          retryCount: 0,
        );
        
        final transactionId = await DatabaseHelper.instance.insertTransaction(transaction);
        print('💾 Transaction saved to database (ID: $transactionId)');
        
        // Post to server
        print('📤 Posting to 3 servers: Rp $amountInt');
        final result = await TransactionService.postTransaction(
          amount: amountInt,
          text: text,
          packageName: packageName,
        );
        
        final success = result['success'] as bool;
        final shouldShowDonation = result['shouldShowDonation'] as bool;
        
        if (success) {
          // Update status: berhasil terkirim
          await DatabaseHelper.instance.updateTransactionSyncStatus(
            id: transactionId,
            isSynced: true,
          );
          successCount++;
          print('✅ Posted successfully to servers (isSynced: true)');
          
          // Clear notification after successful post
          if (uid.isNotEmpty) {
            try {
              await NotificationsListener.cancelNotification(uid);
              print('🗑️ Notification cleared: $uid');
            } catch (e) {
              // MissingPluginException bisa terjadi saat app di-minimize
              // Ini tidak critical karena transaksi sudah sukses dipost
              if (e.toString().contains('MissingPluginException')) {
                print('⚠️ Cannot clear notification (app minimized): $uid');
                // Notification akan tetap di status bar, tidak masalah
              } else {
                print('❌ Error clearing notification: $e');
              }
            }
          }
          
          // Cek pending setelah post active notification sukses
          print('🔍 Running cekPending after active notification post...');
          await TransactionService.cekPending();
          
          // Broadcast event untuk auto-refresh UI
          _transactionPostedController.add('transaction_posted');
          print('📢 Event broadcasted: transaction_posted (active notification)');
          
          // Trigger donation event if needed
          if (shouldShowDonation) {
            AppEventManager().triggerDonationEvent();
          }
        } else {
          // Gagal post, increment retry count
          await DatabaseHelper.instance.updateTransactionSyncStatus(
            id: transactionId,
            isSynced: false,
            retryCount: 1,
          );
          print('⚠️ Failed to post to servers (retryCount: 1)');
        }
        
        processedCount++;
        
        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      print('\n=== GET ACTIVE NOTIFICATIONS COMPLETED ===');
      print('Processed: $processedCount');
      print('Success: $successCount');
      print('Skipped: $skippedCount');
      
      return {
        'processed': processedCount,
        'success': successCount,
        'skipped': skippedCount,
      };
    } catch (e, stackTrace) {
      print('❌ Error in getActiveNotifications: $e');
      print('Stack trace: $stackTrace');
      
      return {
        'processed': processedCount,
        'success': successCount,
        'skipped': skippedCount,
      };
    }
  }
}
