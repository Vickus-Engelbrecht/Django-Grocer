import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'package:django_grocer/screens/customer/home_screen.dart';
import 'package:django_grocer/screens/driver/driver_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Django Grocer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const LoginScreen(),
    );
  }
}

void navigateAfterLogin(BuildContext context, String userType) {
  if (userType == 'customer') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
    );
  } else if (userType == 'driver') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
    );
  }
}
