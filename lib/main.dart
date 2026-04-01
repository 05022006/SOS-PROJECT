import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (skip if placeholder keys are present)
  final options = DefaultFirebaseOptions.currentPlatform;
  final hasPlaceholder = options.apiKey == 'YOUR_API_KEY' ||
      options.appId == 'YOUR_APP_ID' ||
      options.projectId == 'YOUR_PROJECT_ID';

  if (!hasPlaceholder) {
    try {
      await Firebase.initializeApp(options: options);
      print('Firebase initialized successfully.');
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  } else {
    print('Firebase configuration placeholders detected. Skipping initialization.');
  }

  // Initialize background service
  try {
    await BackgroundService.initialize();
  } catch (e) {
    print('Background service initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Safety App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red[700],
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
