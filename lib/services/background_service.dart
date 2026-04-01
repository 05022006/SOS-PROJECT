import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'geofence_service.dart';
import 'panic_detection_service.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  static bool _isInitialized = false;
  static final GeofenceService _geofenceService = GeofenceService();
  static final PanicDetectionService _panicService = PanicDetectionService();

  /// Initialize background service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Request necessary permissions
    await _requestPermissions();

    _isInitialized = true;
  }

  /// Start background monitoring
  static Future<void> startMonitoring() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Start geofence monitoring
    await _geofenceService.startMonitoring();

    // Start panic detection
    await _panicService.startMonitoring();
  }

  /// Stop background monitoring
  static Future<void> stopMonitoring() async {
    _geofenceService.stopMonitoring();
    _panicService.stopMonitoring();
  }

  /// Get monitoring status
  static bool get isGeofenceActive => _geofenceService.isMonitoring;
  static bool get isPanicDetectionActive => _panicService.isMonitoring;
}

/// Request necessary permissions for background service
Future<void> _requestPermissions() async {
  // Location permission
  final locationStatus = await Permission.location.request();

  // Activity recognition (panic detection) on Android only
  PermissionStatus activityStatus = PermissionStatus.denied;
  if (!kIsWeb && Platform.isAndroid) {
    activityStatus = await Permission.activityRecognition.request();
  }

  // Notification permission (for foreground service)
  if (!kIsWeb && Platform.isAndroid) {
    await Permission.notification.request();
  }

  print('Location: ${locationStatus.isDenied ? "Denied" : "Granted"}');
  print('Activity: ${activityStatus.isDenied ? "Denied" : "Granted"}');
}
