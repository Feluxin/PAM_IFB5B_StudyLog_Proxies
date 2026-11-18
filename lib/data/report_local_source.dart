import 'package:sqflite/sqflite.dart';

import '../models/report.dart';
import 'database_helper.dart';

/// Akses tabel `reports` pada SQLite lokal.
class ReportLocalSource {
  final DatabaseHelper helper;
  ReportLocalSource(this.helper);

  Future<Database> get _db => helper.database;

  /// Laporan yang tertinggal di status `sending` karena aplikasi terhenti
  /// dipulihkan menjadi `failed` agar dapat dikirim ulang.
  Future<void> recoverInterruptedSending() async {
    final db = await _db;
    await db.update(
      'reports',
      {'status': ReportStatus.failed, 'last_error': 'Pengiriman sebelumnya terputus'},
      where: 'status = ?',
      whereArgs: [ReportStatus.sending],
    );
  }

  Future<List<FacilityReport>> all() async {
    final db = await _db;
    final rows = await db.query('reports', orderBy: 'created_at DESC');
    return rows.map(FacilityReport.fromMap).toList();
  }

  Future<List<FacilityReport>> awaitingSync() async {
    final db = await _db;
    final rows = await db.query(
      'reports',
      where: 'status IN (?, ?)',
      whereArgs: [ReportStatus.pending, ReportStatus.failed],
      orderBy: 'created_at ASC',
    );
    return rows.map(FacilityReport.fromMap).toList();
  }

  Future<void> insert(FacilityReport report) async {
    final db = await _db;
    await db.insert('reports', report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<void> setStatus(String localId, String status,
      {String? serverId, String? lastError}) async {
    final db = await _db;
    await db.update(
      'reports',
      {'status': status, 'server_id': serverId, 'last_error': lastError},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> delete(String localId) async {
    final db = await _db;
    await db.delete('reports', where: 'local_id = ?', whereArgs: [localId]);
  }
}
