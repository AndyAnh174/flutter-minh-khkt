import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: const [
          ListTile(title: Text('Ngưỡng cảnh báo (demo)')),
          ListTile(title: Text('FPS mục tiêu (demo)')),
        ],
      ),
    );
  }
}


