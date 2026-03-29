import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'location_service.dart';
import 'sos_service.dart';
import 'emergency_contact_service.dart';
import '../models/safe_zone.dart';
import 'safe_zone_service.dart';

class GeofenceService {
  static final GeofenceService _instance = GeofenceService._internal();
  factory GeofenceService() => _instance;
  GeofenceService._internal();

  final LocationService _locationService = LocationService();
  final SafeZoneService _safeZoneService = SafeZoneService();
  final SOSService _sosService = SOSService();
  StreamSubscription<Position>? _locationSubscription;
  bool _isMonitoring = false;
  List<SafeZone> _activeZones = [];

  bool get isMonitoring => _isMonitoring;

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _activeZones = await _safeZoneService.getActiveSafeZones();

    if (_activeZones.isEmpty) {
      _isMonitoring = false;
      return;
    }

    _locationSubscription = _locationService.getLocationStream().listen(
      (position) {
        _checkGeofenceStatus(position);
      },
      onError: (error) {
        print('Location stream error: $error');
      },
    );
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _checkGeofenceStatus(Position currentPosition) async {
    for (var zone in _activeZones) {
      double distance = _locationService.calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        zone.latitude,
        zone.longitude,
      );

      // If user is outside the safe zone
      if (distance > zone.radius) {
        await _handleZoneExit(zone, currentPosition);
      }
    }
  }

  Future<void> _handleZoneExit(SafeZone zone, Position position) async {
    try {
      final locationLink = _locationService.generateGoogleMapsLink(
        position.latitude,
        position.longitude,
      );

      final message = '''
⚠️ GEO-FENCE ALERT ⚠️
I have left the safe zone: ${zone.name}
Current Location: $locationLink
Latitude: ${position.latitude}
Longitude: ${position.longitude}
Time: ${DateTime.now().toString()}
''';

      // Send alert to emergency contacts
      final contactService = EmergencyContactService();
      final contacts = await contactService.getEmergencyContacts();

      for (var contact in contacts) {
        try {
          // Send SMS
          final telephony = Telephony.instance;
          await telephony.sendSms(
            to: contact.phone,
            message: message,
            statusListener: (SendStatus status) {
              print('Geofence alert SMS status: $status');
            },
          );
        } catch (e) {
          print('Failed to send geofence alert: $e');
        }
      }
    } catch (e) {
      print('Error handling zone exit: $e');
    }
  }

  Future<void> refreshZones() async {
    _activeZones = await _safeZoneService.getActiveSafeZones();
  }

  void dispose() {
    stopMonitoring();
  }
}
