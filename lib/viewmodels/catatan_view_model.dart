import 'package:flutter/foundation.dart';

import '../data/catatan_repository.dart';
import '../models/catatan.dart';

class CatatanViewModel extends ChangeNotifier {
  final CatatanRepository repository;
  CatatanViewModel(this.repository);

  List<Catatan> _catatan = [];
  List<Catatan> get catatan => List.unmodifiable(_catatan);
  bool isLoading = false;
  String? error;

  /// Mata kuliah utama praktikum; selalu tampil di halaman Profil.
  static const mataKuliahUtama = 'Pemrograman Aplikasi Bergerak';

  /// Daftar mata kuliah unik dari catatan, untuk halaman Profil.
  List<MataKuliahRingkas> get daftarMataKuliah {
    final jumlah = <String, int>{mataKuliahUtama: 0};
    for (final c in _catatan) {
      final kunci = jumlah.keys.firstWhere(
          (k) => k.toLowerCase() == c.mataKuliah.trim().toLowerCase(),
          orElse: () => c.mataKuliah.trim());
      jumlah[kunci] = (jumlah[kunci] ?? 0) + 1;
    }
    return jumlah.entries.map((e) => MataKuliahRingkas(e.key, e.value)).toList()
      ..sort((a, b) => a.nama.compareTo(b.nama));
  }

  List<Catatan> catatanUntuk(String mataKuliah) => _catatan
      .where((c) => c.mataKuliah.trim().toLowerCase() == mataKuliah.trim().toLowerCase())
      .toList();

  Future<void> muatCatatan() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _catatan = await repository.semua();
    } catch (e) {
      error = 'Tidak dapat membaca catatan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tambahCatatan(Catatan baru) async {
    await repository.tambah(baru);
    await muatCatatan();
  }

  Future<void> ubahCatatan(Catatan catatan) async {
    await repository.ubah(catatan);
    await muatCatatan();
  }

  Future<void> hapusCatatan(int id) async {
    await repository.hapus(id);
    await muatCatatan();
  }
}

class MataKuliahRingkas {
  final String nama;
  final int jumlahCatatan;
  const MataKuliahRingkas(this.nama, this.jumlahCatatan);
}
