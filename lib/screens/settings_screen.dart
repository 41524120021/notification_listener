import 'package:flutter/material.dart';
import '../services/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _fallbackUrlController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Preview normalized URLs
  String _baseUrlPreview = '';
  String _fallbackUrlPreview = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    
    // Add listeners to show preview
    _baseUrlController.addListener(() {
      setState(() {
        if (_baseUrlController.text.isNotEmpty) {
          _baseUrlPreview = SettingsManager.normalizeUrl(_baseUrlController.text);
        } else {
          _baseUrlPreview = '';
        }
      });
    });
    
    _fallbackUrlController.addListener(() {
      setState(() {
        if (_fallbackUrlController.text.isNotEmpty) {
          _fallbackUrlPreview = SettingsManager.normalizeUrl(_fallbackUrlController.text);
        } else {
          _fallbackUrlPreview = '';
        }
      });
    });
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final baseUrl = await SettingsManager.getBaseUrl();
      final fallbackUrl = await SettingsManager.getFallbackUrl();
      
      if (baseUrl != null) _baseUrlController.text = baseUrl;
      if (fallbackUrl != null) _fallbackUrlController.text = fallbackUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await SettingsManager.setBaseUrl(_baseUrlController.text);
      await SettingsManager.setFallbackUrl(_fallbackUrlController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pengaturan berhasil disimpan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Kembali ke halaman sebelumnya
        Navigator.pop(context, true); // true = settings changed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _clearSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengaturan?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua pengaturan URL?\n\n'
          'Anda harus mengatur ulang URL sebelum dapat menggunakan aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SettingsManager.clearSettings();
      _baseUrlController.clear();
      _fallbackUrlController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pengaturan telah dihapus'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _fallbackUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Server'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade400,
                Colors.purple.shade300,
                Colors.pink.shade200,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearSettings,
            tooltip: 'Hapus Pengaturan',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Card dengan contoh
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Panduan Pengisian URL',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '✅ Format yang benar:\n'
                              '   https://domainanda.com/\n'
                              '   https://api.domainanda.com/\n\n'
                              '💡 Tips:\n'
                              '   • Bisa tanpa "https://" (otomatis ditambahkan)\n'
                              '   • Bisa tanpa "/" di akhir (otomatis ditambahkan)\n'
                              '   • Contoh input: domainanda.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Base URL Section
                    _buildSectionTitle('Server Utama (Primary)'),
                    const SizedBox(height: 8),
                    _buildUrlField(
                      controller: _baseUrlController,
                      label: 'Base URL',
                      hint: 'domainanda.com',
                      icon: Icons.cloud,
                      preview: _baseUrlPreview,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Server utama untuk posting transaksi dan mengambil data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Fallback URL Section
                    _buildSectionTitle('Server Cadangan (Fallback)'),
                    const SizedBox(height: 8),
                    _buildUrlField(
                      controller: _fallbackUrlController,
                      label: 'Fallback URL',
                      hint: 'backup.domainanda.com',
                      icon: Icons.cloud_queue,
                      preview: _fallbackUrlPreview,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Server cadangan jika server utama gagal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Info tentang perubahan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Catatan Penting',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Posting hanya ke 1 server (Base URL)\n'
                            '• Fallback URL digunakan jika Base URL gagal\n'
                            '• Perubahan langsung berlaku tanpa restart app\n'
                            '• URL akan otomatis dikoreksi saat disimpan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Simpan Pengaturan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple.shade700,
      ),
    );
  }

  Widget _buildUrlField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String preview,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.deepPurple),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.url,
          validator: (value) => SettingsManager.validateUrl(value ?? ''),
        ),
        // Preview normalized URL
        if (preview.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Akan disimpan sebagai: $preview',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
