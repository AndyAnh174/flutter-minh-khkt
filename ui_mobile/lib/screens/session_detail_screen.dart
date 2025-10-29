import 'package:flutter/material.dart';
import '../data/repositories/session_repository.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionId = ModalRoute.of(context)!.settings.arguments as int?;
    final repo = SessionRepository();
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết phiên #${sessionId ?? '-'}')),
      body: sessionId == null
          ? const Center(child: Text('Thiếu sessionId'))
          : FutureBuilder<List<List<Map<String, Object?>>>>(
              future: Future.wait([
                repo.sessionFrames(sessionId),
                repo.sessionAlerts(sessionId),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final frames = snapshot.data![0];
                final alerts = snapshot.data![1];
                return ListView(
                  children: [
                    ListTile(title: Text('Số khung lưu: ${frames.length}')),
                    ListTile(title: Text('Số cảnh báo: ${alerts.length}')),
                    const Divider(),
                    ...alerts.map((a) => ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text('${a['type']}'),
                          subtitle: Text('${a['message'] ?? ''}'),
                        )),
                  ],
                );
              },
            ),
    );
  }
}


