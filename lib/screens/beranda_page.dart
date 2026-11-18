import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../viewmodels/catatan_view_model.dart';
import '../viewmodels/profil_view_model.dart';
import '../viewmodels/report_view_model.dart';

/// Beranda: satu pintu masuk untuk Profil Mahasiswa, StudyLog, dan Campus Report.
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProfilViewModel>();
    final catatan = context.watch<CatatanViewModel>().catatan.length;
    final laporan = context.watch<ReportViewModel>().belumTerkirim;
    final teks = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyLog'),
        actions: [
          IconButton(
            tooltip: 'Tentang Aplikasi',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.tentang),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Halo, ${profil.namaPanggilan}!', style: teks.headlineSmall),
        const SizedBox(height: 4),
        Text(profil.profil == null
            ? 'Lengkapi profilmu dulu, lalu catat materi dan laporkan fasilitas kampus.'
            : '${profil.profil!.prodi} • NIM ${profil.profil!.nim}'),
        const SizedBox(height: 20),
        _MenuCard(
          icon: Icons.badge_outlined,
          warna: const Color(0xFF0D47A1),
          judul: 'Profil Mahasiswa',
          deskripsi: 'Kartu mahasiswa, kontak, dan mata kuliah.',
          info: profil.profil == null ? 'Belum diisi' : 'Status: ${profil.profil!.status}',
          onTap: () => Navigator.pushNamed(context, AppRoutes.profil),
        ),
        _MenuCard(
          icon: Icons.menu_book_rounded,
          warna: const Color(0xFF4158D0),
          judul: 'StudyLog',
          deskripsi: 'Catatan materi perkuliahan per mata kuliah.',
          info: '$catatan catatan',
          onTap: () => Navigator.pushNamed(context, AppRoutes.catatan),
        ),
        _MenuCard(
          icon: Icons.report_problem_outlined,
          warna: const Color(0xFF00897B),
          judul: 'Campus Report',
          deskripsi: 'Form aduan kerusakan fasilitas kampus dengan foto dan lokasi.',
          info: '$laporan laporan belum terkirim',
          onTap: () => Navigator.pushNamed(context, AppRoutes.report),
        ),
      ]),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color warna;
  final String judul;
  final String deskripsi;
  final String info;
  final VoidCallback onTap;
  const _MenuCard({
    required this.icon,
    required this.warna,
    required this.judul,
    required this.deskripsi,
    required this.info,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: warna.withValues(alpha: 0.12),
              child: Icon(icon, color: warna, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(judul, style: teks.titleMedium),
                const SizedBox(height: 2),
                Text(deskripsi, style: teks.bodySmall),
                const SizedBox(height: 6),
                Text(info, style: teks.labelMedium?.copyWith(color: warna)),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}
