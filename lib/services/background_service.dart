import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:workmanager/workmanager.dart';
import 'geofence_service.dart';
import 'panic_detection_service.dart';

class BackgroundService {
  static const String taskName = 'sosBackgroundTask';
  static final GeofenceService _geofenceService = GeofenceService();
  static final PanicDetectionService _panicService = PanicDetectionService();

  static Future<void> initialize() async {
    // Initialize Flutter Background Service
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'sos_safety_channel',
        initialNotificationTitle: 'SOS Safety App',
        initialNotificationContent: 'Safety monitoring is active',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    // Initialize WorkManager for periodic tasks
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic task (runs every 15 minutes)
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Start geofence monitoring
    await _geofenceService.startMonitoring();
    
    // Start panic detection
    await _panicService.startMonitoring();

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    await _geofenceService.startMonitoring();
    await _panicService.startMonitoring();
    return true;
  }

  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      // Periodic background task
      await _geofenceService.refreshZones();
      return Future.value(true);
    });
  }

  static Future<void> startMonitoring() async {
    await _geofenceService.startMonitoring();
    await _panicService.startMonitoring();
  }

  static Future<void> stopMonitoring() async {
    _geofenceService.stopMonitoring();
    _panicService.stopMonitoring();
  }
}
