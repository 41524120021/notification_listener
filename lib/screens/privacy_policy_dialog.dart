import 'package:flutter/material.dart';
import '../services/privacy_policy_manager.dart';

/// Dialog untuk menampilkan Privacy Policy saat pertama kali buka aplikasi
class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent dismiss dengan back button
      onWillPop: () async => false,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: Colors.deepPurple.shade700, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Kebijakan Privasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Harap baca kebijakan privasi sebelum menggunakan aplikasi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  PrivacyPolicyManager.getPrivacyPolicyTextId(),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // User menolak - keluar dari aplikasi
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Tolak',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // User menerima - simpan consent
              await PrivacyPolicyManager.acceptPrivacyPolicy();
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Setuju',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  /// Show privacy policy dialog
  /// Returns true jika user menerima, false jika menolak
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Tidak bisa dismiss dengan tap di luar
      builder: (context) => const PrivacyPolicyDialog(),
    );
    return result ?? false;
  }
}
