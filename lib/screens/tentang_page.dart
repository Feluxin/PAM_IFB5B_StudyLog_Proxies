import 'package:flutter/material.dart';

// Halaman Tentang Aplikasi (pengayaan 4.7, dipertahankan pada M3)
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tentang Aplikasi')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text('StudyLog', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Aplikasi catatan perkuliahan offline. Catatan disimpan '
              'pada database SQLite di perangkat sehingga tetap tersedia '
              'tanpa koneksi internet.'),
          const Divider(height: 32),
          const Text('Kelompok Proxies',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Samuel Julian Kumaat (2411041)\n'
              'Albert Felix Jonathan (2411048)\n'
              'Rizky Ariello Nesta (2411058)\n'
              'Muhammad Rafli (2411073)\n'
              'Farhan Mikdam (2411078)\n'
              'Desta Adha Chandra (2411079)'),
          const Divider(height: 32),
          const Text('Pemrograman Aplikasi Bergerak\n'
              'Program Studi Informatika, Universitas Mulia'),
        ]),
      );
}
