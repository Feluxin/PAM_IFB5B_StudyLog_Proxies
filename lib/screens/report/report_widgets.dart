import 'package:flutter/material.dart';

import '../../models/report.dart';

/// Label dan warna status agar jelas bagi pengguna dan tidak menyesatkan.
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  static const _warna = {
    ReportStatus.draft: Color(0xFF0D2457),
    ReportStatus.pending: Color(0xFFB7791F),
    ReportStatus.sending: Color(0xFF00897B),
    ReportStatus.success: Color(0xFF2E7D32),
    ReportStatus.failed: Color(0xFFC62828),
  };

  @override
  Widget build(BuildContext context) {
    final warna = _warna[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warna),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: warna, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

/// createdAt disimpan UTC ISO 8601, ditampilkan dalam waktu lokal perangkat.
String formatWaktu(String isoUtc) {
  final t = DateTime.tryParse(isoUtc)?.toLocal();
  if (t == null) return isoUtc;
  String dua(int n) => n.toString().padLeft(2, '0');
  return '${dua(t.day)}/${dua(t.month)}/${t.year} ${dua(t.hour)}:${dua(t.minute)}';
}
