# Flutter Installation Guide for Windows

## 🚀 Step-by-Step Installation

### Step 1: Download Flutter SDK

1. **Go to Flutter website:**
   - Visit: https://docs.flutter.dev/get-started/install/windows
   - OR direct download: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip

2. **Extract Flutter:**
   - Extract the zip file to: `C:\src\flutter`
   - ⚠️ **Important:** Do NOT install Flutter in paths with spaces or special characters
   - ✅ Good: `C:\src\flutter`
   - ❌ Bad: `C:\Program Files\flutter` or `C:\Users\Your Name\flutter`

### Step 2: Add Flutter to PATH

**Method A: Using System Properties (Recommended)**

1. Press `Windows + R`
2. Type: `sysdm.cpl` and press Enter
3. Click "Environment Variables"
4. Under "User variables", find "Path" and click "Edit"
5. Click "New"
6. Add: `C:\src\flutter\bin`
7. Click "OK" on all dialogs
8. **Close and reopen your terminal/command prompt**

**Method B: Using PowerShell (Current Session Only)**

```powershell
$env:Path += ";C:\src\flutter\bin"
```

### Step 3: Verify Installation

Open a **NEW** terminal/PowerShell window and run:

```bash
flutter --version
```

**Expected Output:**
```
Flutter 3.24.5 • channel stable • https://github.com/flutter/flutter.git
Framework • revision xxxxxx
Engine • revision xxxxxx
Tools • Dart 3.x.x • DevTools 2.x.x
```

### Step 4: Install Android Studio (Required for Android Development)

1. **Download Android Studio:**
   - Visit: https://developer.android.com/studio
   - Download and install

2. **Install Android SDK:**
   - Open Android Studio
   - Go to: Tools → SDK Manager
   - Install: Android SDK Platform-Tools, Android SDK Build-Tools
   - Install at least Android SDK Platform 33 (API 33)

3. **Accept Android Licenses:**
   ```bash
   flutter doctor --android-licenses
   ```
   Type `y` for each license

### Step 5: Run Flutter Doctor

```bash
flutter doctor
```

This checks your setup. You should see checkmarks (✓) for:
- Flutter
- Android toolchain
- Android Studio
- VS Code (if installed)

### Step 6: Install Project Dependencies

```bash
# Navigate to project
cd C:\Users\KLPCADMIN\Desktop\proj

# Install dependencies
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in sos_safety_app...
Resolving dependencies...
  firebase_core 2.24.2
  firebase_auth 4.15.3
  cloud_firestore 4.13.6
  ... (many packages)
Got dependencies!
```

### Step 7: Check for Devices

```bash
flutter devices
```

**If using Emulator:**
- Open Android Studio
- Tools → Device Manager
- Create Virtual Device (if none)
- Start emulator
- Run `flutter devices` again

**If using Physical Device:**
- Enable USB Debugging on phone
- Connect via USB
- Run `flutter devices`

---

## ⚡ Quick Installation (Using Git - If Git is Installed)

```bash
# Install to C:\src
cd C:\src
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (then restart terminal)
# Edit PATH in System Environment Variables
# Add: C:\src\flutter\bin

# Verify
flutter --version
```

---

## 📋 Installation Checklist

- [ ] Flutter SDK downloaded and extracted
- [ ] Flutter added to PATH
- [ ] Terminal restarted
- [ ] `flutter --version` works
- [ ] Android Studio installed
- [ ] Android SDK installed
- [ ] `flutter doctor` shows no major issues
- [ ] `flutter pub get` completes successfully
- [ ] Device/emulator connected (`flutter devices`)

---

## 🔧 Troubleshooting

### "Flutter command not found"
- ✅ Make sure Flutter is in PATH
- ✅ Close and reopen terminal
- ✅ Verify path: `C:\src\flutter\bin` exists

### "Android licenses not accepted"
```bash
flutter doctor --android-licenses
```

### "No devices found"
- Start Android emulator OR
- Connect Android phone with USB debugging enabled

### "Pub get failed"
- Check internet connection
- Run `flutter clean` then `flutter pub get`

---

## ✅ After Installation

Once Flutter is installed, run:

```bash
# Navigate to project
cd C:\Users\KLPCADMIN\Desktop\proj

# Install dependencies
flutter pub get

# Check devices
flutter devices

# Run app
flutter run
```

---

## 🎯 Quick Command Reference

```bash
# Check Flutter version
flutter --version

# Check setup
flutter doctor

# Install dependencies
flutter pub get

# List devices
flutter devices

# Run app
flutter run
```

---

**Installation Time:** ~15-30 minutes (depending on internet speed)

**Need Help?** Visit: https://docs.flutter.dev/get-started/install/windows
