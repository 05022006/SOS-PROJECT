# SOS & Geo-Fencing Mobile Application

A comprehensive safety mobile application built with Flutter for women and elderly users. Features one-touch SOS, geo-fencing, panic detection, and emergency contact management.

## 🚀 Features

### Core Features

1. **One-Touch SOS Button**
   - Large, accessible SOS button on home screen
   - Sends SMS with live location to all emergency contacts
   - Auto-calls primary contact and police helpline
   - WhatsApp alert integration (when internet available)

2. **Geo-Fencing Safety Zone**
   - Set multiple safe zones (home, workplace, etc.)
   - Continuous background location monitoring
   - Automatic alerts when user exits safe zones
   - Works even when app is closed

3. **Automatic Panic Detection**
   - Accelerometer-based sudden movement detection
   - Microphone-based loud sound detection
   - 10-second countdown before auto-triggering SOS
   - User can cancel during countdown

4. **Emergency Contacts Management**
   - Add/edit/delete emergency contacts (minimum 3 recommended)
   - Set primary contact
   - Offline-first storage with cloud sync
   - Contact information stored securely

5. **Real-Time Location Sharing**
   - Share Google Maps location links
   - Updates every 30 seconds during emergency
   - Location data only used when needed

6. **Authority Integration**
   - Mock police helpline integration
   - Auto-call during SOS
   - Structure ready for smart city integration

7. **Security & Privacy**
   - Minimal permissions required
   - Location only during emergency or monitoring
   - No data sharing without consent
   - Encrypted data storage

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase account
- Google Maps API key
- Android device/emulator (API 21+)

## 🛠️ Setup Instructions

### 1. Clone and Install Dependencies

```bash
# Navigate to project directory
cd sos_safety_app

# Install Flutter dependencies
flutter pub get
```

### 2. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your Firebase project
3. Download `google-services.json` and place it in `android/app/`
4. Run FlutterFire CLI to configure:
   ```bash
   flutterfire configure
   ```
5. Update `lib/firebase_options.dart` with your Firebase configuration

### 3. Google Maps Setup

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps SDK for Android
   - Geocoding API
3. Add your API key to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
   ```

### 4. Android Configuration

The app requires the following permissions (already configured in `AndroidManifest.xml`):
- Location (Fine & Coarse)
- Background Location
- SMS
- Phone
- Audio Recording
- Internet

### 5. Run the App

```bash
# Run on connected device/emulator
flutter run

# Build release APK
flutter build apk --release
```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── emergency_contact.dart
│   └── safe_zone.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── emergency_contacts_screen.dart
│   ├── add_edit_contact_screen.dart
│   ├── safe_zones_screen.dart
│   ├── add_edit_zone_screen.dart
│   └── settings_screen.dart
└── services/                 # Business logic
    ├── auth_service.dart
    ├── location_service.dart
    ├── sos_service.dart
    ├── emergency_contact_service.dart
    ├── safe_zone_service.dart
    ├── geofence_service.dart
    ├── panic_detection_service.dart
    └── background_service.dart
```

## 🔧 Configuration

### Police Helpline Number

Update the police helpline number in `lib/services/sos_service.dart`:
```dart
static const String policeHelpline = '+91100'; // Replace with actual number
```

### Geo-Fence Settings

Default radius: 100 meters (configurable per zone)
Update interval: Every 10 meters of movement

### Panic Detection Thresholds

- Acceleration threshold: 15.0 m/s²
- Sound threshold: 80 dB (placeholder - requires audio processing)
- Countdown: 10 seconds

## 🧪 Testing

### Test SOS Feature
1. Add at least 3 emergency contacts
2. Grant all required permissions
3. Tap the SOS button
4. Confirm alert sending

### Test Geo-Fencing
1. Add a safe zone at your current location
2. Enable geo-fence monitoring in settings
3. Move outside the safe zone radius
4. Check for alert messages

### Test Panic Detection
1. Enable panic detection in settings
2. Simulate sudden movement or loud sound
3. Wait for 10-second countdown
4. Cancel or let it trigger SOS

## 📸 Screenshots

The app includes the following screens:
1. **Splash Screen** - App loading screen
2. **Login/Register** - User authentication
3. **Home Screen** - Main SOS button and quick actions
4. **Emergency Contacts** - Manage emergency contacts
5. **Safe Zones** - Configure geo-fence zones
6. **Settings** - App configuration and preferences

## 🔒 Privacy & Security

- **Location Data**: Only collected during emergencies or when geo-fencing is active
- **Data Storage**: Local storage with optional cloud sync
- **Permissions**: Minimal permissions requested, only when needed
- **Encryption**: All sensitive data encrypted at rest
- **User Control**: Users can disable features at any time

## 🚧 Future Enhancements

1. **Smart City Integration**
   - Direct integration with local police systems
   - Real-time emergency response coordination
   - Automated dispatch system

2. **Advanced Features**
   - Voice commands for SOS activation
   - AI-powered threat detection
   - Community safety network
   - Emergency response time tracking

3. **Platform Expansion**
   - iOS support
   - Web dashboard for emergency contacts
   - Wearable device integration

4. **Analytics & Reporting**
   - Safety incident reports
   - Location history (opt-in)
   - Emergency response analytics

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⚠️ Important Notes

- **Emergency Services**: This app is a tool to assist in emergencies but does not replace official emergency services
- **Testing**: Always test in a safe environment before relying on the app
- **Permissions**: Grant all required permissions for full functionality
- **Battery**: Background monitoring may impact battery life
- **Internet**: Some features require internet, but core SOS works offline

## 📞 Support

For issues, questions, or contributions, please open an issue on the project repository.

## 🙏 Acknowledgments

Built with:
- Flutter - UI Framework
- Firebase - Backend Services
- Google Maps - Location Services
- Material Design - UI Components

---

**Stay Safe!** 🛡️
