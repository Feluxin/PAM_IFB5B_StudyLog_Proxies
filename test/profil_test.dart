import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studylog_flutter/data/database_helper.dart';
import 'package:studylog_flutter/data/profil_repository.dart';
import 'package:studylog_flutter/models/profil.dart';
import 'package:studylog_flutter/screens/profil/form_profil_page.dart';
import 'package:studylog_flutter/viewmodels/profil_view_model.dart';

class FakeProfilRepository implements ProfilRepository {
  Profil? tersimpan;

  @override
  DatabaseHelper get helper => throw UnimplementedError();

  @override
  Future<Profil?> ambil() async => tersimpan;

  @override
  Future<void> simpan(Profil profil) async => tersimpan = profil;
}

void main() {
  group('Validasi profil', () {
    test('nama', () {
      expect(ValidasiProfil.nama(''), 'Nama wajib diisi');
      expect(ValidasiProfil.nama('Al'), 'Nama minimal 3 karakter');
      expect(ValidasiProfil.nama('Albert 123'), 'Nama hanya boleh berisi huruf');
      expect(ValidasiProfil.nama('Albert Felix Jonathan'), isNull);
    });
    test('NIM', () {
      expect(ValidasiProfil.nim(''), 'NIM wajib diisi');
      expect(ValidasiProfil.nim('24110AB'), 'NIM hanya boleh berisi angka');
      expect(ValidasiProfil.nim('24110'), 'NIM harus 7 digit');
      expect(ValidasiProfil.nim('2411048'), isNull);
    });
    test('kontak opsional', () {
      expect(ValidasiProfil.email(''), isNull);
      expect(ValidasiProfil.email('albert@'), 'Format email tidak valid');
      expect(ValidasiProfil.telepon(''), isNull);
      expect(ValidasiProfil.telepon('0812'), 'Nomor harus 10–13 digit');
    });
  });

  testWidgets('Tombol Simpan hanya aktif saat input valid, lalu profil tersimpan',
      (tester) async {
    final repo = FakeProfilRepository();
    final vm = ProfilViewModel(repo);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: vm,
      child: const MaterialApp(home: FormProfilPage()),
    ));

    FilledButton simpan() => tester.widget<FilledButton>(find.byType(FilledButton));
    expect(simpan().onPressed, isNull); // awal: nama & NIM kosong

    await tester.enterText(find.widgetWithText(TextFormField, 'Nama lengkap'), 'Albert Felix Jonathan');
    await tester.enterText(find.widgetWithText(TextFormField, 'NIM'), '24110');
    await tester.pump();
    expect(simpan().onPressed, isNull); // NIM belum 7 digit
    expect(find.text('NIM harus 7 digit'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'NIM'), '2411048');
    await tester.pump();
    expect(simpan().onPressed, isNotNull);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repo.tersimpan?.nim, '2411048');
    expect(vm.profil?.prodi, 'Informatika');
    expect(vm.namaPanggilan, 'Albert');
  });
}
