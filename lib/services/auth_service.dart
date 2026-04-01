import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../firebase_options.dart';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  static bool firebaseAvailable = false;

  static const String _localUsersKey = 'local_auth_users';
  static const String _localCurrentUid = 'local_auth_current_uid';

  bool get _isFirebaseConfigured {
    final options = DefaultFirebaseOptions.currentPlatform;
    return options.apiKey != 'YOUR_API_KEY' &&
        options.appId != 'YOUR_APP_ID' &&
        options.projectId != 'YOUR_PROJECT_ID';
  }

  bool _firebaseAvailable = false;

  bool get isFirebaseAvailable => _firebaseAvailable;

  void _initFirebase() {
    if (!_isFirebaseConfigured) {
      _firebaseAvailable = false;
      AuthService.firebaseAvailable = false;
      return;
    }

    if (_auth != null && _firestore != null && _firebaseAvailable) return;

    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _firebaseAvailable = true;
    } catch (e) {
      _firebaseAvailable = false;
      print('Firebase init failed, using local mode: $e');
    }

    AuthService.firebaseAvailable = _firebaseAvailable;
  }

  Future<UserModel?> get currentUser async {
    _initFirebase();
    if (_firebaseAvailable) {
      final user = _auth?.currentUser;
      if (user == null) return null;
      return await _getUserData(user.uid);
    }

    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_localCurrentUid);
    if (uid == null) return null;
    final users = await _getLocalUsers();
    final matched = users.where((u) => u.uid == uid);
    return matched.isEmpty ? null : matched.first;
  }

  Stream<User?> get authStateChanges {
    _initFirebase();
    if (!_firebaseAvailable) return const Stream.empty();
    return _auth!.authStateChanges();
  }

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    _initFirebase();
    if (_firebaseAvailable) {
      try {
        UserCredential result = await _auth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final userModel = await _getUserData(result.user!.uid);
        if (userModel != null) {
          return userModel;
        }
        throw Exception('Firebase user data not found.');
      } catch (e) {
        throw Exception('Sign in failed: $e');
      }
    } else {
      final users = await _getLocalUsers();
      final matched = users.where((u) =>
          u.email == email &&
          u is _LocalUserModel &&
          (u as _LocalUserModel).password == password);
      if (matched.isEmpty) {
        throw Exception('Sign in failed: incorrect email or password (local mode).');
      }
      final matchedUser = matched.first as _LocalUserModel;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localCurrentUid, matchedUser.uid);
      return matchedUser;
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    _initFirebase();
    if (_firebaseAvailable) {
      try {
        UserCredential result = await _auth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        UserModel userModel = UserModel(
          uid: result.user!.uid,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
        );

        await _firestore!.collection('users').doc(result.user!.uid).set(userModel.toMap());
        return userModel;
      } catch (e) {
        throw Exception('Registration failed: $e');
      }
    } else {
      final users = await _getLocalUsers();
      if (users.any((u) => u.email == email)) {
        throw Exception('Registration failed: email already exists (local mode).');
      }

      final uid = DateTime.now().millisecondsSinceEpoch.toString();
      final localUser = _LocalUserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        password: password,
      );

      users.add(localUser);
      await _setLocalUsers(users);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localCurrentUid, uid);

      return localUser;
    }
  }

  Future<UserModel?> _getUserData(String uid) async {
    if (_firebaseAvailable) {
      try {
        final doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        return null;
      }
    } else {
      final users = await _getLocalUsers();
      final matched = users.where((u) => u.uid == uid);
      return matched.isEmpty ? null : matched.first;
    }
  }

  Future<void> signOut() async {
    if (_firebaseAvailable) {
      await _auth?.signOut();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localCurrentUid);
    }
  }

  Future<void> updateUserProfile(String name, String phone) async {
    if (_firebaseAvailable) {
      _initFirebase();
      final user = _auth?.currentUser;
      if (user == null) throw Exception('User not signed in.');

      try {
        await _firestore!.collection('users').doc(user.uid).update({
          'name': name,
          'phone': phone,
        });
      } catch (e) {
        throw Exception('Update failed: $e');
      }
    } else {
      final current = await currentUser;
      if (current == null) throw Exception('User not signed in (local mode).');

      final users = await _getLocalUsers();
      final index = users.indexWhere((u) => u.uid == current.uid);
      if (index == -1) throw Exception('User not found (local mode).');

      final updated = (users[index] as _LocalUserModel).copyWith(name: name, phone: phone);
      users[index] = updated;
      await _setLocalUsers(users);
    }
  }

  Future<List<UserModel>> _getLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_localUsersKey) ?? [];
    return list.map((item) {
      final data = jsonDecode(item) as Map<String, dynamic>;
      return _LocalUserModel.fromMap(data);
    }).toList();
  }

  Future<void> _setLocalUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final list = users.map((u) => jsonEncode((u as _LocalUserModel).toMap())).toList();
    await prefs.setStringList(_localUsersKey, list);
  }
}

class _LocalUserModel extends UserModel {
  final String password;

  _LocalUserModel({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required DateTime createdAt,
    this.password = '',
    bool isActive = true,
  }) : super(
          uid: uid,
          name: name,
          email: email,
          phone: phone,
          createdAt: createdAt,
          isActive: isActive,
        );

  _LocalUserModel copyWith({String? name, String? phone}) {
    return _LocalUserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      password: password,
      isActive: isActive,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['password'] = password;
    return map;
  }

  factory _LocalUserModel.fromMap(Map<String, dynamic> map) {
    return _LocalUserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      password: map['password'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}

