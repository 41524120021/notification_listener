import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'settings_manager.dart';
import 'donation_manager.dart';

class TransactionService {

  // Get transaksi dari server (untuk tab Data Transaksi)
  // Hanya ambil 10 data terakhir untuk menghindari data terlalu banyak
  static Future<List<Transaction>> getTransaksiFromServer() async {
    try {
      final baseUrl = await SettingsManager.getBaseUrl();
      
      if (baseUrl == null) {
        print('❌ Base URL not configured');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${baseUrl}api/notif_api/get_transaksi'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final jsonList = jsonDecode(response.body) as List;
        return _parseTransactions(jsonList);
      }

      return [];
    } catch (e) {
      print('Error getting transaksi: $e');
      return [];
    }
  }

  // Get transaksi QRIS dari server (untuk tab Trx QRIS)
  // Hanya ambil 10 data terakhir
  static Future<List<Transaction>> getQrisFromServer() async {
    try {
      final baseUrl = await SettingsManager.getBaseUrl();
      
      if (baseUrl == null) {
        print('❌ Base URL not configured');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${baseUrl}api/notif_api/get_transaksi_qris'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final jsonList = jsonDecode(response.body) as List;
        // Pass true untuk forceQris karena ini dari endpoint QRIS
        return _parseTransactions(jsonList, forceQris: true);
      }

      return [];
    } catch (e) {
      print('Error getting QRIS: $e');
      return [];
    }
  }

  /// Post transaksi ke 1 server saja (Base URL)
  /// Dengan fallback ke server kedua jika gagal
  /// Return Map dengan 'success' (bool) dan 'shouldShowDonation' (bool)
  static Future<Map<String, dynamic>> postTransaction({
    required int amount,
    required String text,
    required String packageName,
  }) async {
    print('📤 Starting transaction posting...');

    try {
      final baseUrl = await SettingsManager.getBaseUrl();
      final fallbackUrl = await SettingsManager.getFallbackUrl();
      
      if (baseUrl == null || fallbackUrl == null) {
        print('❌ URLs not configured. Please configure in Settings.');
        return {'success': false, 'shouldShowDonation': false};
      }
      
      // Try posting to primary server
      print('→ Posting to primary server ($baseUrl)...');
      try {
        final response = await http.post(
          Uri.parse('${baseUrl}api/notif_api/insert_data'),
          body: {
            'nilaitransaksi': amount.toString(),
            'text': text,
            'packagename': packageName,
          },
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          print('✅ Post sukses ke primary server');
          
          // Hit counter
          try {
            await http.get(Uri.parse('${baseUrl}pending/transaksinl'))
                .timeout(const Duration(seconds: 5));
            print('  → Counter updated');
          } catch (e) {
            print('  ⚠️ Counter failed: $e');
          }
          
          // Increment donation counter and check if should show donation
          final shouldShowDonation = await DonationManager.incrementAndCheckShowDonation();
          
          return {'success': true, 'shouldShowDonation': shouldShowDonation};
        } else {
          print('❌ Post gagal ke primary server: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error posting to primary server: $e');
      }

      // Fallback to secondary server
      print('→ Trying fallback server ($fallbackUrl)...');
      try {
        final response = await http.post(
          Uri.parse('${fallbackUrl}api/notif_api/insert_data'),
          body: {
            'nilaitransaksi': amount.toString(),
            'text': text,
            'packagename': packageName,
          },
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          print('✅ Post sukses ke fallback server');
          
          // Hit counter
          try {
            await http.get(Uri.parse('${fallbackUrl}pending/transaksinl'))
                .timeout(const Duration(seconds: 5));
            print('  → Counter updated');
          } catch (e) {
            print('  ⚠️ Counter failed: $e');
          }
          
          // Increment donation counter and check if should show donation
          final shouldShowDonation = await DonationManager.incrementAndCheckShowDonation();
          
          return {'success': true, 'shouldShowDonation': shouldShowDonation};
        } else {
          print('❌ Post gagal ke fallback server: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error posting to fallback server: $e');
      }

      print('❌ Posting failed to all servers');
      return {'success': false, 'shouldShowDonation': false};
      
    } catch (e) {
      print('❌ Error in postTransaction: $e');
      return {'success': false, 'shouldShowDonation': false};
    }
  }

  // Parse transaksi dari server
  // Support untuk 2 format: 'bank' (transaksi biasa) dan 'Qris' (transaksi QRIS)
  // forceQris: jika true, semua transaksi akan di-mark sebagai QRIS (untuk endpoint get_transaksi_qris)
  static List<Transaction> _parseTransactions(List jsonList, {bool forceQris = false}) {
    return jsonList.map((json) {
      // Cek apakah ini transaksi QRIS atau biasa
      // Jika forceQris = true (dari endpoint QRIS), langsung set sebagai QRIS
      // Jika tidak, cek dari field 'Qris' di JSON
      final isQris = forceQris || (json.containsKey('Qris') && json['Qris'] != null);
      
      return Transaction(
        idTransaksi: json['id_transaksi']?.toString(),
        idWeb: json['parsing']?.toString(), // ID dari web/server
        bankName: json['bank'] ?? json['Qris'] ?? 'Unknown',
        amount: json['nilaitransaksi']?.toString(),
        detail: json['text'] ?? '',
        timestamp: json['created_date'] != null
            ? DateTime.tryParse(json['created_date']) ?? DateTime.now()
            : DateTime.now(),
        isQris: isQris, // Set flag QRIS
      );
    }).toList();
  }

  /// Cek pending di server (Base URL dengan fallback)
  /// Hit endpoint untuk trigger proses pending di server
  static Future<Map<String, int>> cekPending() async {
    int successCount = 0;
    int failedCount = 0;

    try {
      print('🔍 Cek pending started...');
      
      final baseUrl = await SettingsManager.getBaseUrl();
      final fallbackUrl = await SettingsManager.getFallbackUrl();
      
      if (baseUrl == null || fallbackUrl == null) {
        print('❌ URLs not configured');
        return {'success': 0, 'failed': 0};
      }
      
      // Try primary server first
      try {
        final response = await http.get(Uri.parse('${baseUrl}pending'))
            .timeout(const Duration(seconds: 150));
        
        if (response.statusCode == 200) {
          successCount++;
          print('✅ Cek pending primary server: OK');
          
          return {
            'success': successCount,
            'failed': failedCount,
          };
        } else {
          print('❌ Cek pending primary server: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error cek pending primary server: $e');
      }
      
      // Fallback to secondary server
      try {
        final response = await http.get(Uri.parse('${fallbackUrl}cek_mutasi'))
            .timeout(const Duration(seconds: 150));
        
        if (response.statusCode == 200) {
          successCount++;
          print('✅ Cek pending fallback server: OK');
        } else {
          failedCount++;
          print('❌ Cek pending fallback server: ${response.statusCode}');
        }
      } catch (e) {
        failedCount++;
        print('❌ Error cek pending fallback server: $e');
      }
      
      print('📊 Cek pending selesai: $successCount berhasil, $failedCount gagal');
      
      return {
        'success': successCount,
        'failed': failedCount,
      };
    } catch (e) {
      print('❌ Error cek pending: $e');
      return {
        'success': successCount,
        'failed': failedCount,
      };
    }
  }
}
