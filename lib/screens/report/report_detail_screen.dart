import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/report.dart';
import '../../viewmodels/report_view_model.dart';
import 'report_widgets.dart';

class ReportDetailScreen extends StatelessWidget {
  final String localId;
  const ReportDetailScreen({super.key, required this.localId});

  Future<void> _hapus(BuildContext context, ReportViewModel vm) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus laporan lokal?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (setuju != true) return;
    await vm.remove(localId);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportViewModel>();
    final report = vm.byId(localId);
    if (report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Laporan tidak ditemukan')),
      );
    }
    final adaFoto = report.photoPath != null && File(report.photoPath!).existsSync();
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Row(children: [
          Expanded(
            child: Text(report.title, style: Theme.of(context).textTheme.headlineSmall),
          ),
          StatusChip(report.status),
        ]),
        const SizedBox(height: 12),
        Text('Kategori: ${report.category}'),
        Text('Prioritas: ${report.priority}'),
        Text('Waktu: ${formatWaktu(report.createdAt)}'),
        Text(report.latitude != null
            ? 'Lokasi: ${report.latitude!.toStringAsFixed(5)}, ${report.longitude!.toStringAsFixed(5)}'
            : 'Lokasi: tidak dicantumkan'),
        const Divider(height: 26),
        Text(report.description),
        const SizedBox(height: 16),
        if (adaFoto) Image.file(File(report.photoPath!), height: 220),
        if (report.lastError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('Kesalahan: ${report.lastError}',
                style: const TextStyle(color: Colors.red)),
          ),
        if (report.serverId != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('ID Server: ${report.serverId}'),
          ),
        const SizedBox(height: 24),
        if (!report.terkirim) ...[
          FilledButton.icon(
            onPressed: vm.busy ? null : () => vm.queueAndSend(localId),
            icon: const Icon(Icons.cloud_upload),
            label: Text(vm.busy
                ? 'Mengirim...'
                : report.status == ReportStatus.draft
                    ? 'Antrekan & Kirim'
                    : 'Coba Kirim Lagi'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: vm.busy ? null : () => _hapus(context, vm),
            icon: const Icon(Icons.delete),
            label: const Text('Hapus Lokal'),
          ),
        ],
      ]),
    );
  }
}
