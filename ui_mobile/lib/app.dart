import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/live_camera_screen.dart';
import 'screens/history_screen.dart';
import 'screens/session_detail_screen.dart';
import 'screens/settings_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Mobile',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      routes: {
        '/': (context) => const HomeScreen(),
        '/live': (context) => const LiveCameraScreen(),
        '/history': (context) => const HistoryScreen(),
        '/session': (context) => const SessionDetailScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}


