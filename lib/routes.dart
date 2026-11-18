import 'package:flutter/material.dart';

import 'models/catatan.dart';
import 'screens/beranda_page.dart';
import 'screens/daftar_catatan_page.dart';
import 'screens/detail_catatan_page.dart';
import 'screens/form_catatan_page.dart';
import 'screens/profil/detail_mata_kuliah_page.dart';
import 'screens/profil/form_profil_page.dart';
import 'screens/profil/kontak_page.dart';
import 'screens/profil/profil_page.dart';
import 'screens/report/report_detail_screen.dart';
import 'screens/report/report_form_screen.dart';
import 'screens/report/report_list_screen.dart';
import 'screens/tentang_page.dart';

/// Nama route untuk setiap destination (setara route pada Navigation Compose).
/// Back stack dikelola Navigator: pushNamed menambah layar, pop kembali.
class AppRoutes {
  static const beranda = '/';
  static const profil = '/profil';
  static const formProfil = '/profil/edit';
  static const kontak = '/profil/kontak';
  static const mataKuliah = '/profil/mata-kuliah'; // argumen: String nama
  static const catatan = '/catatan';
  static const detailCatatan = '/catatan/detail'; // argumen: int id
  static const formCatatan = '/catatan/form'; // argumen: FormCatatanArgs?
  static const report = '/report';
  static const formReport = '/report/form';
  static const detailReport = '/report/detail'; // argumen: String localId
  static const tentang = '/tentang';

  /// Pengganti NavHost: memetakan nama route dan argumen ke halaman.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final Widget page = switch (settings.name) {
      beranda => const BerandaPage(),
      profil => const ProfilPage(),
      formProfil => const FormProfilPage(),
      kontak => const KontakPage(),
      mataKuliah => DetailMataKuliahPage(nama: args as String),
      catatan => const DaftarCatatanPage(),
      detailCatatan => DetailCatatanPage(id: args as int),
      formCatatan => FormCatatanPage(
          awal: (args as FormCatatanArgs?)?.awal,
          mataKuliahAwal: args?.mataKuliah,
        ),
      report => const ReportListScreen(),
      formReport => const ReportFormScreen(),
      detailReport => ReportDetailScreen(localId: args as String),
      tentang => const TentangPage(),
      _ => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Halaman ${settings.name} tidak ditemukan')),
        ),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

class FormCatatanArgs {
  final Catatan? awal;
  final String? mataKuliah;
  const FormCatatanArgs({this.awal, this.mataKuliah});
}
