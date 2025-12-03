import 'package:shared_preferences/shared_preferences.dart';

/// Manager untuk Privacy Policy consent
class PrivacyPolicyManager {
  static const String _keyPrivacyAccepted = 'privacy_policy_accepted';
  static const String _keyPrivacyVersion = 'privacy_policy_version';
  static const String currentVersion = '1.0.0'; // Update ini jika privacy policy berubah

  /// Check apakah user sudah menerima privacy policy
  static Future<bool> hasAcceptedPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_keyPrivacyAccepted) ?? false;
    final version = prefs.getString(_keyPrivacyVersion) ?? '';
    
    // Return true hanya jika sudah accept DAN versinya sama dengan current version
    return accepted && version == currentVersion;
  }

  /// Simpan bahwa user sudah menerima privacy policy
  static Future<void> acceptPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrivacyAccepted, true);
    await prefs.setString(_keyPrivacyVersion, currentVersion);
  }

  /// Reset privacy policy acceptance (untuk testing atau jika ada update major)
  static Future<void> resetPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrivacyAccepted);
    await prefs.remove(_keyPrivacyVersion);
  }

  /// Get privacy policy text dalam Bahasa Indonesia
  static String getPrivacyPolicyTextId() {
    return '''
KEBIJAKAN PRIVASI - NotifListener

Terakhir Diperbarui: 3 Desember 2025

PENDAHULUAN

NotifListener dirancang untuk membantu Anda memantau dan mencatat notifikasi transaksi perbankan secara otomatis. Kebijakan Privasi ini menjelaskan bagaimana aplikasi mengumpulkan, menggunakan, dan melindungi informasi Anda.

INFORMASI YANG KAMI KUMPULKAN

1. Data Notifikasi
   • Konten notifikasi dari aplikasi perbankan dan pembayaran
   • Nama aplikasi yang mengirim notifikasi
   • Waktu notifikasi diterima
   • Detail transaksi (nama bank, jumlah, jenis transaksi)

2. Data Konfigurasi
   • URL server yang Anda konfigurasi
   • Pengaturan aplikasi Anda
   • Aturan notifikasi kustom

3. Penyimpanan Lokal
   • Riwayat transaksi di perangkat Anda
   • Transaksi yang gagal dikirim

BAGAIMANA KAMI MENGGUNAKAN DATA ANDA

✓ Mengekstrak informasi transaksi dari notifikasi
✓ Mengirim data ke server yang ANDA konfigurasi
✓ Menyimpan riwayat transaksi secara lokal
✓ Mencoba ulang pengiriman yang gagal

PENTING:
✗ Kami TIDAK membagikan data Anda ke pihak ketiga
✗ Data HANYA dikirim ke server yang Anda tentukan
✗ Kami TIDAK menggunakan data untuk iklan
✗ Kami TIDAK menggunakan layanan analitik pihak ketiga

KEAMANAN DATA

• Data disimpan dalam database terenkripsi di perangkat Anda
• Transmisi data menggunakan HTTPS (jika server Anda mendukung)
• Kami tidak menyimpan data di server yang kami kontrol

HAK ANDA

Anda dapat:
• Mencabut akses notifikasi kapan saja (Settings → Apps → NotifListener)
• Menghapus semua data dengan uninstall aplikasi
• Mengontrol pengiriman data dengan mengatur URL server
• Melihat semua transaksi yang diproses dalam aplikasi

IZIN YANG DIPERLUKAN

• Notification Listener: Untuk membaca notifikasi perbankan
• Internet: Untuk mengirim data ke server Anda
• Foreground Service: Agar aplikasi tetap berjalan
• Wake Lock: Memproses notifikasi saat layar mati
• Boot Completed: Memulai otomatis setelah restart

KONTAK

Jika ada pertanyaan tentang kebijakan privasi ini, silakan hubungi pengembang melalui GitHub repository aplikasi ini.

PERSETUJUAN

Dengan menekan "Setuju", Anda menyetujui:
1. Pengumpulan data notifikasi seperti dijelaskan di atas
2. Pengiriman data ke server yang Anda konfigurasi
3. Penyimpanan riwayat transaksi di perangkat Anda

Anda dapat menarik persetujuan kapan saja dengan mencabut akses notifikasi atau uninstall aplikasi.

---

Untuk versi lengkap dalam Bahasa Inggris dan Indonesia, silakan kunjungi:
https://github.com/41524120021/notiflistener_share/blob/main/PRIVACY_POLICY.md
''';
  }
}
