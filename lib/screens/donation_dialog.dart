import 'package:flutter/material.dart';
import '../services/donation_manager.dart';

/// Dialog untuk menampilkan QRIS donation setiap 500 transaksi berhasil
class DonationDialog extends StatelessWidget {
  const DonationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade700,
                    Colors.orange.shade600,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Success icon with animation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<int>(
                    future: DonationManager.getSuccessCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Text(
                        '🎉 $count Transaksi Berhasil! 🎉',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.coffee,
                          size: 40,
                          color: Colors.brown.shade700,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Setiap uang kopi yang Anda berikan sangat berharga.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Terima kasih atas dukungan Anda! 🙏',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // QRIS Image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/qrislivin.jpeg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'QRIS Code',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Scan QRIS di atas untuk memberikan dukungan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show donation dialog
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const DonationDialog(),
    );
  }
}
