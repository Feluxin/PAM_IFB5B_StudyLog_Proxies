import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';
import '../../viewmodels/profil_view_model.dart';

/// Layar tambahan Materi 5: Kontak mahasiswa.
class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilViewModel>().profil;
    String isi(String? v) => (v == null || v.isEmpty) ? 'Belum diisi' : v;
    return Scaffold(
      appBar: AppBar(title: const Text('Kontak')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Nama'),
              subtitle: Text(isi(profil?.nama)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(isi(profil?.email)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Nomor HP'),
              subtitle: Text(isi(profil?.telepon)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.formProfil),
          icon: const Icon(Icons.edit),
          label: const Text('Ubah Kontak'),
        ),
      ]),
    );
  }
}
