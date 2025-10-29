import '../../data/db.dart';

class SessionRepository {
  Future<int> startSession({String? notes}) async {
    final db = await AppDatabase.instance();
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.insert('sessions', {
      'started_at': now,
      'notes': notes,
    });
  }

  Future<void> endSession(int sessionId, {double? summaryScore}) async {
    final db = await AppDatabase.instance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'sessions',
      {'ended_at': now, 'summary_score': summaryScore},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> addFrame({
    required int sessionId,
    required int tsMs,
    String? poseStatus,
    String? eyeState,
    double? eyeDistanceCm,
  }) async {
    final db = await AppDatabase.instance();
    await db.insert('frames', {
      'session_id': sessionId,
      'ts_ms': tsMs,
      'pose_status': poseStatus,
      'eye_state': eyeState,
      'eye_distance_cm': eyeDistanceCm,
    });
  }

  Future<void> addAlert({
    required int sessionId,
    required int tsMs,
    required String type,
    String? message,
  }) async {
    final db = await AppDatabase.instance();
    await db.insert('alerts', {
      'session_id': sessionId,
      'ts_ms': tsMs,
      'type': type,
      'message': message,
    });
  }

  Future<List<Map<String, Object?>>> listSessions() async {
    final db = await AppDatabase.instance();
    return db.query('sessions', orderBy: 'started_at DESC');
  }

  Future<List<Map<String, Object?>>> sessionFrames(int sessionId) async {
    final db = await AppDatabase.instance();
    return db.query('frames', where: 'session_id = ?', whereArgs: [sessionId], orderBy: 'ts_ms ASC');
  }

  Future<List<Map<String, Object?>>> sessionAlerts(int sessionId) async {
    final db = await AppDatabase.instance();
    return db.query('alerts', where: 'session_id = ?', whereArgs: [sessionId], orderBy: 'ts_ms ASC');
  }
}


