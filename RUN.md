# Run the SOS Safety App

## Windows: required first step (symlinks)

Flutter needs **symlinks** for plugins. On Windows you **must** do one of these:

1. **Recommended:** Turn on **Developer Mode**  
   - Press `Win + I` → **Privacy & security** → **For developers** → turn **Developer Mode** **On**  
   - Or run: `start ms-settings:developers`  
   - Restart the terminal, then run Flutter again.

2. **Alternative:** Open your terminal **as Administrator** (less ideal).

Until this is done, commands like `flutter run` / `flutter build` can fail with:

> `Building with plugins requires symlink support.`

---

## Install deps (optional: avoids `flutter pub` symlink step during get)

```powershell
cd C:\Users\KLPCADMIN\Desktop\proj
dart pub get
```

For **build/run**, you still need Developer Mode as above.

---

## Run on Android (best for this app — SMS, telephony, location)

1. Connect a phone with **USB debugging**, *or* start an **AVD** in Android Studio.
2. Check the device:

```powershell
cd C:\Users\KLPCADMIN\Desktop\proj
flutter devices
```

3. Run:

```powershell
flutter run
```

If several devices show, pick Android, e.g.:

```powershell
flutter run -d <device_id>
```

**APK after a successful build:**

- Debug: `build\app\outputs\flutter-apk\app-debug.apk`
- Install on phone: copy the APK and open it, or `adb install build\app\outputs\flutter-apk\app-debug.apk`

---

## Run on Windows desktop (after Developer Mode)

Needs **Visual Studio** with **Desktop development with C++** (for the Windows runner toolchain).

```powershell
cd C:\Users\KLPCADMIN\Desktop\proj
flutter run -d windows
```

---

## Run on Chrome (web)

This project uses **Firebase**. Web needs valid options in `lib/firebase_options.dart`:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Then:

```powershell
flutter run -d chrome
```

---

## Firebase / Maps (optional)

- Add **`android/app/google-services.json`** (Firebase Android app).
- Run **`flutterfire configure`** to regenerate `firebase_options.dart`.
- For Google Maps, add your API key in **`android/app/src/main/AndroidManifest.xml`**.

---

## Quick reference

| Goal              | Command / location |
|-------------------|--------------------|
| Android run       | `flutter run` (with device in `flutter devices`) |
| Android debug APK | `flutter build apk --debug` → `build\app\outputs\flutter-apk\app-debug.apk` |
| Windows run       | Developer Mode + VS C++ workload → `flutter run -d windows` |
