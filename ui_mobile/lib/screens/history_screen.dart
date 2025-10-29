import 'package:flutter/material.dart';
import '../data/repositories/session_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SessionRepository _repo = SessionRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử')),
      body: FutureBuilder<List<Map<String, Object?>>> (
        future: _repo.listSessions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('Chưa có phiên nào'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              final id = s['id'] as int?;
              final started = s['started_at'] as int?;
              final ended = s['ended_at'] as int?;
              final time = DateTime.fromMillisecondsSinceEpoch(started ?? 0);
              return ListTile(
                title: Text('Phiên #$id'),
                subtitle: Text('${time.toLocal()}${ended == null ? ' (đang chạy/kết thúc gần đây)' : ''}'),
                onTap: () => Navigator.pushNamed(context, '/session', arguments: id),
              );
            },
          );
        },
      ),
    );
  }
}



