# 🚀 START HERE - Run the SOS Safety App

## ⚡ Quick Run (3 Steps)

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Connect Device
- Connect Android phone via USB (enable USB debugging)
- OR start Android emulator from Android Studio

### Step 3: Run the App
```bash
flutter run
```

---

## 📋 Before Running - Required Setup

### 1. Firebase Setup (Required for Login/Register)

**Option A: Quick Setup**
1. Go to https://console.firebase.google.com/
2. Create new project → Add Android app
3. Package name: `com.sos.safety.app`
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`
6. Run: `flutterfire configure`

**Option B: Skip Firebase (Limited Features)**
- App will work but login/register won't function
- Local features (SOS, contacts) will work

### 2. Google Maps API Key (Optional - for Safe Zones)

1. Get API key from https://console.cloud.google.com/
2. Enable "Maps SDK for Android"
3. Edit `android/app/src/main/AndroidManifest.xml`
4. Replace `YOUR_API_KEY_HERE` with your actual key

---

## 🎯 Final Run Command

```bash
flutter pub get && flutter run
```

**OR step by step:**

```bash
# Install packages
flutter pub get

# Check devices
flutter devices

# Run app
flutter run
```

---

## ✅ Ready to Run?

1. ✅ Flutter installed? → `flutter --version`
2. ✅ Device connected? → `flutter devices`
3. ✅ Dependencies installed? → `flutter pub get`
4. ✅ Firebase configured? (optional)

**Then run:**
```bash
flutter run
```

---

## 🆘 Troubleshooting

**"Flutter not found"**
- Install Flutter: https://flutter.dev/docs/get-started/install
- Add to PATH

**"No devices"**
- Start emulator: Android Studio → AVD Manager
- OR connect phone with USB debugging enabled

**"Firebase error"**
- Add `google-services.json` to `android/app/`
- Run `flutterfire configure`

**"Build failed"**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🎉 That's It!

**Run Command:**
```bash
flutter run
```

The app will launch on your device! 🚀
