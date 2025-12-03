# Privacy Policy - NotifListener

**Last Updated: December 3, 2025**

## Introduction

NotifListener ("the App") is designed to help users monitor and record banking transaction notifications automatically. This Privacy Policy explains how the App collects, uses, and protects your information.

By using this App, you agree to the collection and use of information in accordance with this policy.

## Information We Collect

### 1. Notification Data
The App requires access to your device notifications to function properly. Specifically, we collect:

- **Notification Content**: Text content from banking and payment app notifications
- **Package Names**: Identifiers of apps that send notifications (e.g., banking apps)
- **Timestamps**: When notifications are received
- **Transaction Details**: Information extracted from notifications such as:
  - Bank name
  - Transaction amount
  - Transaction type (debit/credit)
  - Account information (if present in notification)
  - QRIS transaction details

### 2. Configuration Data
- **Server URLs**: Custom server endpoints you configure for data transmission
- **App Settings**: Your preferences and configurations within the App
- **Notification Rules**: Custom rules you create for processing specific notifications

### 3. Local Storage
- **Transaction History**: Records of processed transactions stored locally on your device
- **Failed Transactions**: Transactions that failed to sync with your server

## How We Use Your Information

### Primary Purpose
The App uses collected notification data to:

1. **Extract Transaction Information**: Parse banking notifications to identify transaction details
2. **Send to Your Server**: Transmit extracted data to server URLs that YOU configure
3. **Local Recording**: Store transaction history locally on your device
4. **Retry Failed Transmissions**: Automatically retry sending failed transactions to your configured servers

### Important Notes
- **No Third-Party Sharing**: We do NOT share your data with any third parties
- **User-Controlled Destinations**: Data is ONLY sent to servers that YOU explicitly configure
- **No Analytics**: We do not use analytics services that collect your personal data
- **No Advertising**: We do not use your data for advertising purposes

## Data Storage and Security

### Local Storage
- All transaction data is stored locally in an encrypted SQLite database on your device
- You can clear this data at any time by uninstalling the App or clearing app data

### Data Transmission
- Data is transmitted to YOUR configured servers using HTTPS (if your server supports it)
- We recommend using HTTPS endpoints for secure transmission
- The App does not store your data on any servers controlled by the App developer

### Security Measures
- Notification access is protected by Android's permission system
- Local database is protected by Android's app sandboxing
- No data is transmitted to servers we control or operate

## Your Rights and Controls

### You Have the Right To:

1. **Revoke Notification Access**: 
   - Go to Android Settings → Apps → NotifListener → Permissions
   - Disable notification access at any time

2. **Delete Your Data**:
   - Uninstall the App to remove all local data
   - Clear app data from Android Settings

3. **Control Data Transmission**:
   - Configure or remove server URLs at any time
   - The App will not send data if no server URLs are configured

4. **View Collected Data**:
   - All processed transactions are visible within the App
   - You can review what data has been extracted and sent

## Permissions Explained

### Why We Need Notification Access

The App requires "Notification Listener" permission to:
- Read banking and payment notifications in real-time
- Extract transaction information automatically
- Process notifications even when the App is in the background

**This is a sensitive permission.** We only use it for the core functionality described above.

### Other Permissions

- **Internet Access**: Required to send data to your configured servers
- **Foreground Service**: Keeps the App running to monitor notifications continuously
- **Wake Lock**: Ensures the App can process notifications even when the screen is off
- **Boot Completed**: Allows the App to start automatically after device restart

## Data Retention

- **Local Data**: Stored indefinitely on your device until you delete it
- **Server Data**: Retention depends on YOUR server configuration (we have no control over this)

## Changes to This Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by:
- Updating the "Last Updated" date at the top of this policy
- Displaying a notification within the App (for significant changes)

## Children's Privacy

This App is not intended for use by children under the age of 13. We do not knowingly collect personal information from children under 13.

## Third-Party Services

The App does NOT integrate with any third-party services, analytics platforms, or advertising networks.

The only external connections made are to:
- **Your Configured Servers**: Servers whose URLs you explicitly provide in the App settings

## Compliance

### Google Play Store Policies
This App complies with Google Play Store policies regarding:
- Notification Listener Service usage
- Data safety and transparency
- User privacy and security

### Data Safety Disclosure
As required by Google Play, we disclose:
- **Data Collected**: Notification content, transaction details
- **Data Usage**: Sent to user-configured servers, stored locally
- **Data Sharing**: No sharing with third parties
- **Security**: Data transmission uses HTTPS (if configured), local storage is encrypted

## Contact Information

