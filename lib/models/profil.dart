/// Profil mahasiswa pemilik perangkat (satu baris di tabel `profil`).
class Profil {
  static const daftarStatus = ['Aktif', 'Cuti', 'Non-aktif'];

  final String nama;
  final String nim;
  final String prodi;
  final String status;
  final String email;
  final String telepon;

  const Profil({
    required this.nama,
    required this.nim,
    required this.prodi,
    this.status = 'Aktif',
    this.email = '',
    this.telepon = '',
  });

  Map<String, Object?> toMap() => {
        'id': 1,
        'nama': nama,
        'nim': nim,
        'prodi': prodi,
        'status': status,
        'email': email,
        'telepon': telepon,
      };

  factory Profil.fromMap(Map<String, Object?> map) => Profil(
        nama: map['nama'] as String,
        nim: map['nim'] as String,
        prodi: map['prodi'] as String,
        status: map['status'] as String? ?? 'Aktif',
        email: map['email'] as String? ?? '',
        telepon: map['telepon'] as String? ?? '',
      );
}

/// Aturan validasi form profil. Mengembalikan pesan galat, atau null jika valid.
class ValidasiProfil {
  static final _huruf = RegExp(r"^[A-Za-z .'-]+$");
  static final _angka = RegExp(r'^\d+$');
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? nama(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Nama wajib diisi';
    if (t.length < 3) return 'Nama minimal 3 karakter';
    if (!_huruf.hasMatch(t)) return 'Nama hanya boleh berisi huruf';
    return null;
  }

  static String? nim(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'NIM wajib diisi';
    if (!_angka.hasMatch(t)) return 'NIM hanya boleh berisi angka';
    if (t.length != 7) return 'NIM harus 7 digit';
    return null;
  }

  static String? prodi(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Program studi wajib diisi';
    if (t.length < 3) return 'Program studi minimal 3 karakter';
    return null;
  }

  /// Opsional; jika diisi harus berformat email.
  static String? email(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    return _email.hasMatch(t) ? null : 'Format email tidak valid';
  }

  /// Opsional; jika diisi harus 10–13 digit.
  static String? telepon(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    if (!_angka.hasMatch(t)) return 'Nomor hanya boleh berisi angka';
    if (t.length < 10 || t.length > 13) return 'Nomor harus 10–13 digit';
    return null;
  }

  static bool semuaValid({
    required String nama,
    required String nim,
    required String prodi,
    String email = '',
    String telepon = '',
  }) =>
      ValidasiProfil.nama(nama) == null &&
      ValidasiProfil.nim(nim) == null &&
      ValidasiProfil.prodi(prodi) == null &&
      ValidasiProfil.email(email) == null &&
      ValidasiProfil.telepon(telepon) == null;
}
