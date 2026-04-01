import 'dart:async';
import 'dart:js' as js;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> checkLocationPermission() async {
    if (kIsWeb) return true;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<bool> isLocationServiceEnabled() async {
    if (kIsWeb) return true;
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentLocation() async {
    if (kIsWeb) {
      return await _getWebLocation();
    }
    bool hasPermission = await checkLocationPermission();
    if (!hasPermission) return null;
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
    } catch (e) {
      print('getCurrentLocation failed: $e');
      return null;
    }
  }

  Future<Position?> _getWebLocation() async {
    final completer = Completer<Position?>();

    // Set up global callbacks Flutter can call from JS
    js.context['_dartLocationSuccess'] = (lat, lng, accuracy) {
      if (completer.isCompleted) return;
      try {
        final position = Position(
          latitude: (lat as num).toDouble(),
          longitude: (lng as num).toDouble(),
          timestamp: DateTime.now(),
          accuracy: (accuracy as num?)?.toDouble() ?? 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        print('Web location got: ${position.latitude}, ${position.longitude}');
        completer.complete(position);
      } catch (e) {
        print('Location parse error: $e');
        if (!completer.isCompleted) completer.complete(null);
      }
    };

    js.context['_dartLocationError'] = (msg) {
      print('Browser location error: $msg');
      if (!completer.isCompleted) completer.complete(null);
    };

    // Call browser geolocation via eval - simplest reliable approach
    js.context.callMethod('eval', ['''
      navigator.geolocation.getCurrentPosition(
        function(pos) {
          window._dartLocationSuccess(
            pos.coords.latitude,
            pos.coords.longitude,
            pos.coords.accuracy
          );
        },
        function(err) {
          window._dartLocationError(err.message);
        },
        { enableHighAccuracy: false, timeout: 10000, maximumAge: 60000 }
      );
    ''']);

    // Safety timeout
    Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        print('Web geolocation timed out');
        completer.complete(null);
      }
    });

    return completer.future;
  }

  Future<Position?> getLastKnownLocation() async {
    if (kIsWeb) return null;
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  String generateGoogleMapsLink(double latitude, double longitude) {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }
}