If you have questions or concerns about this Privacy Policy or the App's data practices, please contact:

**Developer**: [Galih Rakasiwi]  
**Email**: justrakka@gmail.com  
**GitHub**: https://github.com/41524120021/notification_listener


## Consent

By using NotifListener, you consent to:
1. The collection of notification data as described in this policy
2. The transmission of extracted data to servers you configure
3. Local storage of transaction history on your device

You can withdraw consent at any time by:
- Revoking notification access in Android Settings
- Uninstalling the App

---

## Indonesian Version / Versi Indonesia

# Kebijakan Privasi - NotifListener

**Terakhir Diperbarui: 3 Desember 2025**

## Pendahuluan

NotifListener ("Aplikasi") dirancang untuk membantu pengguna memantau dan mencatat notifikasi transaksi perbankan secara otomatis. Kebijakan Privasi ini menjelaskan bagaimana Aplikasi mengumpulkan, menggunakan, dan melindungi informasi Anda.

Dengan menggunakan Aplikasi ini, Anda menyetujui pengumpulan dan penggunaan informasi sesuai dengan kebijakan ini.

## Informasi yang Kami Kumpulkan

### 1. Data Notifikasi
Aplikasi memerlukan akses ke notifikasi perangkat Anda untuk berfungsi dengan baik. Secara khusus, kami mengumpulkan:

- **Konten Notifikasi**: Konten teks dari notifikasi aplikasi perbankan dan pembayaran
- **Nama Paket**: Identifikasi aplikasi yang mengirim notifikasi (misalnya, aplikasi perbankan)
- **Waktu**: Kapan notifikasi diterima
- **Detail Transaksi**: Informasi yang diekstrak dari notifikasi seperti:
  - Nama bank
  - Jumlah transaksi
  - Jenis transaksi (debit/kredit)
  - Informasi rekening (jika ada dalam notifikasi)
  - Detail transaksi QRIS

### 2. Data Konfigurasi
- **URL Server**: Endpoint server kustom yang Anda konfigurasi untuk transmisi data
- **Pengaturan Aplikasi**: Preferensi dan konfigurasi Anda dalam Aplikasi
- **Aturan Notifikasi**: Aturan kustom yang Anda buat untuk memproses notifikasi tertentu

### 3. Penyimpanan Lokal
- **Riwayat Transaksi**: Catatan transaksi yang diproses disimpan secara lokal di perangkat Anda
- **Transaksi Gagal**: Transaksi yang gagal disinkronkan dengan server Anda

## Bagaimana Kami Menggunakan Informasi Anda

### Tujuan Utama
Aplikasi menggunakan data notifikasi yang dikumpulkan untuk:

1. **Ekstraksi Informasi Transaksi**: Mengurai notifikasi perbankan untuk mengidentifikasi detail transaksi
2. **Kirim ke Server Anda**: Mengirimkan data yang diekstrak ke URL server yang ANDA konfigurasi
3. **Pencatatan Lokal**: Menyimpan riwayat transaksi secara lokal di perangkat Anda
4. **Coba Ulang Transmisi Gagal**: Secara otomatis mencoba mengirim ulang transaksi yang gagal ke server yang Anda konfigurasi

### Catatan Penting
- **Tidak Ada Berbagi dengan Pihak Ketiga**: Kami TIDAK membagikan data Anda dengan pihak ketiga mana pun
- **Tujuan Dikontrol Pengguna**: Data HANYA dikirim ke server yang ANDA konfigurasi secara eksplisit
- **Tanpa Analitik**: Kami tidak menggunakan layanan analitik yang mengumpulkan data pribadi Anda
- **Tanpa Iklan**: Kami tidak menggunakan data Anda untuk tujuan periklanan

## Penyimpanan dan Keamanan Data

### Penyimpanan Lokal
- Semua data transaksi disimpan secara lokal dalam database SQLite terenkripsi di perangkat Anda
- Anda dapat menghapus data ini kapan saja dengan mencopot Aplikasi atau menghapus data aplikasi

### Transmisi Data
- Data dikirimkan ke server yang ANDA konfigurasi menggunakan HTTPS (jika server Anda mendukung)
- Kami merekomendasikan menggunakan endpoint HTTPS untuk transmisi yang aman
- Aplikasi tidak menyimpan data Anda di server mana pun yang dikontrol oleh pengembang Aplikasi

### Langkah Keamanan
- Akses notifikasi dilindungi oleh sistem izin Android
- Database lokal dilindungi oleh sandboxing aplikasi Android
- Tidak ada data yang dikirimkan ke server yang kami kontrol atau operasikan

## Hak dan Kontrol Anda

