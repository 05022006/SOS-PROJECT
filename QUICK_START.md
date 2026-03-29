# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code
- Firebase account
- Google Cloud account (for Maps)

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Firebase Setup (5 min)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project
3. Add Android app (package: `com.sos.safety.app`)
4. Download `google-services.json`
5. Place in `android/app/` folder
6. Run: `flutterfire configure`

### Step 3: Google Maps Setup (3 min)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable "Maps SDK for Android"
3. Create API key
4. Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_KEY_HERE"/>
   ```

### Step 4: Run App
```bash
flutter run
```

### Step 5: First Use
1. Register new account
2. Add 3+ emergency contacts
3. Create a safe zone
4. Test SOS button

## ⚡ Quick Commands

```bash
# Run app
flutter run

# Build APK
flutter build apk --release

# Check for issues
flutter analyze

# Clean build
flutter clean && flutter pub get
```

## 🔑 Important Files

- **Firebase Config**: `lib/firebase_options.dart`
- **Police Number**: `lib/services/sos_service.dart` (line 20)
- **Maps API Key**: `android/app/src/main/AndroidManifest.xml`

## 📱 First Test

1. Launch app
2. Register account
3. Add emergency contact (your own number for testing)
4. Grant all permissions
5. Tap SOS button
6. Check SMS received

## ⚠️ Common Issues

**Firebase not working?**
- Check `google-services.json` location
- Verify Firebase project settings
- Run `flutterfire configure`

**Maps not showing?**
- Verify API key in AndroidManifest.xml
- Check API is enabled in Google Cloud
- Ensure billing is enabled

**Permissions denied?**
- Grant manually in device settings
- Check AndroidManifest.xml has permissions

**Build errors?**
```bash
flutter clean
flutter pub get
flutter run
```

## 🎯 Next Steps

1. ✅ Complete setup above
2. ✅ Test all features
3. ✅ Add real emergency contacts
4. ✅ Configure safe zones
5. ✅ Test in real scenarios (safely!)

---

**Need help?** Check README.md or SETUP.md for detailed instructions.
