import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _warnThreshold = 0.3;
  int _fps = 10;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _warnThreshold = prefs.getDouble('warnThreshold') ?? 0.3;
      _fps = prefs.getInt('fps') ?? 10;
      _loading = false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('warnThreshold', _warnThreshold);
    await prefs.setInt('fps', _fps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                Text('Ngưỡng cảnh báo: ${(_warnThreshold * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  min: 0.2,
                  max: 0.8,
                  divisions: 60,
                  value: _warnThreshold,
                  label: _warnThreshold.toStringAsFixed(2),
                  onChanged: (v) {
                    setState(() => _warnThreshold = v);
                  },
                  onChangeEnd: (v) => _savePrefs(),
                ),
                const SizedBox(height: 20),
                Text('FPS mục tiêu:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 30,
                        divisions: 29,
                        value: _fps.toDouble(),
                        label: _fps.toString(),
                        onChanged: (v) {
                          setState(() => _fps = v.round());
                        },
                        onChangeEnd: (v) => _savePrefs(),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        initialValue: _fps.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8)),
                        onChanged: (value) {
                          final n = int.tryParse(value) ?? _fps;
                          if (n > 0 && n <= 60) {
                            setState(() => _fps = n);
                            _savePrefs();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('FPS')
                  ],
                )
              ],
            ),
    );
  }
}


