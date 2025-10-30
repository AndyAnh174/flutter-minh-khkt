import 'package:flutter/material.dart';
import '../data/repositories/session_repository.dart';
import 'package:intl/intl.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key});

  String _fmtTime(int? ms) {
    if (ms == null) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('HH:mm:ss dd/MM/yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = ModalRoute.of(context)!.settings.arguments as int?;
    final repo = SessionRepository();
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết phiên #${sessionId ?? '-'}')),
      body: sessionId == null
          ? const Center(child: Text('Thiếu sessionId'))
          : FutureBuilder<List<dynamic>>(
              future: Future.wait([
                repo.sessionFrames(sessionId),
                repo.sessionAlerts(sessionId),
                repo.listSessions().then((ss) => ss.firstWhere((e)=>e['id']==sessionId)),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final frames = snapshot.data![0] as List;
                final alerts = snapshot.data![1] as List;
                final info = snapshot.data![2] as Map<String, Object?>;
                final started = info['started_at'] as int?;
                final ended = info['ended_at'] as int?;
                final duration = (ended != null && started != null) ? Duration(milliseconds: ended-started) : null;

                // Thống kê trạng thái
                int closedCount = frames.where((f)=>f['eye_state']=='closed').length;
                int upright = frames.where((f)=>f['pose_status']=='straight').length;
                int notUpright = frames.where((f)=>f['pose_status']=='not_straight').length;
                int total = frames.length;

                double pctClosed = total>0 ? closedCount/total*100 : 0;
                double pctStraight = total>0 ? upright/total*100 : 0;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Thời gian bắt đầu: ${_fmtTime(started)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Thời gian kết thúc: ${ended==null?'-':_fmtTime(ended)}'),
                    if (duration != null)
                      Text('Tổng thời lượng: ${duration.inMinutes} phút ${duration.inSeconds%60} giây'),
                    const SizedBox(height: 10),
                    Text('Tổng số khung: $total'),
                    Text('Số lần nhắm mắt: $closedCount (${pctClosed.toStringAsFixed(1)}%)'),
                    Text('Đúng tư thế: $upright (${pctStraight.toStringAsFixed(1)}%)'),
                    Text('Sai tư thế: $notUpright (${(100-pctStraight).toStringAsFixed(1)}%)'),
                    const Divider(),
                    Text('Cảnh báo:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    if (alerts.isEmpty)
                      const Text('Không có cảnh báo nào.'),
                    ...alerts.map((a) => Card(
                      color: a['type']=='eye'? Colors.red[100] : Colors.orange[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Icon(Icons.warning, color: a['type']=='eye'?Colors.red:Colors.orange),
                        title: Text('${a['type']}'.toUpperCase()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (a['message']!=null)
                              Text(a['message'].toString()),
                            Text('Thời gian: ${_fmtTime(a['ts_ms'] as int?)}', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    )),
                  ],
                );
              },
            ),
    );
  }
}


