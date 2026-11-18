import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/profil.dart';
import '../../viewmodels/profil_view_model.dart';

/// Form Profil Mahasiswa (Materi 4): input disimpan sebagai state,
/// divalidasi saat diketik, dan tombol Simpan hanya aktif jika semua valid.
class FormProfilPage extends StatefulWidget {
  const FormProfilPage({super.key});

  @override
  State<FormProfilPage> createState() => _FormProfilPageState();
}

class _FormProfilPageState extends State<FormProfilPage> {
  late final Profil? _awal = context.read<ProfilViewModel>().profil;
  late final _nama = TextEditingController(text: _awal?.nama);
  late final _nim = TextEditingController(text: _awal?.nim);
  late final _prodi = TextEditingController(text: _awal?.prodi ?? 'Informatika');
  late final _email = TextEditingController(text: _awal?.email);
  late final _telepon = TextEditingController(text: _awal?.telepon);
  late String _status = _awal?.status ?? Profil.daftarStatus.first;
  bool _menyimpan = false;

  @override
  void dispose() {
    for (final c in [_nama, _nim, _prodi, _email, _telepon]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => ValidasiProfil.semuaValid(
        nama: _nama.text,
        nim: _nim.text,
        prodi: _prodi.text,
        email: _email.text,
        telepon: _telepon.text,
      );

  Future<void> _simpan() async {
    setState(() => _menyimpan = true);
    final vm = context.read<ProfilViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await vm.simpan(Profil(
        nama: _nama.text.trim(),
        nim: _nim.text.trim(),
        prodi: _prodi.text.trim(),
        status: _status,
        email: _email.text.trim(),
        telepon: _telepon.text.trim(),
      ));
      messenger.showSnackBar(const SnackBar(content: Text('Profil tersimpan')));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Widget _field(TextEditingController c, String label, String? Function(String?) validator,
          {TextInputType? keyboard, IconData? icon, String? helper}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: label,
            helperText: helper,
            prefixIcon: icon == null ? null : Icon(icon),
          ),
          validator: validator,
          // Event onChanged memicu setState agar tombol Simpan ikut diperbarui.
          onChanged: (_) => setState(() {}),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_awal == null ? 'Isi Profil' : 'Edit Profil')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _field(_nama, 'Nama lengkap', ValidasiProfil.nama, icon: Icons.person_outline),
        _field(_nim, 'NIM', ValidasiProfil.nim,
            keyboard: TextInputType.number, icon: Icons.badge_outlined, helper: '7 digit, contoh 2411048'),
        _field(_prodi, 'Program studi', ValidasiProfil.prodi, icon: Icons.school_outlined),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
                labelText: 'Status mahasiswa', prefixIcon: Icon(Icons.verified_outlined)),
            items: Profil.daftarStatus
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4, bottom: 8),
          child: Text('Kontak (opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        _field(_email, 'Email', ValidasiProfil.email,
            keyboard: TextInputType.emailAddress, icon: Icons.email_outlined),
        _field(_telepon, 'Nomor HP', ValidasiProfil.telepon,
            keyboard: TextInputType.phone, icon: Icons.phone_outlined),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _valid && !_menyimpan ? _simpan : null,
          icon: const Icon(Icons.save),
          label: Text(_menyimpan ? 'Menyimpan...' : 'Simpan'),
        ),
        if (!_valid)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Tombol Simpan aktif setelah nama, NIM, dan program studi valid.',
                textAlign: TextAlign.center),
          ),
      ]),
    );
  }
}
