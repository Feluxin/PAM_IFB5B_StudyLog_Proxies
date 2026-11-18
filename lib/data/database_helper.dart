import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Satu berkas SQLite untuk seluruh modul aplikasi.
///
/// Versi 1 (StudyLog M3): tabel `catatan`.
/// Versi 2 (Studi Kasus 2): tambah tabel `profil` (Profil Mahasiswa) dan
/// `reports` (Campus Report). Pengguna lama tidak kehilangan catatan karena
/// tabel baru dibuat lewat `onUpgrade`.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static const int versi = 2;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final filePath = join(await getDatabasesPath(), 'studylog.db');
    _database = await openDatabase(
      filePath,
      version: versi,
      onCreate: (db, version) async {
        await _buatCatatan(db);
        await _buatProfil(db);
        await _buatReports(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _buatProfil(db);
          await _buatReports(db);
        }
      },
    );
    return _database!;
  }

  static Future<void> _buatCatatan(Database db) => db.execute('''
    CREATE TABLE catatan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mata_kuliah TEXT NOT NULL,
      judul TEXT NOT NULL,
      isi TEXT NOT NULL,
      tanggal TEXT NOT NULL
    )
  ''');

  static Future<void> _buatProfil(Database db) => db.execute('''
    CREATE TABLE profil (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      nama TEXT NOT NULL,
      nim TEXT NOT NULL,
      prodi TEXT NOT NULL,
      status TEXT NOT NULL,
      email TEXT NOT NULL DEFAULT '',
      telepon TEXT NOT NULL DEFAULT ''
    )
  ''');

  static Future<void> _buatReports(Database db) => db.execute('''
    CREATE TABLE reports (
      local_id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT NOT NULL,
      priority TEXT NOT NULL,
      photo_path TEXT,
      latitude REAL,
      longitude REAL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      server_id TEXT,
      last_error TEXT
    )
  ''');
}
