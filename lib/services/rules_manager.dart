import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/bank_rule.dart';
import 'settings_manager.dart';

class RulesManager {
  static const String _rulesKey = 'bank_rules';

  static Future<void> saveRules(List<BankRule> rules) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = rules.map((rule) => rule.toJson()).toList();
    await prefs.setString(_rulesKey, jsonEncode(jsonList));
  }

  static Future<List<BankRule>> loadRules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_rulesKey);

    if (jsonString == null) {
      // Jika belum ada, WAJIB load dari server (seperti B4A LoadRemoteRules)
      final serverRules = await loadRemoteRules();
      if (serverRules != null && serverRules.isNotEmpty) {
        await saveRules(serverRules);
        return serverRules;
      }
      
      // Jika server gagal, return empty (tidak pakai default hardcode)
      print('Gagal load rules dari server, return empty list');
      return [];
    }

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => BankRule.fromJson(json)).toList();
  }

  // Load rules dari server dengan fallback
  static Future<List<BankRule>?> loadRemoteRules() async {
    try {
      // Get URLs from settings
      final baseUrl = await SettingsManager.getBaseUrl();
      final fallbackUrl = await SettingsManager.getFallbackUrl();
      
      // Check if URLs are configured
      if (baseUrl == null || fallbackUrl == null) {
        print('❌ URLs not configured yet. Please configure in Settings.');
        return null;
      }
      
      // Try primary server first
      final response = await http.get(
        Uri.parse('${baseUrl}api/notif_api/get_rules'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final jsonList = jsonDecode(response.body) as List;
        if (jsonList.isNotEmpty) {
          return _parseServerRules(jsonList);
        }
      }

      // Fallback to secondary server
      final fallbackResponse = await http.get(
        Uri.parse('${fallbackUrl}api/notif_api/get_rules'),
      ).timeout(const Duration(seconds: 10));

      if (fallbackResponse.statusCode == 200 && fallbackResponse.body.isNotEmpty) {
        final jsonList = jsonDecode(fallbackResponse.body) as List;
        return _parseServerRules(jsonList);
      }

      return null;
    } catch (e) {
      print('Error loading remote rules: $e');
      return null;
    }
  }

  // Parse rules dari format server ke BankRule (sesuai format B4A: bank, norek, packagename, title, trigger, parsemethod)
  static List<BankRule> _parseServerRules(List jsonList) {
    return jsonList.map((json) {
      return BankRule(
        bankName: json['bank'] ?? '',
        accountNumber: json['norek'] ?? '',
        packageName: json['packagename'] ?? '',
        title: json['title'] ?? '',
        detail: json['trigger'] ?? '',
        extractMethod: json['parsemethod'] ?? 'ExtractWithRp',
        isActive: json['isActive'] ?? true,
      );
    }).toList();
  }

  static Future<void> addRule(BankRule rule) async {
    final rules = await loadRules();
    rules.add(rule);
    await saveRules(rules);
  }

  static Future<void> updateRule(int index, BankRule rule) async {
    final rules = await loadRules();
    if (index >= 0 && index < rules.length) {
      rules[index] = rule;
      await saveRules(rules);
    }
  }

  static Future<void> deleteRule(int index) async {
    final rules = await loadRules();
    if (index >= 0 && index < rules.length) {
      rules.removeAt(index);
      await saveRules(rules);
    }
  }

  static Future<BankRule?> matchNotification(String packageName, String title, String detail) async {
    final rules = await loadRules();
    
    print('🔍 Matching notification against ${rules.length} rules');
    print('Looking for package: $packageName');
    
    for (var i = 0; i < rules.length; i++) {
      final rule = rules[i];
      print('\n--- Checking Rule #$i ---');
      print('Rule Bank: ${rule.bankName}');
      print('Rule Package: ${rule.packageName}');
      print('Rule Title: ${rule.title}');
      print('Rule Detail: ${rule.detail}');
      print('Rule Active: ${rule.isActive}');
      
      if (!rule.isActive) {
        print('❌ Rule is inactive, skipping');
        continue;
      }
      
      // Match package name
      if (rule.packageName.isNotEmpty && packageName != rule.packageName) {
        print('❌ Package name mismatch: "${packageName}" != "${rule.packageName}"');
        continue;
      }
      print('✅ Package name matched or empty');

      // Match title (case insensitive, contains)
      if (rule.title.isNotEmpty && 
          !title.toLowerCase().contains(rule.title.toLowerCase())) {
        print('❌ Title mismatch: "$title" does not contain "${rule.title}"');
        continue;
      }
      print('✅ Title matched or empty');

      // Match detail (case insensitive, contains)
      if (rule.detail.isNotEmpty && 
          !detail.toLowerCase().contains(rule.detail.toLowerCase())) {
        print('❌ Detail mismatch: "$detail" does not contain "${rule.detail}"');
        continue;
      }
      print('✅ Detail matched or empty');

      // Jika semua match, return rule ini
      print('🎯 RULE MATCHED! Returning rule for bank: ${rule.bankName}');
      return rule;
    }

    print('❌ No matching rule found after checking all ${rules.length} rules');
    return null;
  }
}
