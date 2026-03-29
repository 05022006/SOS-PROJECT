import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/safe_zone.dart';
import 'auth_service.dart';

class SafeZoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  static const String _localStorageKey = 'safe_zones';

  String? get _userId => _authService.currentUser?.uid;

  Future<List<SafeZone>> getSafeZones() async {
    // Try to get from local storage first (offline-first)
    List<SafeZone> localZones = await _getLocalZones();

    if (_userId == null) {
      return localZones;
    }

    try {
      // Try to sync from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('safe_zones')
          .get();

      List<SafeZone> zones = snapshot.docs
          .map((doc) => SafeZone.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();

      // Update local storage
      await _saveLocalZones(zones);
      return zones;
    } catch (e) {
      // If sync fails, return local zones
      return localZones;
    }
  }

  Future<List<SafeZone>> getActiveSafeZones() async {
    List<SafeZone> zones = await getSafeZones();
    return zones.where((zone) => zone.isActive).toList();
  }

  Future<void> addSafeZone(SafeZone zone) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Add to Firestore
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('safe_zones')
          .add(zone.toMap());

      // Update local storage
      List<SafeZone> zones = await getSafeZones();
      zones.add(zone.copyWith(id: docRef.id));
      await _saveLocalZones(zones);
    } catch (e) {
      // If Firestore fails, save locally only
      List<SafeZone> zones = await _getLocalZones();
      zones.add(zone);
      await _saveLocalZones(zones);
      throw Exception('Failed to sync, saved locally: $e');
    }
  }

  Future<void> updateSafeZone(SafeZone zone) async {
    if (_userId == null || zone.id == null) {
      throw Exception('Invalid zone or user not authenticated');
    }

    try {
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('safe_zones')
          .doc(zone.id)
          .update(zone.toMap());

      // Update local storage
      List<SafeZone> zones = await _getLocalZones();
      int index = zones.indexWhere((z) => z.id == zone.id);
      if (index != -1) {
        zones[index] = zone;
        await _saveLocalZones(zones);
      }
    } catch (e) {
      // If Firestore fails, update locally only
      List<SafeZone> zones = await _getLocalZones();
      int index = zones.indexWhere((z) => z.id == zone.id);
      if (index != -1) {
        zones[index] = zone;
        await _saveLocalZones(zones);
      }
      throw Exception('Failed to sync, updated locally: $e');
    }
  }

  Future<void> deleteSafeZone(String zoneId) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('safe_zones')
          .doc(zoneId)
          .delete();

      // Update local storage
      List<SafeZone> zones = await _getLocalZones();
      zones.removeWhere((z) => z.id == zoneId);
      await _saveLocalZones(zones);
    } catch (e) {
      // If Firestore fails, delete locally only
      List<SafeZone> zones = await _getLocalZones();
      zones.removeWhere((z) => z.id == zoneId);
      await _saveLocalZones(zones);
      throw Exception('Failed to sync, deleted locally: $e');
    }
  }

  Future<void> _saveLocalZones(List<SafeZone> zones) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = zones.map((z) => jsonEncode(z.toMap())).toList();
    await prefs.setStringList(_localStorageKey, jsonList);
  }

  Future<List<SafeZone>> _getLocalZones() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_localStorageKey) ?? [];
    return jsonList
        .map((json) => SafeZone.fromMap(jsonDecode(json)))
        .toList();
  }
}
