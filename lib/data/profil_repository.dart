import 'package:sqflite/sqflite.dart';

import '../models/profil.dart';
import 'database_helper.dart';

class ProfilRepository {
  final DatabaseHelper helper;
  ProfilRepository(this.helper);

  Future<Profil?> ambil() async {
    final db = await helper.database;
    final rows = await db.query('profil', where: 'id = 1', limit: 1);
    return rows.isEmpty ? null : Profil.fromMap(rows.first);
  }

  Future<void> simpan(Profil profil) async {
    final db = await helper.database;
    await db.insert('profil', profil.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
