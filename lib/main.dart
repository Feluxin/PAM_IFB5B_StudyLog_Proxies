import 'package:flutter/material.dart';

// Milestone 1 + Latihan Mandiri 3.5 (Kelompok Proxies)
// - Field "Topik" dengan validasi minimal tiga karakter
// - Warna, ikon, dan teks tombol berubah ketika data berhasil ditampilkan

void main() => runApp(const StudyLogApp());

class StudyLogApp extends StatelessWidget {
  const StudyLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyLog | Praktikum 1',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const CatatanFormSederhana(),
    );
  }
}

class CatatanFormSederhana extends StatefulWidget {
  const CatatanFormSederhana({super.key});

  @override
  State<CatatanFormSederhana> createState() => _CatatanFormSederhanaState();
}

class _CatatanFormSederhanaState extends State<CatatanFormSederhana> {
  final _formKey = GlobalKey<FormState>();
  final _mataKuliah = TextEditingController();
  final _judul = TextEditingController();
  final _topik = TextEditingController();
  final _isi = TextEditingController();
  String? _hasil;

  // State tambahan: true setelah data valid ditampilkan,
  // kembali false ketika pengguna mengubah isi form.
  bool _berhasil = false;

  @override
  void dispose() {
    _mataKuliah.dispose();
    _judul.dispose();
    _topik.dispose();
    _isi.dispose();
    super.dispose();
  }

  String? _wajibDiisi(String? nilai, String label) =>
      (nilai == null || nilai.trim().isEmpty) ? '$label wajib diisi' : null;

  String? _validasiTopik(String? nilai) {
    final teks = nilai?.trim() ?? '';
    if (teks.isEmpty) return 'Topik wajib diisi';
    if (teks.length < 3) return 'Topik minimal 3 karakter';
    return null;
  }

  void _simpanSementara() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _berhasil = false);
      return;
    }
    setState(() {
      _hasil = '${_mataKuliah.text.trim()} | ${_judul.text.trim()} | '
          'Topik: ${_topik.text.trim()}';
      _berhasil = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data ditampilkan (belum tersimpan permanen).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StudyLog - Form Catatan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Praktikum 1: State & Interaksi',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            // Event: setiap ketikan pengguna mengembalikan tombol ke kondisi awal.
            onChanged: () {
              if (_berhasil) setState(() => _berhasil = false);
            },
            child: Column(
              children: [
                TextFormField(
                  controller: _mataKuliah,
                  decoration: const InputDecoration(
                      labelText: 'Mata kuliah', border: OutlineInputBorder()),
                  validator: (nilai) => _wajibDiisi(nilai, 'Mata kuliah'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _judul,
                  decoration: const InputDecoration(
                      labelText: 'Judul catatan', border: OutlineInputBorder()),
                  validator: (nilai) => _wajibDiisi(nilai, 'Judul'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _topik,
                  decoration: const InputDecoration(
                      labelText: 'Topik',
                      helperText: 'Minimal 3 karakter',
                      border: OutlineInputBorder()),
                  validator: _validasiTopik,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _isi,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      labelText: 'Isi catatan', border: OutlineInputBorder()),
                  validator: (nilai) => _wajibDiisi(nilai, 'Isi catatan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _simpanSementara,
            style: FilledButton.styleFrom(
              backgroundColor: _berhasil ? Colors.green : null,
            ),
            icon: Icon(_berhasil ? Icons.check_circle : Icons.save),
            label: Text(_berhasil ? 'Berhasil Ditampilkan' : 'Tampilkan Catatan'),
          ),
          if (_hasil != null) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Hasil input: $_hasil'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
