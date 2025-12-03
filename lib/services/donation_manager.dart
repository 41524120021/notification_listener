import 'package:shared_preferences/shared_preferences.dart';

/// Manager untuk tracking donation counter
class DonationManager {
  static const String _keySuccessCount = 'donation_success_count';
  static const String _keyLastShownAt = 'donation_last_shown_at';
  static const int _showEvery = 500; // Show every 500 successful transactions

  /// Increment success counter dan return true jika perlu show donation dialog
  static Future<bool> incrementAndCheckShowDonation() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get current count
    int currentCount = prefs.getInt(_keySuccessCount) ?? 0;
    
    // Increment
    currentCount++;
    await prefs.setInt(_keySuccessCount, currentCount);
    
    print('📊 Donation counter: $currentCount');
    
    // Check if we should show donation dialog
    if (currentCount % _showEvery == 0) {
      // Check if we haven't shown it recently (within last hour)
      final lastShown = prefs.getInt(_keyLastShownAt) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneHour = 60 * 60 * 1000;
      
      if (now - lastShown > oneHour) {
        // Update last shown time
        await prefs.setInt(_keyLastShownAt, now);
        print('🎉 Showing donation dialog at $currentCount transactions!');
        return true;
      }
    }
    
    return false;
  }

  /// Get current success count
  static Future<int> getSuccessCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySuccessCount) ?? 0;
  }

  /// Reset counter (for testing)
  static Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySuccessCount);
    await prefs.remove(_keyLastShownAt);
  }

  /// Get next milestone
  static Future<int> getNextMilestone() async {
    final count = await getSuccessCount();
    return ((count ~/ _showEvery) + 1) * _showEvery;
  }
}
