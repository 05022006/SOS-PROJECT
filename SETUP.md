# Detailed Setup Guide

## Step-by-Step Installation

### 1. Environment Setup

#### Install Flutter
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install
# Extract and add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Install Android Studio
1. Download from https://developer.android.com/studio
2. Install Android SDK (API 21+)
3. Configure Android emulator or connect physical device

### 2. Project Setup

```bash
# Clone or navigate to project
cd sos_safety_app

# Get dependencies
flutter pub get

# Verify setup
flutter doctor -v
```

### 3. Firebase Configuration

#### Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add Project"
3. Enter project name: "SOS Safety App"
4. Enable Google Analytics (optional)

#### Add Android App
1. In Firebase Console, click "Add App" → Android
2. Package name: `com.sos.safety.app`
3. Download `google-services.json`
4. Place in `android/app/` directory

#### Configure FlutterFire
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure

# Select your Firebase project
# Select Android platform
# This will update firebase_options.dart
```

#### Enable Firebase Services
1. Go to Firebase Console → Authentication
2. Enable "Email/Password" sign-in method
3. Go to Firestore Database
4. Create database in "Test mode" (for development)
5. Set up security rules (see below)

#### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /emergency_contacts/{contactId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /safe_zones/{zoneId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 4. Google Maps Setup

#### Get API Key
1. Go to https://console.cloud.google.com/
2. Create new project or select existing
3. Enable APIs:
   - Maps SDK for Android
   - Geocoding API
   - Places API (optional)
4. Create credentials → API Key
5. Restrict API key to Android apps (recommended)

#### Add to AndroidManifest.xml
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    ...
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>
</application>
```

### 5. Android Permissions

All permissions are already configured in `AndroidManifest.xml`. The app will request them at runtime:

- **Location**: Required for SOS and geo-fencing
- **SMS**: Required to send emergency alerts
- **Phone**: Required to make emergency calls
- **Audio**: Required for panic detection
- **Background Location**: Required for geo-fencing when app is closed

### 6. Build Configuration

#### Update build.gradle
The `android/app/build.gradle` is already configured. Verify:
- `minSdkVersion 21` (Android 5.0+)
- `targetSdkVersion 34`
- `compileSdkVersion 34`

#### Signing Configuration (for release)
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/keystore.jks
```

Update `android/app/build.gradle` signing configs for release builds.

### 7. Run the App

```bash
# Check connected devices
flutter devices

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### 8. Testing Checklist

- [ ] App launches successfully
- [ ] User can register/login
- [ ] Can add emergency contacts (minimum 3)
- [ ] Can add safe zones
- [ ] SOS button triggers alerts
- [ ] Geo-fencing detects zone exit
- [ ] Panic detection works (test carefully)
- [ ] Background services run when app is closed
- [ ] Location sharing works
- [ ] Settings can be changed

### 9. Troubleshooting

#### Firebase Issues
- Verify `google-services.json` is in correct location
- Check Firebase project settings
- Ensure Authentication is enabled
- Verify Firestore rules

#### Google Maps Issues
- Verify API key is correct
- Check API restrictions
- Ensure Maps SDK is enabled
- Check billing is enabled (if required)

#### Permission Issues
- Grant all permissions manually in device settings
- Check Android version compatibility
- Verify `AndroidManifest.xml` permissions

#### Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter run

# Check for errors
flutter analyze
flutter doctor -v
```

### 10. Production Deployment

#### Before Release
1. Update `pubspec.yaml` version
2. Configure release signing
3. Test all features thoroughly
4. Update Firebase security rules
5. Set up production Firebase project
6. Configure Google Maps API restrictions
7. Test on multiple devices/Android versions

#### Play Store Submission
1. Build release app bundle: `flutter build appbundle --release`
2. Create Play Store listing
3. Upload app bundle
4. Fill in store listing details
5. Submit for review

---

For additional help, refer to:
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Documentation](https://developers.google.com/maps/documentation)
