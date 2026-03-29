import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/geofence_service.dart';
import '../services/panic_detection_service.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final GeofenceService _geofenceService = GeofenceService();
  final PanicDetectionService _panicService = PanicDetectionService();
  bool _geofenceEnabled = false;
  bool _panicDetectionEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _geofenceEnabled = _geofenceService.isMonitoring;
      _panicDetectionEnabled = _panicService.isMonitoring;
    });
  }

  Future<void> _handleLogout() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User Info
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red[700],
              child: Text(
                user?.email?[0].toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user?.email ?? 'User'),
            subtitle: const Text('Account Information'),
          ),
          const Divider(),

          // Geo-Fence Settings
          SwitchListTile(
            title: const Text('Geo-Fence Monitoring'),
            subtitle: const Text('Monitor location and alert when leaving safe zones'),
            value: _geofenceEnabled,
            onChanged: (value) async {
              if (value) {
                await _geofenceService.startMonitoring();
              } else {
                _geofenceService.stopMonitoring();
              }
              setState(() => _geofenceEnabled = value);
            },
          ),

          // Panic Detection Settings
          SwitchListTile(
            title: const Text('Panic Detection'),
            subtitle: const Text('Auto-detect panic situations using sensors'),
            value: _panicDetectionEnabled,
            onChanged: (value) async {
              if (value) {
                await _panicService.startMonitoring();
              } else {
                _panicService.stopMonitoring();
              }
              setState(() => _panicDetectionEnabled = value);
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('SOS Safety App v1.0.0'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: const Text(
                    'SOS & Geo-Fencing Mobile Application\n'
                    'for Women and Elderly Safety\n\n'
                    'Version: 1.0.0\n'
                    'Built with Flutter & Firebase',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Privacy & Security:\n\n'
                      '• Location data is only used during emergencies or geo-fence monitoring\n'
                      '• No data is shared without your consent\n'
                      '• All data is encrypted and stored securely\n'
                      '• You can disable features at any time\n'
                      '• Emergency contacts are stored locally and synced to cloud',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}
