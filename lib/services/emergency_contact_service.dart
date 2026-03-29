import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/emergency_contact.dart';
import 'auth_service.dart';

class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  static const String _localStorageKey = 'emergency_contacts';

  String? get _userId => _authService.currentUser?.uid;

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    // Try to get from local storage first (offline-first)
    List<EmergencyContact> localContacts = await _getLocalContacts();
    
    if (_userId == null) {
      return localContacts;
    }

    try {
      // Try to sync from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('emergency_contacts')
          .get();

      List<EmergencyContact> contacts = snapshot.docs
          .map((doc) => EmergencyContact.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();

      // Update local storage
      await _saveLocalContacts(contacts);
      return contacts;
    } catch (e) {
      // If sync fails, return local contacts
      return localContacts;
    }
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Add to Firestore
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('emergency_contacts')
          .add(contact.toMap());

      // Update local storage
      List<EmergencyContact> contacts = await getEmergencyContacts();
      contacts.add(contact.copyWith(id: docRef.id));
      await _saveLocalContacts(contacts);
    } catch (e) {
      // If Firestore fails, save locally only
      List<EmergencyContact> contacts = await _getLocalContacts();
      contacts.add(contact);
      await _saveLocalContacts(contacts);
      throw Exception('Failed to sync, saved locally: $e');
    }
  }

  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    if (_userId == null || contact.id == null) {
      throw Exception('Invalid contact or user not authenticated');
    }

    try {
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('emergency_contacts')
          .doc(contact.id)
          .update(contact.toMap());

      // Update local storage
      List<EmergencyContact> contacts = await _getLocalContacts();
      int index = contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        contacts[index] = contact;
        await _saveLocalContacts(contacts);
      }
    } catch (e) {
      // If Firestore fails, update locally only
      List<EmergencyContact> contacts = await _getLocalContacts();
      int index = contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        contacts[index] = contact;
        await _saveLocalContacts(contacts);
      }
      throw Exception('Failed to sync, updated locally: $e');
    }
  }

  Future<void> deleteEmergencyContact(String contactId) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('emergency_contacts')
          .doc(contactId)
          .delete();

      // Update local storage
      List<EmergencyContact> contacts = await _getLocalContacts();
      contacts.removeWhere((c) => c.id == contactId);
      await _saveLocalContacts(contacts);
    } catch (e) {
      // If Firestore fails, delete locally only
      List<EmergencyContact> contacts = await _getLocalContacts();
      contacts.removeWhere((c) => c.id == contactId);
      await _saveLocalContacts(contacts);
      throw Exception('Failed to sync, deleted locally: $e');
    }
  }

  Future<void> _saveLocalContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((c) => jsonEncode(c.toMap())).toList();
    await prefs.setStringList(_localStorageKey, jsonList);
  }

  Future<List<EmergencyContact>> _getLocalContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_localStorageKey) ?? [];
    return jsonList
        .map((json) => EmergencyContact.fromMap(jsonDecode(json)))
        .toList();
  }
}
