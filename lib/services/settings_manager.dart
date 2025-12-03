import 'package:shared_preferences/shared_preferences.dart';

/// Manager untuk menyimpan dan mengambil pengaturan aplikasi
/// Terutama untuk konfigurasi URL server yang bisa diubah tanpa rebuild APK
class SettingsManager {
  // Keys untuk SharedPreferences
  static const String _baseUrlKey = 'base_url';
  static const String _fallbackUrlKey = 'fallback_url';
  
  /// Get Base URL (primary server)
  /// Returns null if not set - user MUST configure this
  static Future<String?> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey);
  }
  
  /// Get Fallback URL (secondary server)
  /// Returns null if not set - user MUST configure this
  static Future<String?> getFallbackUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fallbackUrlKey);
  }
  
  /// Check if URLs are configured
  static Future<bool> isConfigured() async {
    final baseUrl = await getBaseUrl();
    final fallbackUrl = await getFallbackUrl();
    return baseUrl != null && fallbackUrl != null;
  }
  
  /// Set Base URL with auto-correction
  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedUrl = normalizeUrl(url);
    await prefs.setString(_baseUrlKey, normalizedUrl);
  }
  
  /// Set Fallback URL with auto-correction
  static Future<void> setFallbackUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedUrl = normalizeUrl(url);
    await prefs.setString(_fallbackUrlKey, normalizedUrl);
  }
  
  /// Clear all settings
  static Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
    await prefs.remove(_fallbackUrlKey);
  }
  
  /// Normalize URL - auto-add https:// and trailing /
  static String normalizeUrl(String url) {
    String normalized = url.trim();
    
    // Auto-add https:// if no scheme
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    
    // Auto-add trailing /
    if (!normalized.endsWith('/')) {
      normalized += '/';
    }
    
    return normalized;
  }
  
  /// Validate URL format with detailed error message
  static String? validateUrl(String url) {
    if (url.isEmpty) {
      return 'URL tidak boleh kosong';
    }
    
    String normalized = normalizeUrl(url);
    
    try {
      final uri = Uri.parse(normalized);
      
      // Check if has valid scheme
      if (!uri.hasScheme) {
        return 'URL harus memiliki protokol (http:// atau https://)';
      }
      
      // Check if scheme is http or https
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return 'Protokol harus http:// atau https://';
      }
      
      // Check if has host/domain
      if (uri.host.isEmpty) {
        return 'URL harus memiliki domain (contoh: domainanda.com)';
      }
      
      // Check if domain is valid (has at least one dot or is localhost)
      if (!uri.host.contains('.') && uri.host != 'localhost') {
        return 'Domain tidak valid (contoh: domainanda.com)';
      }
      
      return null; // Valid
    } catch (e) {
      return 'Format URL tidak valid';
    }
  }
  
  /// Get all settings as Map (untuk debugging)
  static Future<Map<String, String?>> getAllSettings() async {
    return {
      'baseUrl': await getBaseUrl(),
      'fallbackUrl': await getFallbackUrl(),
    };
  }
}
