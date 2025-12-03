# 📱 NotifListener - Automatic Transaction Notification System

> Sistem otomatis untuk menangkap notifikasi transaksi bank dan QRIS, kemudian mengirimkan data ke server untuk pencatatan dan monitoring.

[![Android](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![Flutter](https://img.shields.io/badge/Framework-Flutter-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

## 🌟 Features

### 📲 Aplikasi Android
- ✅ **Auto-capture** notifikasi transaksi dari aplikasi bank
- ✅ **Multi-bank support** (BCA, BRI, Mandiri, dll)
- ✅ **QRIS support** (GoPay, OVO, DANA, dll)
- ✅ **Background service** - Berjalan 24/7 di background
- ✅ **Auto-retry** - Retry otomatis jika gagal kirim ke server
- ✅ **Duplicate detection** - Mencegah transaksi duplikat
- ✅ **Multi-server** - Support 3 server URL (utama + 2 fallback)
- ✅ **Real-time sync** - Data langsung tersinkronisasi ke server
- ✅ **Battery optimized** - Hemat baterai dengan foreground service

### 🌐 Website Backend
- ✅ **Admin panel** - Dashboard untuk monitoring transaksi
- ✅ **QRIS generator** - Generate QRIS dinamis dengan nominal
- ✅ **Bank management** - Kelola multiple rekening bank
- ✅ **Rules configuration** - Atur rules untuk capture notifikasi
- ✅ **Transaction history** - Riwayat semua transaksi
- ✅ **Reports** - Laporan transaksi per periode
- ✅ **API endpoints** - RESTful API untuk integrasi

## 📋 Requirements

### Aplikasi Android
- Android 5.0 (Lollipop) atau lebih tinggi
- Notification access permission
- Internet connection
- Battery optimization disabled (recommended)

### Website Backend
- PHP 7.4 atau lebih tinggi
- MySQL 5.7 atau lebih tinggi
- Apache/Nginx web server
- SSL Certificate (HTTPS recommended)

## 🚀 Quick Start

### 1️⃣ Install Aplikasi

**Dari Play Store (Beta):**
```
https://play.google.com/apps/testing/com.notiflistener.app
```

**Atau install manual APK:**
```
build/app/outputs/flutter-apk/app-release.apk
```

### 2️⃣ Setup Website

1. Upload `public_html.zip` ke hosting
2. Extract di folder `public_html` atau `www`
3. Import database (jika ada)
4. Konfigurasi database di `application/config/database.php`
5. Akses admin panel: `https://domainanda.com/admin`

### 3️⃣ Konfigurasi

**Di Aplikasi:**
1. Buka aplikasi NotifListener
2. Menu ⋮ → Pengaturan Server
3. Isi Server URL: `https://domainanda.com/api`
4. Aktifkan Notification Listener
5. Disable Battery Optimization

**Di Website:**
1. Login admin panel
2. Setup QRIS: `/admin/payments/qris_nt/settings`
3. Setup Bank: `/admin/payments/transfer_bank/settings`
4. Setup Rules: `/admin/notif_rules`

## 📖 Dokumentasi Lengkap

- **[PANDUAN_SETUP_TRANSAKSI.md](./PANDUAN_SETUP_TRANSAKSI.md)** - Panduan setup lengkap step-by-step
- **[ANDROID_15_EDGE_TO_EDGE.md](./ANDROID_15_EDGE_TO_EDGE.md)** - Kompatibilitas Android 15
- **[FIX_DUPLICATE_TRANSACTIONS.md](./FIX_DUPLICATE_TRANSACTIONS.md)** - Fix duplikasi transaksi

## 🏗️ Project Structure

```
notiflistener_share/
├── android/                    # Android native code
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/        # Kotlin code (MainActivity, etc)
│   │   │   ├── res/           # Resources (styles, etc)
│   │   │   └── AndroidManifest.xml
│   │   └── build.gradle.kts   # Android build config
│   └── build.gradle.kts       # Project build config
│
├── lib/                        # Flutter Dart code
│   ├── main.dart              # Entry point
│   ├── models/                # Data models
│   │   ├── transaction.dart
│   │   └── notification_rule.dart
│   ├── services/              # Business logic
│   │   ├── notification_service.dart
│   │   ├── transaction_service.dart
│   │   ├── database_helper.dart
│   │   └── rules_manager.dart
│   ├── screens/               # UI screens
│   │   ├── data_transaksi_tab.dart
│   │   ├── trx_qris_tab.dart
│   │   └── settings_screen.dart
│   └── utils/                 # Utilities
│       └── text_extractor.dart
│
├── public_html/               # Website backend (PHP)
│   ├── application/
│   │   ├── controllers/
│   │   │   ├── admin/
│   │   │   │   ├── payments/
│   │   │   │   │   ├── Qris_nt.php
│   │   │   │   │   └── Transfer_bank.php
│   │   │   │   └── Notif_rules.php
│   │   │   └── api/
│   │   │       └── Transaction.php
│   │   ├── models/
│   │   └── views/
│   └── index.php
│
├── build/                     # Build outputs
│   └── app/
│       └── outputs/
│           ├── bundle/        # AAB for Play Store
│           └── flutter-apk/   # APK for manual install
│
├── pubspec.yaml              # Flutter dependencies
├── README.md                 # This file
├── PANDUAN_SETUP_TRANSAKSI.md
├── ANDROID_15_EDGE_TO_EDGE.md
└── FIX_DUPLICATE_TRANSACTIONS.md
```

## 🔧 Development

### Build APK
```bash
flutter build apk --release
```

### Build AAB (Play Store)
```bash
flutter build appbundle --release
```

### Run in Debug Mode
```bash
flutter run
```

### Run in Release Mode
```bash
flutter run --release
```

## 🧪 Testing

### Test Notification Capture
1. Kirim transfer ke rekening yang sudah dikonfigurasi
2. Tunggu notifikasi dari aplikasi bank
3. Check aplikasi NotifListener → Tab "Transaksi"
4. Verify data masuk ke server

### Test QRIS
1. Generate QRIS dari website admin
2. Scan dan bayar menggunakan e-wallet
3. Tunggu notifikasi
4. Check aplikasi NotifListener → Tab "QRIS"
5. Verify data masuk ke server

## 📊 Tech Stack

### Mobile App
- **Framework**: Flutter 3.x
- **Language**: Dart
- **Database**: SQLite (local)
- **State Management**: StatefulWidget
- **Background Service**: flutter_foreground_task
- **Notification**: flutter_notification_listener

### Backend
- **Framework**: CodeIgniter 3.x
- **Language**: PHP 7.4+
- **Database**: MySQL 5.7+
- **API**: RESTful JSON API

## 🔐 Security

- ✅ HTTPS recommended for server communication
- ✅ API authentication with token
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ CSRF protection
- ✅ Secure password hashing

## 🐛 Known Issues & Fixes

### ✅ Fixed Issues
- ✅ **Duplicate transactions** - Fixed with duplicate detection system
- ✅ **Android 15 edge-to-edge** - Implemented edge-to-edge support
- ✅ **Battery optimization** - Added foreground service
- ✅ **Notification missed when screen locked** - Fixed with wakelock

### 🔄 Ongoing
- 🔄 Performance optimization for large transaction lists
- 🔄 UI/UX improvements

## 📝 Changelog

### Version 1.0.0 (2025-12-05)
- ✅ Initial release
- ✅ Multi-bank support
- ✅ QRIS support
- ✅ Background service
- ✅ Auto-retry mechanism
- ✅ Duplicate detection
- ✅ Android 15 compatibility
- ✅ Edge-to-edge display

## 🤝 Contributing

This is a proprietary project. Contact the developer for contribution guidelines.

## 📄 License

Proprietary - All rights reserved

## 👨‍💻 Developer

**Project**: NotifListener  
**Version**: 1.0.0  
**Last Update**: 2025-12-05

## 📞 Support

For support and inquiries:
- Check documentation in project folder
- Review log files for errors
- Contact developer with:
  - Screenshot of error
  - Log file
  - Steps to reproduce

---

## 🎯 Roadmap

### Version 1.1.0 (Planned)
- [ ] Multi-language support (EN/ID)
- [ ] Dark mode
- [ ] Export transactions to Excel
- [ ] Push notification for failed transactions
- [ ] Widget for quick stats

### Version 1.2.0 (Planned)
- [ ] Biometric authentication
- [ ] Transaction categories
- [ ] Advanced filtering
- [ ] Charts and analytics
- [ ] Webhook support

---

**Made with ❤️ using Flutter**
