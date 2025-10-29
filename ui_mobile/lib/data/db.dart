import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'app.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  started_at INTEGER NOT NULL,
  ended_at INTEGER,
  summary_score REAL,
  notes TEXT
);
''');
        await db.execute('''
CREATE TABLE frames (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  ts_ms INTEGER NOT NULL,
  pose_status TEXT,
  eye_state TEXT,
  eye_distance_cm REAL,
  FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE
);
''');
        await db.execute('''
CREATE TABLE alerts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  ts_ms INTEGER NOT NULL,
  type TEXT NOT NULL,
  message TEXT,
  FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE
);
''');
      },
    );
    return _db!;
  }
}


