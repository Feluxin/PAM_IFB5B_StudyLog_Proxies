// Uji navigasi (Materi 5): semua layar dapat dibuka lewat route dan tombol
// kembali mengikuti back stack, tanpa crash atau overflow tampilan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studylog_flutter/data/catatan_repository.dart';
import 'package:studylog_flutter/data/database_helper.dart';
import 'package:studylog_flutter/data/report_repository.dart';
import 'package:studylog_flutter/models/catatan.dart';
import 'package:studylog_flutter/models/profil.dart';
import 'package:studylog_flutter/routes.dart';
import 'package:studylog_flutter/services/device_services.dart';
import 'package:studylog_flutter/viewmodels/catatan_view_model.dart';
import 'package:studylog_flutter/viewmodels/profil_view_model.dart';
import 'package:studylog_flutter/viewmodels/report_view_model.dart';

import 'profil_test.dart' show FakeProfilRepository;
import 'report_repository_test.dart' show FakeApi, FakeLocal;

class FakeCatatanRepository implements CatatanRepository {
  final List<Catatan> data = [
    Catatan(id: 1, mataKuliah: 'Pemrograman Aplikasi Bergerak', judul: 'SQLite pada Flutter',
        isi: 'sqflite menyimpan data di studylog.db', tanggal: DateTime(2026, 11, 7)),
  ];
  @override
  DatabaseHelper get helper => throw UnimplementedError();
  @override
  Future<List<Catatan>> semua() async => data;
  @override
  Future<int> tambah(Catatan c) async => 0;
  @override
  Future<int> ubah(Catatan c) async => 0;
  @override
  Future<int> hapus(int id) async => 0;
}

void main() {
  testWidgets('Beranda → Profil → Detail Mata Kuliah → kembali, lalu Campus Report',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    final profilRepo = FakeProfilRepository()
      ..tersimpan = const Profil(nama: 'Albert Felix Jonathan', nim: '2411048', prodi: 'Informatika',
          email: 'albert@example.com', telepon: '081234567890');
    final profil = ProfilViewModel(profilRepo);
    final catatan = CatatanViewModel(FakeCatatanRepository());
    final report = ReportViewModel(ReportRepository(FakeLocal(), FakeApi()));
    await profil.muat();
    await catatan.muatCatatan();
    await report.initialize();

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider(create: (_) => DeviceServices()),
        ChangeNotifierProvider.value(value: profil),
        ChangeNotifierProvider.value(value: catatan),
        ChangeNotifierProvider.value(value: report),
      ],
      child: const MaterialApp(
        initialRoute: AppRoutes.beranda,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Albert!'), findsOneWidget);

    await tester.tap(find.text('Profil Mahasiswa'));
    await tester.pumpAndSettle();
    expect(find.text('NIM 2411048'), findsOneWidget);

    await tester.tap(find.text('Tampilkan Salam'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Halo, Albert Felix Jonathan!'), findsOneWidget);

    await tester.tap(find.text('Kontak'));
    await tester.pumpAndSettle();
    expect(find.text('albert@example.com'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Pemrograman Aplikasi Bergerak'), 200);
    await tester.tap(find.text('Pemrograman Aplikasi Bergerak'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Mata Kuliah'), findsOneWidget);
    expect(find.text('SQLite pada Flutter'), findsOneWidget);

    // Back stack: Detail Mata Kuliah → Profil → Beranda
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Profil Mahasiswa'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Halo, Albert!'), findsOneWidget);

    await tester.tap(find.text('Campus Report'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Belum ada laporan'), findsOneWidget);
    await tester.tap(find.text('Buat Laporan'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan Offline'), findsOneWidget);
  });
}
