# 📱 Panduan Publish ke Google Play Store

## ✅ Checklist Persiapan

### 1. **App Information & Branding**
- [ ] **App Name**: "NotifListener" atau nama yang Anda inginkan
- [ ] **Short Description**: Max 80 karakter
- [ ] **Full Description**: Jelaskan fungsi app dengan detail
- [ ] **App Icon**: 512x512 px, PNG format (sudah ada: `notiflistener.png`)
- [ ] **Feature Graphic**: 1024x500 px untuk Play Store listing
- [ ] **Screenshots**: Minimal 2 screenshot (phone & tablet jika support)
- [ ] **Privacy Policy URL**: WAJIB jika app mengakses data sensitif

### 2. **Permissions & Privacy**

#### ⚠️ PENTING - Notification Listener Permission
App ini menggunakan **Notification Listener Service** yang merupakan **sensitive permission**. Google Play Store memiliki requirement khusus:

**Requirements:**
1. ✅ **Declare in Manifest** (sudah ada di `AndroidManifest.xml`)
2. ✅ **Privacy Policy**: WAJIB ada dan harus explain:
   - Kenapa app butuh akses notifikasi
   - Data apa yang dikumpulkan dari notifikasi
   - Bagaimana data disimpan dan digunakan
   - Apakah data dibagikan ke pihak ketiga
3. ✅ **Data Safety Form**: Isi dengan jujur di Play Console
4. ✅ **Prominent Disclosure**: Jelaskan ke user SEBELUM minta permission

#### Privacy Policy Template (Contoh):
```
KEBIJAKAN PRIVASI - NotifListener

1. Pengumpulan Data
   - Aplikasi ini mengakses notifikasi untuk memproses transaksi perbankan
   - Data yang dikumpulkan: isi notifikasi, nama bank, jumlah transaksi
   
2. Penggunaan Data
   - Data digunakan untuk mencatat transaksi dan mengirim ke server Anda
   - Data disimpan lokal di device dan di server yang Anda konfigurasi
   
3. Keamanan
   - Data tidak dibagikan ke pihak ketiga
   - Koneksi ke server menggunakan HTTPS
   
4. Hak User
   - User dapat menghapus data kapan saja
   - User dapat mencabut akses notifikasi dari Settings
```

### 3. **App Signing & Build**

#### Generate Keystore (Jika belum ada):
```bash
keytool -genkey -v -keystore notiflistener-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias notiflistener
```

#### Update `android/key.properties`:
```properties
storePassword=<password-anda>
keyPassword=<password-anda>
keyAlias=notiflistener
storeFile=<path-to-keystore>/notiflistener-release.jks
```

#### Build Release APK/AAB:
```bash
# AAB (recommended untuk Play Store)
flutter build appbundle --release

# APK (untuk testing)
flutter build apk --release
```

### 4. **Version & Build Number**

Update di `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: major.minor.patch+buildNumber
```

Untuk update selanjutnya, increment build number:
```yaml
version: 1.0.1+2
version: 1.1.0+3
# dst...
```

### 5. **Target API Level**

Google Play Store requirements (2024):
- **Target SDK**: Minimum API 33 (Android 13)
- **Compile SDK**: API 34 (Android 14) recommended

Check di `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 6. **App Content Rating**

Di Play Console, isi questionnaire untuk rating:
- Pilih kategori yang sesuai
- Untuk app finansial, biasanya rated "Everyone" atau "Teen"

### 7. **Testing**

#### Internal Testing:
1. Upload AAB ke Internal Testing track
2. Invite tester (bisa pakai email sendiri)
3. Test minimal 14 hari sebelum production

#### Closed Testing (Optional):
- Invite limited users untuk testing
- Kumpulkan feedback

### 8. **Play Store Listing**

#### Required Assets:
- [x] App Icon (512x512)
- [ ] Feature Graphic (1024x500)
- [ ] Screenshots (min 2, max 8)
  - Phone: 320-3840 px (width/height)
  - Tablet (optional): 1200-7680 px

#### Description Tips:
```
📱 NotifListener - Monitor Transaksi Otomatis

