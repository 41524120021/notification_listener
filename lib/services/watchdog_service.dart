import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';

/// WatchdogService - Keeps notification listener running
/// Equivalent to WatchdogService.bas from B4A
class WatchdogService {
  static Timer? _watchdogTimer;
  static bool _isRunning = false;

  /// Start watchdog to periodically check notification listener status
  static void start() {
    if (_isRunning) {
      debugPrint('WatchdogService already running');
      return;
    }

    debugPrint('WatchdogService: Starting watchdog');
    _isRunning = true;

    // Check every 30 seconds
    _watchdogTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNotificationListener();
    });

    // Initial check
    _checkNotificationListener();
  }

  /// Stop watchdog timer
  static void stop() {
    debugPrint('WatchdogService: Stopping watchdog');
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _isRunning = false;
  }

  /// Check if notification listener is active
  static void _checkNotificationListener() {
    debugPrint('WatchdogService: Checking notification listener status');
    
    // In B4A, WatchdogService calls StartService(NotificationService)
    // In Flutter, we ensure the listener is initialized
    if (!NotificationService.isListening) {
      debugPrint('WatchdogService: Notification listener not active, restarting...');
      NotificationService.startListening();
    } else {
      debugPrint('WatchdogService: Notification listener is active');
    }
  }

  /// Check if watchdog is running
  static bool get isRunning => _isRunning;
}
