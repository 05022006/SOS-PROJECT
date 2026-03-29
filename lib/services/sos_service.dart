import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'emergency_contact_service.dart';
import '../models/emergency_contact.dart';

class SOSService {
  static final SOSService _instance = SOSService._internal();
  factory SOSService() => _instance;
  SOSService._internal();

  final Telephony _telephony = Telephony.instance;
  final LocationService _locationService = LocationService();
  final EmergencyContactService _contactService = EmergencyContactService();
  Timer? _panicTimer;

  // Police helpline number (mock - can be configured)
  static const String policeHelpline = '+91100'; // Replace with actual number

  Future<bool> checkSMSPermission() async {
    final status = await Permission.sms.status;
    if (status.isDenied) {
      final result = await Permission.sms.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  Future<bool> checkPhonePermission() async {
    final status = await Permission.phone.status;
    if (status.isDenied) {
      final result = await Permission.phone.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  Future<void> triggerSOS() async {
    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        // Try last known location
        final lastPosition = await _locationService.getLastKnownLocation();
        if (lastPosition == null) {
          throw Exception('Unable to get location');
        }
        await _sendSOSAlerts(lastPosition);
      } else {
        await _sendSOSAlerts(position);
      }
    } catch (e) {
      throw Exception('SOS trigger failed: $e');
    }
  }

  Future<void> _sendSOSAlerts(Position position) async {
    // Get emergency contacts
    final contacts = await _contactService.getEmergencyContacts();
    
    if (contacts.isEmpty) {
      throw Exception('No emergency contacts found');
    }

    // Generate location message
    final locationLink = _locationService.generateGoogleMapsLink(
      position.latitude,
      position.longitude,
    );
    
    final message = '''
🚨 SOS ALERT 🚨
I need immediate help!
Location: $locationLink
Latitude: ${position.latitude}
Longitude: ${position.longitude}
Time: ${DateTime.now().toString()}
''';

    // Send SMS to all contacts
    await _sendSMS(contacts, message);

    // Call primary contact
    final primaryContact = contacts.firstWhere(
      (c) => c.isPrimary,
      orElse: () => contacts.first,
    );
    await _makePhoneCall(primaryContact.phone);

    // Call police helpline
    await _makePhoneCall(policeHelpline);

    // Send WhatsApp message (if available)
    await _sendWhatsApp(primaryContact.phone, message);
  }

  Future<void> _sendSMS(List<EmergencyContact> contacts, String message) async {
    bool hasPermission = await checkSMSPermission();
    if (!hasPermission) {
      return;
    }

      for (var contact in contacts) {
        try {
          await _telephony.sendSms(
            to: contact.phone,
            message: message,
            statusListener: (SendStatus status) {
              print('SMS status for ${contact.name}: $status');
            },
          );
        } catch (e) {
          // Continue with other contacts even if one fails
          print('Failed to send SMS to ${contact.name}: $e');
        }
      }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    bool hasPermission = await checkPhonePermission();
    if (!hasPermission) {
      return;
    }

    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Failed to make phone call: $e');
    }
  }

  Future<void> _sendWhatsApp(String phoneNumber, String message) async {
    try {
      // Remove + and spaces from phone number
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[+\s]'), '');
      final uri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // WhatsApp not available, continue silently
      print('WhatsApp not available: $e');
    }
  }

  void startPanicDetectionTimer(Function onTrigger) {
    _panicTimer?.cancel();
    _panicTimer = Timer(const Duration(seconds: 10), () {
      onTrigger();
    });
  }

  void cancelPanicDetection() {
    _panicTimer?.cancel();
    _panicTimer = null;
  }

  void dispose() {
    _panicTimer?.cancel();
  }
}
