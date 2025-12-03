# Perubahan Aplikasi NotifListener - v2.0

## 📝 Ringkasan Perubahan

Aplikasi NotifListener telah diperbarui dengan fitur pengaturan URL server yang dapat diubah tanpa perlu rebuild APK, dan penyederhanaan posting transaksi dari 3 server menjadi 1 server dengan fallback.

## ✨ Fitur Baru

### 1. **Pengaturan Server URL (Configurable)** 
- ✅ Menambahkan UI untuk mengatur Base URL dan Fallback URL
- ✅ URL disimpan di SharedPreferences (persistent)
- ✅ Dapat diubah kapan saja tanpa rebuild APK
- ✅ **Validasi Pintar**: Pesan error yang jelas dan detail
- ✅ **Auto-correction**: Otomatis tambahkan `https://` dan `/` jika tidak ada
- ✅ **Preview URL**: Tampilkan preview URL yang akan disimpan saat mengetik
- ✅ **No Default URLs**: User WAJIB setting sendiri (cocok untuk publish ke end user)
- ✅ **Panduan Lengkap**: Contoh format URL yang benar di Settings screen

### 2. **Penyederhanaan Posting Transaksi**
- ✅ **Sebelumnya**: Posting ke 3 server (ahlipulsa.com, isipulsaku.com, digitu.my.id)
- ✅ **Sekarang**: Posting ke 1 server saja (Base URL) dengan fallback otomatis ke server kedua jika gagal
- ✅ Lebih cepat dan efisien (1 request vs 3 requests)
- ✅ Mengurangi beban network dan battery

### 3. **User Experience Improvements**
- ✅ **Persistent Warning Banner**: Tampil di atas tabs jika URL belum dikonfigurasi
- ✅ **Tap to Configure**: User bisa tap banner untuk langsung ke Settings
- ✅ **Auto-refresh**: Banner hilang otomatis setelah URL di-set
- ✅ **Non-blocking**: App tetap bisa jalan meskipun URL belum di-set
- ✅ **Clear Feedback**: Notifikasi sukses/error yang jelas

## 📂 File yang Dibuat/Diubah

