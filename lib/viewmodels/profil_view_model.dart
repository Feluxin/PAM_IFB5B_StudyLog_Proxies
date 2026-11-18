import 'package:flutter/foundation.dart';

import '../data/profil_repository.dart';
import '../models/profil.dart';

/// State holder profil (Materi 5): nama, NIM, dan prodi disimpan di ViewModel
/// sehingga tetap tersedia saat layar dibuat ulang (rotasi atau pindah layar),
/// lalu disimpan ke SQLite agar tidak hilang saat aplikasi ditutup.
class ProfilViewModel extends ChangeNotifier {
  final ProfilRepository repository;
  ProfilViewModel(this.repository);

  Profil? _profil;
  bool isLoading = true;
  String? error;

  Profil? get profil => _profil;
  bool get sudahDiisi => _profil != null;
  String get namaPanggilan {
    final nama = _profil?.nama.trim() ?? '';
    return nama.isEmpty ? 'Mahasiswa' : nama.split(' ').first;
  }

  Future<void> muat() async {
    try {
      _profil = await repository.ambil();
      error = null;
    } catch (e) {
      error = 'Tidak dapat membaca profil: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> simpan(Profil profil) async {
    await repository.simpan(profil);
    _profil = profil;
    notifyListeners();
  }
}
