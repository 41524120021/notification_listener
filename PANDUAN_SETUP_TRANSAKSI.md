# 📖 Panduan Setup Sistem Transaksi NotifListener

## Daftar Isi
1. [Setup Website (Backend)](#1-setup-website-backend)
2. [Setup Aplikasi Android](#2-setup-aplikasi-android)
3. [Konfigurasi Payment Gateway](#3-konfigurasi-payment-gateway)
4. [Konfigurasi Notification Rules](#4-konfigurasi-notification-rules)
5. [Testing & Troubleshooting](#5-testing--troubleshooting)

---

## 1. Setup Website (Backend)

### 📦 **Upload Website**

1. **Download file `public_html.zip`** dari folder project
2. **Login ke cPanel/Admin Panel** hosting Anda
3. **Akses File Manager** atau gunakan FTP
4. **Upload file zip** ke direktori `public_html` atau `www`
5. **Extract file zip** di server

**Atau melalui Admin Panel:**
- Akses: `https://domainanda.com/admin/sistem`
- Upload file `public_html.zip`
- Sistem akan otomatis extract dan setup

### 🗄️ **Setup Database**

1. **Import database** dari file `database.sql` (jika ada)
2. **Konfigurasi database** di file `application/config/database.php`:
   ```php
   $db['default'] = array(
       'hostname' => 'localhost',
       'username' => 'your_db_username',
       'password' => 'your_db_password',
       'database' => 'your_db_name',
   );
   ```

### 🔐 **Login Admin Panel**

- URL: `https://domainanda.com/admin`
- Username: `admin` (default)
- Password: `admin` (default)

⚠️ **PENTING**: Ganti password default setelah login pertama kali!

---

## 2. Setup Aplikasi Android

### 📱 **Install Aplikasi**

**Opsi 1: Google Play Store (Beta Testing)**
1. Klik link: [https://play.google.com/apps/testing/com.notiflistener.app](https://play.google.com/apps/testing/com.notiflistener.app)
2. Klik **"Become a tester"**
3. Download dan install aplikasi dari Play Store

**Opsi 2: Install Manual (APK)**
1. Download file `app-release.apk` dari folder `build/app/outputs/flutter-apk/`
2. Enable **"Install from Unknown Sources"** di Android
3. Install APK

### ⚙️ **Konfigurasi Server URL**

1. **Buka aplikasi NotifListener**
2. **Tap menu ⋮** (pojok kanan atas)
3. **Pilih "Pengaturan Server"**
4. **Isi URL server:**

   ```
   Server URL Utama:
   https://domainanda.com/api
   
   Fallback URL 1:
   https://domainanda.com/api
   (Isi sama dengan server utama jika tidak ada backup server)
   
   Fallback URL 2:
   https://domainanda.com/api
   (Isi sama dengan server utama jika tidak ada backup server)
   ```

5. **Tap "Simpan"**
6. **Restart aplikasi** untuk memastikan konfigurasi tersimpan

### 🔔 **Aktifkan Notification Listener**

1. **Tap "Tap untuk Aktifkan"** di halaman utama
2. **Pilih "NotifListener"** dari daftar
3. **Enable toggle** untuk memberikan akses
4. **Kembali ke aplikasi**
5. **Status harus berubah** menjadi "🟢 Listener Aktif"

### 🔋 **Disable Battery Optimization**

1. **Tap menu ⋮** → **"Battery Optimization"**
2. **Pilih "All apps"**
3. **Cari "NotifListener"**
4. **Pilih "Don't optimize"**
5. **Tap "Done"**

⚠️ **PENTING**: Ini memastikan aplikasi tetap berjalan di background!

---

## 3. Konfigurasi Payment Gateway

### 💳 **Setup QRIS (Quick Response Code Indonesian Standard)**

#### **Akses Menu QRIS**
- URL: `https://domainanda.com/admin/payments/qris_nt/settings`

#### **Konfigurasi QRIS**

| Field | Keterangan | Contoh |
|-------|------------|--------|
| **NMID** | Nomor Merchant ID dari penyedia QRIS | `ID1234567890123` |
| **Merchant Name** | Nama merchant yang tertera di QRIS | `Toko Saya` |
| **Merchant City** | Kota merchant | `Jakarta` |
| **Merchant Category** | Kode kategori merchant (4 digit) | `5812` (Restaurant) |
| **Currency Code** | Kode mata uang (360 = IDR) | `360` |
| **Country Code** | Kode negara (ID = Indonesia) | `ID` |
| **Static QR Code** | QR Code statis dari bank/penyedia | `00020101021126...` |

#### **Cara Mendapatkan Data QRIS:**

1. **Login ke aplikasi bank/e-wallet** (BCA, Mandiri, GoPay, dll)
2. **Buka menu QRIS Merchant**
3. **Pilih "QRIS Statis"** atau "Static QR"
4. **Copy data QRIS** (biasanya berupa string panjang)
5. **Paste ke field "Static QR Code"**

#### **Generate QRIS Dinamis:**

✅ **Otomatis!** Sistem akan generate QRIS dinamis berdasarkan:
- Static QR Code yang Anda input
- Nominal transaksi
- Timestamp unik

**Contoh:**
```
Input: Static QR = "00020101021126..."
Transaksi: Rp 50.000

Output: Dynamic QR = "00020101021126...54045000..." (dengan nominal embedded)
```

---

### 🏦 **Setup Transfer Bank**

#### **Akses Menu Transfer Bank**
- URL: `https://domainanda.com/admin/payments/transfer_bank/settings`

#### **Tambah Rekening Bank**

1. **Klik "Tambah Bank"**
2. **Isi data rekening:**

| Field | Keterangan | Contoh |
|-------|------------|--------|
| **Nama Bank** | Nama bank (uppercase) | `BCA`, `MANDIRI`, `BRI` |
| **Nomor Rekening** | Nomor rekening tujuan | `1234567890` |
| **Nama Pemilik** | Nama pemilik rekening | `John Doe` |
| **Cabang** | Cabang bank (opsional) | `Jakarta Pusat` |
| **Status** | Aktif/Nonaktif | `Aktif` |
| **Logo** | Upload logo bank | `bca_logo.png` |

3. **Klik "Simpan"**

#### **Contoh Konfigurasi Multiple Bank:**

```
Bank 1:
- Nama: BCA
- No. Rek: 1234567890
- Nama: PT. Example Indonesia
- Status: Aktif

Bank 2:
- Nama: MANDIRI
- No. Rek: 9876543210
- Nama: PT. Example Indonesia
- Status: Aktif

Bank 3:
- Nama: BRI
- No. Rek: 5555666677778888
- Nama: PT. Example Indonesia
- Status: Aktif
```

---

## 4. Konfigurasi Notification Rules

### 📋 **Akses Menu Notification Rules**
- URL: `https://domainanda.com/admin/notif_rules`

### ➕ **Tambah Rule Baru**

1. **Klik "Tambah Rule"**
2. **Isi data rule:**

| Field | Keterangan | Wajib | Contoh |
|-------|------------|-------|--------|
| **Bank Name** | Nama bank/payment (uppercase) | ✅ | `BCA`, `GOPAY`, `OVO` |
| **Package Name** | Package name aplikasi Android | ✅ | `com.bca.mybca.omni.android` |
| **Title** | Kata kunci di title notifikasi | ❌ | `Catatan Finansial`, `Transfer Masuk` |
| **Detail** | Kata kunci di detail/text notifikasi | ❌ | `Pemasukan`, `masuk`, `diterima` |
| **Extract Method** | Metode ekstraksi nominal | ✅ | `extractWithComma`, `extractWithDot` |
| **QRIS** | Centang jika transaksi QRIS | ❌ | ☑️ (untuk QRIS), ☐ (untuk Transfer) |
| **Active** | Status rule aktif/nonaktif | ✅ | ☑️ Aktif |

### 📱 **Cara Mendapatkan Package Name**

**Metode 1: Dari Aplikasi NotifListener**
1. Buka aplikasi NotifListener
2. Tap menu ⋮ → "Cek Notifikasi"
3. Lihat log di console (jika debug mode)
4. Package name akan terlihat di log

**Metode 2: Dari Play Store**
1. Buka aplikasi di Play Store
2. Lihat URL di browser
3. Contoh: `https://play.google.com/store/apps/details?id=com.bca.mybca.omni.android`
4. Package name = `com.bca.mybca.omni.android`

**Metode 3: Menggunakan ADB**
```bash
adb shell pm list packages | grep bca
# Output: package:com.bca.mybca.omni.android
```

### 📝 **Contoh Konfigurasi Rules**

#### **Rule 1: BCA (Transfer Bank)**
```
Bank Name: BCA
Package Name: com.bca.mybca.omni.android
Title: Catatan Finansial
Detail: Pemasukan
Extract Method: extractWithComma
QRIS: ☐ (Tidak)
Active: ☑️ Aktif
```

**Contoh Notifikasi yang Cocok:**
```
Title: Catatan Finansial
Text: Pemasukan Rp1.500.000,00 dari JOHN DOE pada 05/12/2025 10:30
```

#### **Rule 2: BRI (Transfer Bank)**
```
Bank Name: BRI
Package Name: id.co.bri.brimo
Title: BRImo
Detail: masuk
Extract Method: extractWithDot
QRIS: ☐ (Tidak)
Active: ☑️ Aktif
```

**Contoh Notifikasi yang Cocok:**
```
Title: BRImo
Text: Sobat BRI! Dana Rp1.000.451 masuk ke rekening 736901035288537 pada 05/12/2025 11:14:59 KET.:TRANSFER DARI JANE DOE
```

#### **Rule 3: GOPAY (QRIS)**
```
Bank Name: GOPAY
Package Name: com.gojek.app
Title: 
Detail: menerima
Extract Method: extractWithDot
QRIS: ☑️ (Ya)
Active: ☑️ Aktif
```

**Contoh Notifikasi yang Cocok:**
```
Title: GoPay
Text: Kamu menerima Rp50.000 dari Toko ABC via QRIS
```

#### **Rule 4: DANA (QRIS)**
```
Bank Name: DANA
Package Name: id.dana
Title: Uang Masuk
Detail: 
Extract Method: extractWithDot
QRIS: ☑️ (Ya)
Active: ☑️ Aktif
```

**Contoh Notifikasi yang Cocok:**
```
Title: Uang Masuk
Text: Rp75.000 masuk ke DANA kamu dari pembayaran QRIS
```

### 🔍 **Extract Methods**

| Method | Deskripsi | Format Nominal | Contoh |
|--------|-----------|----------------|--------|
| `extractWithComma` | Ekstrak nominal dengan koma sebagai separator desimal | `Rp1.500.000,00` | BCA, Mandiri |
| `extractWithDot` | Ekstrak nominal dengan titik sebagai separator ribuan | `Rp1.500.000` | BRI, GoPay, OVO |
| `extractQris` | Khusus untuk format QRIS | `Rp 50000` atau `50.000` | QRIS payments |

### ⚙️ **Tips Konfigurasi Rules**

1. **Title dan Detail bisa kosong**
   - Jika kosong, sistem hanya match berdasarkan Package Name
   - Lebih fleksibel tapi kurang spesifik

2. **Gunakan kata kunci yang unik**
   - Contoh: "Pemasukan" untuk BCA, "masuk" untuk BRI
   - Hindari kata umum seperti "dari", "ke", dll

3. **Test dengan notifikasi real**
   - Kirim transaksi test ke rekening
   - Lihat apakah notifikasi ter-capture
   - Check log di aplikasi

4. **QRIS vs Transfer Bank**
   - ☑️ QRIS: Untuk pembayaran via QR Code (GoPay, OVO, DANA, dll)
   - ☐ Transfer: Untuk transfer bank biasa (BCA, BRI, Mandiri, dll)

---

## 5. Testing & Troubleshooting

### ✅ **Testing Flow Lengkap**

#### **Test 1: Transfer Bank**
1. **Kirim transfer** ke rekening yang sudah dikonfigurasi
2. **Tunggu notifikasi** dari aplikasi bank
3. **Buka aplikasi NotifListener**
4. **Check tab "Transaksi"** → Transaksi harus muncul
5. **Check website admin** → Data harus tersimpan di database

#### **Test 2: QRIS**
1. **Generate QRIS** dari website (dengan nominal)
2. **Scan QRIS** menggunakan aplikasi e-wallet
3. **Bayar transaksi**
4. **Tunggu notifikasi** dari aplikasi e-wallet
5. **Buka aplikasi NotifListener**
6. **Check tab "QRIS"** → Transaksi harus muncul
7. **Check website admin** → Data harus tersimpan di database

### 🐛 **Troubleshooting**

#### **Problem 1: Notifikasi tidak ter-capture**

**Penyebab:**
- ❌ Notification Listener tidak aktif
- ❌ Battery optimization masih aktif
- ❌ Rule tidak match dengan notifikasi

**Solusi:**
1. Check status listener (harus 🟢 Aktif)
2. Disable battery optimization
3. Check rule configuration:
   - Package name harus exact match
   - Title/Detail harus ada di notifikasi
4. Test dengan menu "Cek Notifikasi" di aplikasi

#### **Problem 2: Nominal tidak ter-extract**

**Penyebab:**
- ❌ Extract method salah
- ❌ Format nominal tidak sesuai

**Solusi:**
1. Check format nominal di notifikasi
2. Pilih extract method yang sesuai:
   - Koma (`,`) → `extractWithComma`
   - Titik (`.`) → `extractWithDot`
3. Test dengan berbagai format nominal

#### **Problem 3: Data tidak masuk ke server**

**Penyebab:**
- ❌ Server URL salah
- ❌ Server down/maintenance
- ❌ Network error

**Solusi:**
1. Check server URL di pengaturan
2. Test koneksi: `ping domainanda.com`
3. Check server logs di cPanel
4. Gunakan fallback URL jika server utama down
5. Retry failed transactions dari menu aplikasi

#### **Problem 4: Transaksi duplikat**

**Penyebab:**
- ❌ Notifikasi yang sama diproses berkali-kali
- ❌ Bug di sistem (sudah diperbaiki di versi terbaru)

**Solusi:**
1. Update aplikasi ke versi terbaru
2. Check log untuk "DUPLICATE DETECTED"
3. Clear notification setelah diproses
4. Restart aplikasi jika masih terjadi

### 📊 **Monitoring**

#### **Di Aplikasi:**
- **Tab "Transaksi"**: Lihat semua transaksi transfer bank
- **Tab "QRIS"**: Lihat semua transaksi QRIS
- **Tab "Rules"**: Lihat dan edit notification rules
- **Menu "Cek Notifikasi"**: Manual check notifikasi di status bar
- **Menu "Retry Gagal"**: Retry transaksi yang gagal dikirim

#### **Di Website Admin:**
- **Dashboard**: Overview transaksi hari ini
- **Transaksi**: List semua transaksi
- **QRIS**: List transaksi QRIS
- **Reports**: Laporan transaksi per periode
- **Logs**: System logs dan error logs

### 📞 **Support**

Jika masih ada masalah:
1. Check dokumentasi lengkap di folder project
2. Lihat log error di aplikasi dan server
3. Contact developer dengan info:
   - Screenshot error
   - Log file
   - Langkah yang sudah dilakukan

---

## 📚 Referensi Tambahan

- [ANDROID_15_EDGE_TO_EDGE.md](./ANDROID_15_EDGE_TO_EDGE.md) - Panduan kompatibilitas Android 15
- [FIX_DUPLICATE_TRANSACTIONS.md](./FIX_DUPLICATE_TRANSACTIONS.md) - Fix duplikasi transaksi
- [API Documentation](./API_DOCUMENTATION.md) - Dokumentasi API endpoint (jika ada)

---

## 🎯 Checklist Setup

### Website
- [ ] Upload dan extract `public_html.zip`
- [ ] Konfigurasi database
- [ ] Login admin panel
- [ ] Ganti password default
- [ ] Setup QRIS settings
- [ ] Setup transfer bank settings
- [ ] Tambah notification rules

### Aplikasi
- [ ] Install aplikasi dari Play Store/APK
- [ ] Konfigurasi server URL
- [ ] Aktifkan notification listener
- [ ] Disable battery optimization
- [ ] Test notifikasi bank
- [ ] Verify data masuk ke server

### Testing
- [ ] Test transfer bank → Notifikasi ter-capture
- [ ] Test QRIS → Notifikasi ter-capture
- [ ] Check data di tab "Transaksi"
- [ ] Check data di tab "QRIS"
- [ ] Check data di website admin
- [ ] Test retry failed transactions
- [ ] Monitor untuk duplikasi

---

**Versi**: 1.0  
**Terakhir Update**: 2025-12-05  
**Status**: ✅ Ready for Production

---

## 💡 Tips & Best Practices

1. **Backup Database Rutin**
   - Setup auto backup harian
   - Simpan backup di lokasi terpisah

2. **Monitor Log Secara Berkala**
   - Check error log di server
   - Check application log di aplikasi

3. **Update Aplikasi**
   - Selalu gunakan versi terbaru
   - Check Play Store untuk update

4. **Security**
   - Ganti password admin secara berkala
   - Gunakan HTTPS untuk server URL
   - Enable firewall di server

5. **Performance**
   - Clear old transactions secara berkala
   - Optimize database indexes
   - Monitor server resources

---

**🎉 Selamat! Setup sistem transaksi NotifListener sudah selesai!**

Jika ada pertanyaan atau kendala, silakan hubungi developer atau check dokumentasi tambahan di folder project.
