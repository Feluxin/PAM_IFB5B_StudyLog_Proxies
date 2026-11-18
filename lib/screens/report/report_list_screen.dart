import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/report_view_model.dart';
import '../../routes.dart';
import 'report_widgets.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Report (${vm.reports.length})'),
        actions: [
          IconButton(
            tooltip: 'Kirim laporan tertunda',
            onPressed: vm.busy ? null : vm.sync,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (vm.isLoading) return const Center(child: CircularProgressIndicator());
        if (vm.error != null) {
          return Center(child: Text('Gagal memuat database: ${vm.error}'));
        }
        if (vm.reports.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada laporan. Tekan Buat Laporan untuk melaporkan '
                  'kerusakan fasilitas.', textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: vm.reports.length,
          itemBuilder: (context, index) {
            final report = vm.reports[index];
            return Card(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: ListTile(
                leading: const Icon(Icons.report_problem_outlined),
                title: Text(report.title),
                subtitle: Text('${report.category} • ${formatWaktu(report.createdAt)}'),
                trailing: StatusChip(report.status),
                onTap: () => Navigator.pushNamed(context, AppRoutes.detailReport,
                    arguments: report.localId),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.formReport),
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ),
      bottomNavigationBar: vm.busy ? const LinearProgressIndicator() : null,
    );
  }
}
