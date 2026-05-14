import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const MapRunnerApp());
}

class MapRunnerApp extends StatelessWidget {
  const MapRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapRunner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
