import 'package:flutter/material.dart';
import '../services/privacy_policy_manager.dart';

/// Dialog untuk menampilkan Privacy Policy saat pertama kali buka aplikasi
class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if user has scrolled to bottom
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      // Consider "bottom" if within 50 pixels of the end
      if (currentScroll >= maxScroll - 50 && !_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    return WillPopScope(
      // Prevent dismiss dengan back button
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade700,
                      Colors.deepPurple.shade500,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.privacy_tip,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Kebijakan Privasi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Harap baca kebijakan privasi sebelum menggunakan aplikasi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Privacy policy text
                      Text(
                        PrivacyPolicyManager.getPrivacyPolicyTextId(),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Scroll indicator if not at bottom
                      if (!_hasScrolledToBottom)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade300, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_downward, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Scroll ke bawah untuk mengaktifkan tombol Setuju',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tombol Tolak
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Tolak',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Setuju (disabled until scrolled to bottom)
                    ElevatedButton(
                      onPressed: _hasScrolledToBottom
                          ? () async {
                              await PrivacyPolicyManager.acceptPrivacyPolicy();
                              if (context.mounted) {
                                Navigator.of(context).pop(true);
                              }
                            }
                          : null, // Disabled if not scrolled to bottom
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasScrolledToBottom
                            ? Colors.deepPurple.shade600
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: _hasScrolledToBottom ? 3 : 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_hasScrolledToBottom)
                            const Icon(Icons.check_circle, size: 20)
                          else
                            const Icon(Icons.lock, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _hasScrolledToBottom ? 'Setuju' : 'Scroll Dulu',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show privacy policy dialog
  /// Returns true jika user menerima, false jika menolak
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PrivacyPolicyDialog(),
    );
    return result ?? false;
  }
}