Aplikasi untuk memantau dan mencatat transaksi perbankan secara otomatis 
melalui notifikasi SMS/app banking.

✨ Fitur Utama:
• Deteksi otomatis notifikasi transaksi
• Kirim data ke server custom Anda
• Konfigurasi URL server tanpa rebuild app
• Support multiple bank
• Retry otomatis jika gagal

🔒 Keamanan:
• Data hanya dikirim ke server yang Anda tentukan
• Tidak ada pihak ketiga yang mengakses data
• Koneksi HTTPS terenkripsi

⚙️ Mudah Dikonfigurasi:
• Set URL server dari dalam app
• Atur rules untuk setiap bank
• Monitor transaksi real-time
```

---

## 🚨 CRITICAL - Notification Listener Declaration

Google akan **REJECT** app jika tidak ada penjelasan yang jelas tentang penggunaan Notification Listener.

### Yang Harus Dilakukan:

1. **Di Play Console - Data Safety Section**:
   - Declare bahwa app mengakses notifications
   - Explain purpose: "To process banking transaction notifications"
   - Declare data sharing: "Data sent to user's configured server"

2. **Di App - Prominent Disclosure**:
   ✅ Sudah ada di app (saat user enable notification listener)
   
3. **Privacy Policy**:
   ⚠️ WAJIB upload ke website dan link di Play Console

---

## 📋 Step-by-Step Publish

### 1. Persiapan
```bash
# Clean build
flutter clean
flutter pub get

# Build release AAB
flutter build appbundle --release
```

### 2. Upload ke Play Console
1. Login ke [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill app details
4. Upload AAB di "Internal Testing" atau "Production"

### 3. Fill Required Forms
- **App content**: Content rating, target audience, etc.
- **Data safety**: Declare data collection & sharing
- **Privacy policy**: Add URL
- **App access**: Explain if need special access

### 4. Submit for Review
- Review bisa 1-7 hari
- Jika ditolak, baca rejection reason dan fix

---

## ⚠️ Potential Issues & Solutions

### Issue 1: "Notification Listener not properly declared"
**Solution**: 
- Add detailed explanation in Data Safety form
- Provide Privacy Policy
- Add in-app disclosure before requesting permission

### Issue 2: "Missing Privacy Policy"
**Solution**:
- Create simple HTML page
- Upload ke GitHub Pages / hosting
- Link di Play Console

### Issue 3: "App crashes on startup"
**Solution**:
- Test di multiple devices
- Check ProGuard rules jika pakai obfuscation
- Add crash reporting (Firebase Crashlytics)

### Issue 4: "Target API level too low"
**Solution**:
- Update `targetSdkVersion` to 33+
- Test compatibility

---

## 🔧 Recommended Additions (Optional)

### 1. Crash Reporting
```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

### 2. Analytics
```yaml
dependencies:
  firebase_analytics: ^10.7.0
```

### 3. In-App Updates
```yaml
dependencies:
  in_app_update: ^4.2.2
```

---

## 📞 Support & Resources

- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Notification Listener Policy](https://support.google.com/googleplay/android-developer/answer/9888170)
- [Data Safety Guide](https://support.google.com/googleplay/android-developer/answer/10787469)

---

## ✅ Final Checklist Before Submit

- [ ] App tested on multiple devices
- [ ] No crashes or critical bugs
- [ ] Privacy Policy uploaded and linked
- [ ] Data Safety form filled completely
- [ ] Screenshots uploaded (min 2)
- [ ] Feature graphic uploaded
- [ ] App description clear and complete
- [ ] Content rating completed
- [ ] Notification Listener usage explained
- [ ] AAB signed with release keystore
- [ ] Version number correct

---

**Good luck dengan publish ke Play Store! 🚀**
