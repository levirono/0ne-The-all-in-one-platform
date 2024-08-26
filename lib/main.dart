import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one/services/database_helper.dart';
import 'package:one/splashscreen/splash_screen.dart';
import 'package:one/ui/home';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyAaZv3xdNfHRsTxQ63AXyUHLY-WzWDHv7Q",
            appId: "1:150143957390:android:9644c97359427845f34cdf",
            messagingSenderId: "150143957390",
            projectId: "onel-ba9bf",
          ),
        )
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return HomePage(); // Navigate to HomePage if user is authenticated
          } else {
            return SplashScreen(); // Navigate to SplashScreen if user is not authenticated
          }
        },
      ),
    );
  }
}