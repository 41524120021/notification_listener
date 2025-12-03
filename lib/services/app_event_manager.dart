import 'dart:async';

/// Event manager untuk komunikasi antara services dan UI
class AppEventManager {
  // Singleton pattern
  static final AppEventManager _instance = AppEventManager._internal();
  factory AppEventManager() => _instance;
  AppEventManager._internal();

  // Stream controller untuk donation event
  final _donationEventController = StreamController<bool>.broadcast();
  
  /// Stream untuk listen donation events
  Stream<bool> get donationEventStream => _donationEventController.stream;

  /// Trigger donation event
  void triggerDonationEvent() {
    print('🎁 Triggering donation event');
    _donationEventController.add(true);
  }

  /// Dispose
  void dispose() {
    _donationEventController.close();
  }
}