### File Baru:
1. **`lib/services/settings_manager.dart`**
   - Manager untuk menyimpan dan mengambil URL dari SharedPreferences
   - Fungsi validasi URL dengan pesan error detail
   - Fungsi normalisasi URL (auto-add https:// dan /)
   - Check if URLs configured

2. **`lib/screens/settings_screen.dart`**
   - UI untuk mengatur Base URL dan Fallback URL
   - Form dengan validasi real-time
   - Preview URL yang akan disimpan
   - Panduan pengisian dengan contoh
   - Tombol hapus pengaturan

3. **`PLAYSTORE_PUBLISH_GUIDE.md`**
   - Panduan lengkap publish ke Google Play Store
   - Checklist requirements
   - Special notes untuk Notification Listener permission
   - Privacy Policy template

### File yang Diubah:
1. **`lib/services/rules_manager.dart`**
   - Menghapus hardcoded URLs
   - Menggunakan SettingsManager untuk dynamic URLs
   - Null check untuk URLs

2. **`lib/services/transaction_service.dart`**
   - Menghapus hardcoded URLs
   - `postTransaction()`: Disederhanakan dari 3 server → 1 server + fallback
   - `cekPending()`: Disederhanakan dari 3 server → 1 server + fallback
   - `getTransaksiFromServer()`: Menggunakan dynamic URL
   - `getQrisFromServer()`: Menggunakan dynamic URL
   - Null check untuk semua method

3. **`lib/main.dart`**
   - Menambahkan import SettingsManager dan SettingsScreen
   - Menambahkan menu "Pengaturan Server" di popup menu
   - Update `_cekPending()` untuk menggunakan TransactionService.cekPending()
   - Tambah state `_isUrlConfigured` untuk tracking
   - Tambah persistent warning banner
   - Periodic check URL configuration (tiap 10 detik)

4. **`lib/services/foreground_task_handler.dart`**
   - Update `_cekPending()` untuk menggunakan TransactionService.cekPending()

## 🎯 Cara Menggunakan

### Pertama Kali Buka App:
1. Akan muncul **warning banner orange** di atas tabs
2. Tap banner atau buka menu **⋮** → **"Pengaturan Server"**
3. Isi **Base URL** dan **Fallback URL**
   - Contoh: `domainanda.com` (https:// dan / otomatis ditambahkan)
   - Atau: `https://domainanda.com/` (format lengkap)
4. Lihat **preview** URL yang akan disimpan (warna hijau)
5. Tap **"Simpan Pengaturan"**
6. Banner warning akan hilang otomatis

### Mengubah URL Server:
1. Buka aplikasi NotifListener
2. Tap icon **⋮** (3 titik) di pojok kanan atas
3. Pilih **"Pengaturan Server"**
4. Edit **Base URL** (server utama) dan **Fallback URL** (server cadangan)
5. Tap **"Simpan Pengaturan"**
6. Selesai! Perubahan langsung berlaku tanpa restart app

### Hapus Pengaturan:
1. Di halaman Pengaturan Server
2. Tap icon **🗑️** (delete) di pojok kanan atas
3. Konfirmasi hapus
4. URL akan dihapus dan warning banner muncul lagi

## 🔧 Detail Teknis

### URL Configuration:
- **Tidak ada default URLs** - user WAJIB setting sendiri
- URLs disimpan di SharedPreferences
- Auto-normalization: `domainanda.com` → `https://domainanda.com/`

### Validasi URL:
- ✅ Tidak boleh kosong
- ✅ Harus ada protokol (http:// atau https://)
- ✅ Harus ada domain yang valid
- ✅ Domain harus punya titik (.) atau localhost
- ❌ Error message yang jelas jika tidak valid

### Endpoint yang Digunakan:
- **Get Rules**: `{baseUrl}api/notif_api/get_rules`
- **Get Transaksi**: `{baseUrl}api/notif_api/get_transaksi`
- **Get QRIS**: `{baseUrl}api/notif_api/get_transaksi_qris`
- **Post Transaction**: `{baseUrl}api/notif_api/insert_data`
- **Counter**: `{baseUrl}pending/transaksinl`
- **Cek Pending**: `{baseUrl}pending` atau `{fallbackUrl}cek_mutasi`

### Alur Posting Transaksi (Baru):
1. Check if URLs configured → jika tidak, return false
2. Coba posting ke **Base URL**
3. Jika sukses → selesai ✅
4. Jika gagal → coba **Fallback URL**
5. Jika sukses → selesai ✅
6. Jika gagal → return false ❌ (akan di-retry nanti)

### Behavior Jika URL Belum Di-set:
- ✅ App tetap bisa dibuka dan digunakan
- ✅ Notification listener tetap jalan
- ✅ Warning banner muncul persistent
- ❌ Posting transaksi return false (data tersimpan lokal untuk retry)
- ❌ Get data dari server return empty array
- ❌ Load rules dari server return null

## 📊 Keuntungan Perubahan

1. ✅ **Fleksibilitas**: Bisa ganti server tanpa rebuild APK
2. ✅ **Efisiensi**: Posting hanya ke 1 server (lebih cepat & hemat battery)
3. ✅ **Reliability**: Ada fallback otomatis jika server utama down
4. ✅ **User-Friendly**: UI yang mudah digunakan dengan panduan jelas
5. ✅ **Maintainability**: Kode lebih bersih dan mudah di-maintain
6. ✅ **Ready for End Users**: Cocok untuk publish ke Play Store
7. ✅ **Privacy**: User kontrol penuh ke mana data dikirim

## 🚀 Testing

Untuk testing perubahan:
1. Build dan install APK
2. Buka app → lihat warning banner
3. Tap banner → isi URL
4. Coba ubah URL di Pengaturan Server
5. Trigger notifikasi untuk test posting transaksi
6. Cek log untuk memastikan menggunakan URL yang benar
7. Coba hapus pengaturan → banner muncul lagi

## 📝 Catatan Penting

- ✅ Semua perubahan backward compatible
- ✅ Data yang sudah ada tidak akan terpengaruh
- ✅ URL disimpan secara persistent (tidak hilang saat restart app)
- ✅ Validasi URL otomatis mencegah input URL yang salah
- ⚠️ User HARUS setting URL sebelum bisa posting ke server
- ⚠️ App tetap bisa jalan meskipun URL belum di-set (non-blocking)

## 🎯 Ready for Play Store

App ini sudah siap untuk di-publish ke Google Play Store dengan catatan:
1. ✅ Buat Privacy Policy (lihat template di `PLAYSTORE_PUBLISH_GUIDE.md`)
2. ✅ Isi Data Safety form di Play Console
3. ✅ Upload screenshots dan feature graphic
4. ✅ Explain penggunaan Notification Listener permission
5. ✅ Test di multiple devices

Lihat panduan lengkap di **`PLAYSTORE_PUBLISH_GUIDE.md`**
