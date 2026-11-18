import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/profil.dart';
import '../../routes.dart';
import '../../viewmodels/catatan_view_model.dart';
import '../../viewmodels/profil_view_model.dart';

/// Layar Profil: Kartu Mahasiswa (Materi 3) yang menampilkan hasil
/// Form Profil (Materi 4), dengan navigasi ke Kontak dan Detail Mata Kuliah (Materi 5).
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  /// State lokal untuk tombol "Tampilkan Salam" (Materi 3).
  bool _salam = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfilViewModel>();
    final mataKuliah = context.watch<CatatanViewModel>().daftarMataKuliah;
    final profil = vm.profil;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        actions: [
          IconButton(
            tooltip: 'Edit profil',
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.formProfil),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              _KartuMahasiswa(profil: profil),
              const SizedBox(height: 12),
              if (profil == null)
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.formProfil),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Lengkapi Profil'),
                )
              else ...[
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _salam = !_salam),
                  icon: Icon(_salam ? Icons.visibility_off : Icons.waving_hand),
                  label: Text(_salam ? 'Sembunyikan Salam' : 'Tampilkan Salam'),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _salam
                      ? Padding(
                          key: const ValueKey('salam'),
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Halo, ${profil.nama}! Selamat belajar di '
                            '${profil.prodi}, Universitas Mulia.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('kosong')),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.kontak),
                  icon: const Icon(Icons.contact_mail_outlined),
                  label: const Text('Kontak'),
                ),
              ],
              const SizedBox(height: 20),
              Text('Mata Kuliah', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              const Text('Diambil dari catatan StudyLog. Ketuk untuk melihat detail.'),
              const SizedBox(height: 8),
              for (final mk in mataKuliah)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.class_outlined),
                    title: Text(mk.nama),
                    subtitle: Text('${mk.jumlahCatatan} catatan'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.mataKuliah, arguments: mk.nama),
                  ),
                ),
            ]),
    );
  }
}

class _KartuMahasiswa extends StatelessWidget {
  final Profil? profil;
  const _KartuMahasiswa({required this.profil});

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final skema = Theme.of(context).colorScheme;
    final p = profil;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Image.asset('assets/images/logo_mulia.png', height: 88),
          const SizedBox(height: 8),
          Text('KARTU MAHASISWA',
              style: teks.labelLarge?.copyWith(letterSpacing: 2, color: skema.primary)),
          const Divider(height: 28),
          if (p == null)
            const Text('Profil belum diisi.\nTekan Lengkapi Profil untuk mengisi data.',
                textAlign: TextAlign.center)
          else ...[
            Text(p.nama, style: teks.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('NIM ${p.nim}', style: teks.titleMedium),
            const SizedBox(height: 4),
            Text(p.prodi, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Chip(
              avatar: Icon(Icons.circle, size: 12,
                  color: p.status == 'Aktif' ? Colors.green : Colors.orange),
              label: Text('Status: ${p.status}'),
            ),
          ],
        ]),
      ),
    );
  }
}
