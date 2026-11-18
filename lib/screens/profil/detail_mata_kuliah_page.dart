import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';
import '../../viewmodels/catatan_view_model.dart';

/// Detail Mata Kuliah (Materi 5). Nama mata kuliah dikirim sebagai argumen route,
/// lalu catatan StudyLog untuk mata kuliah itu ditampilkan di sini.
class DetailMataKuliahPage extends StatelessWidget {
  final String nama;
  const DetailMataKuliahPage({super.key, required this.nama});

  @override
  Widget build(BuildContext context) {
    final catatan = context.watch<CatatanViewModel>().catatanUntuk(nama);
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mata Kuliah')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.formCatatan,
            arguments: FormCatatanArgs(mataKuliah: nama)),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 88), children: [
        Text(nama, style: teks.headlineSmall),
        const SizedBox(height: 4),
        Text('${catatan.length} catatan tersimpan'),
        const Divider(height: 28),
        if (catatan.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text('Belum ada catatan untuk mata kuliah ini.', textAlign: TextAlign.center),
          ),
        for (final c in catatan)
          Card(
            child: ListTile(
              title: Text(c.judul),
              subtitle: Text(c.isi, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.detailCatatan, arguments: c.id),
            ),
          ),
      ]),
    );
  }
}