### Anda Memiliki Hak Untuk:

1. **Mencabut Akses Notifikasi**:
   - Buka Pengaturan Android → Aplikasi → NotifListener → Izin
   - Nonaktifkan akses notifikasi kapan saja

2. **Menghapus Data Anda**:
   - Copot Aplikasi untuk menghapus semua data lokal
   - Hapus data aplikasi dari Pengaturan Android

3. **Mengontrol Transmisi Data**:
   - Konfigurasi atau hapus URL server kapan saja
   - Aplikasi tidak akan mengirim data jika tidak ada URL server yang dikonfigurasi

4. **Melihat Data yang Dikumpulkan**:
   - Semua transaksi yang diproses terlihat dalam Aplikasi
   - Anda dapat meninjau data apa yang telah diekstrak dan dikirim

## Penjelasan Izin

### Mengapa Kami Memerlukan Akses Notifikasi

Aplikasi memerlukan izin "Notification Listener" untuk:
- Membaca notifikasi perbankan dan pembayaran secara real-time
- Mengekstrak informasi transaksi secara otomatis
- Memproses notifikasi bahkan saat Aplikasi berjalan di latar belakang

**Ini adalah izin sensitif.** Kami hanya menggunakannya untuk fungsi inti yang dijelaskan di atas.

### Izin Lainnya

- **Akses Internet**: Diperlukan untuk mengirim data ke server yang Anda konfigurasi
- **Layanan Foreground**: Menjaga Aplikasi tetap berjalan untuk memantau notifikasi secara terus-menerus
- **Wake Lock**: Memastikan Aplikasi dapat memproses notifikasi bahkan saat layar mati
- **Boot Completed**: Memungkinkan Aplikasi untuk memulai secara otomatis setelah perangkat restart

## Penyimpanan Data

- **Data Lokal**: Disimpan tanpa batas waktu di perangkat Anda sampai Anda menghapusnya
- **Data Server**: Penyimpanan bergantung pada konfigurasi server ANDA (kami tidak memiliki kontrol atas ini)

## Perubahan pada Kebijakan Privasi Ini

Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan apa pun dengan:
- Memperbarui tanggal "Terakhir Diperbarui" di bagian atas kebijakan ini
- Menampilkan notifikasi dalam Aplikasi (untuk perubahan signifikan)

## Privasi Anak-anak

Aplikasi ini tidak ditujukan untuk digunakan oleh anak-anak di bawah usia 13 tahun. Kami tidak dengan sengaja mengumpulkan informasi pribadi dari anak-anak di bawah 13 tahun.

## Layanan Pihak Ketiga

Aplikasi TIDAK terintegrasi dengan layanan pihak ketiga, platform analitik, atau jaringan periklanan apa pun.

Satu-satunya koneksi eksternal yang dibuat adalah ke:
- **Server yang Anda Konfigurasi**: Server yang URL-nya Anda berikan secara eksplisit dalam pengaturan Aplikasi

## Kepatuhan

### Kebijakan Google Play Store
Aplikasi ini mematuhi kebijakan Google Play Store mengenai:
- Penggunaan Notification Listener Service
- Keamanan dan transparansi data
- Privasi dan keamanan pengguna

### Pengungkapan Keamanan Data
Sesuai yang disyaratkan oleh Google Play, kami mengungkapkan:
- **Data yang Dikumpulkan**: Konten notifikasi, detail transaksi
- **Penggunaan Data**: Dikirim ke server yang dikonfigurasi pengguna, disimpan secara lokal
- **Berbagi Data**: Tidak ada berbagi dengan pihak ketiga
- **Keamanan**: Transmisi data menggunakan HTTPS (jika dikonfigurasi), penyimpanan lokal terenkripsi

## Informasi Kontak

Jika Anda memiliki pertanyaan atau kekhawatiran tentang Kebijakan Privasi ini atau praktik data Aplikasi, silakan hubungi:

**Pengembang**: [galih rakasiwi]  
**Email**: [justrakka@gmail.com]  
**GitHub**: https://github.com/41524120021/notification_listener

## Persetujuan

Dengan menggunakan NotifListener, Anda menyetujui:
1. Pengumpulan data notifikasi seperti yang dijelaskan dalam kebijakan ini
2. Transmisi data yang diekstrak ke server yang Anda konfigurasi
3. Penyimpanan lokal riwayat transaksi di perangkat Anda

Anda dapat menarik persetujuan kapan saja dengan:
- Mencabut akses notifikasi di Pengaturan Android
- Mencopot Aplikasi

---

**Terima kasih telah menggunakan NotifListener!**
