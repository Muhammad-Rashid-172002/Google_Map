import 'package:flutter/material.dart';
import 'package:google_map/screens/google_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Map',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        // primarySwatch: Colors.deepPurple,
      ),
      home: const GoogleMapScreen(),
    );
  }
}
//