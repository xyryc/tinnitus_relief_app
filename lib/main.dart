import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinnitus Relief Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        fontFamily: 'Kallisto', // Set Kallisto as the default font for the entire app
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Kallisto'),
          displayMedium: TextStyle(fontFamily: 'Kallisto'),
          displaySmall: TextStyle(fontFamily: 'Kallisto'),
          headlineLarge: TextStyle(fontFamily: 'Kallisto'),
          headlineMedium: TextStyle(fontFamily: 'Kallisto'),
          headlineSmall: TextStyle(fontFamily: 'Kallisto'),
          titleLarge: TextStyle(fontFamily: 'Kallisto'),
          titleMedium: TextStyle(fontFamily: 'Kallisto'),
          titleSmall: TextStyle(fontFamily: 'Kallisto'),
          bodyLarge: TextStyle(fontFamily: 'Kallisto'),
          bodyMedium: TextStyle(fontFamily: 'Kallisto'),
          bodySmall: TextStyle(fontFamily: 'Kallisto'),
          labelLarge: TextStyle(fontFamily: 'Kallisto'),
          labelMedium: TextStyle(fontFamily: 'Kallisto'),
          labelSmall: TextStyle(fontFamily: 'Kallisto'),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

