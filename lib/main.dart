import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'screens/opening_screen.dart'; // Make sure this import exists

void main() {
  runApp(DevicePreview(
    enabled: true,
    builder: (context) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Sharing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OpeningScreen(), // Set to OpeningScreen
      useInheritedMediaQuery: true, // Recommended when using DevicePreview
    );
  }
}
