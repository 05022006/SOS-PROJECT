import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'twilio_service.dart';
import 'location_service.dart';
import 'emergency_contact_service.dart';
import '../models/emergency_contact.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  if (kIsWeb) return true; // handled by Twilio on web
    final status = await Permission.sms.status;
    if (status.isDenied) {
      final result = await Permission.sms.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  Future<bool> checkPhonePermission() async {
  if (kIsWeb) return false; // phone calls not supported on web
    final status = await Permission.phone.status;
    if (status.isDenied) {
      final result = await Permission.phone.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

Future<void> triggerSOS() async {
  try {
    final position = await _locationService.getCurrentLocation();
    await _sendSOSAlerts(position); // pass null if no location
  } catch (e) {
    throw Exception('SOS trigger failed: $e');
  }
}

// Change signature to accept nullable position
Future<void> _sendSOSAlerts(Position? position) async {
  final contacts = await _contactService.getEmergencyContacts();

  if (contacts.isEmpty) {
    throw Exception('No emergency contacts found');
  }

  // Build message with or without location
  String message;
  if (position != null) {
    final locationLink = _locationService.generateGoogleMapsLink(
      position.latitude,
      position.longitude,
    );
  message = 'SOS! I am in danger.Please help immediately!😭. Location: $locationLink';
  } else {
  message = 'SOS! I am in danger.Please help immediately!😭';
    }

  await _sendSMS(contacts, message);

  final primaryContact = contacts.firstWhere(
    (c) => c.isPrimary,
    orElse: () => contacts.first,
  );
  await _makePhoneCall(primaryContact.phone);
  await _makePhoneCall(policeHelpline);

  if (position != null) {
    await _sendWhatsApp(primaryContact.phone, message);
  }
}

Future<void> _sendSMS(List<EmergencyContact> contacts, String message) async {
  final twilio = TwilioService();
  
  for (var contact in contacts) {
    final success = await twilio.sendSMS(
      to: contact.phone,
      message: message,
    );
    print('SMS to ${contact.name} (${contact.phone}): ${success ? "sent" : "failed"}');
  }
}


  Future<void> _makePhoneCall(String phoneNumber) async {
  if (kIsWeb) return; // phone calls not supported on web
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
  if (kIsWeb) return; // skip on web to avoid errors
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
