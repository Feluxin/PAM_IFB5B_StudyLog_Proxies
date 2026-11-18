import 'package:flutter_test/flutter_test.dart';
import 'package:studylog_flutter/models/report.dart';

void main() {
  test('model laporan dapat dipetakan bolak-balik ke Map SQLite', () {
    const report = FacilityReport(
      localId: 'test-1',
      title: 'Lampu rusak',
      category: 'Ruang Kelas',
      description: 'Lampu ruang kelas tidak menyala',
      priority: 'Tinggi',
      status: ReportStatus.draft,
      createdAt: '2026-11-12T00:00:00Z',
    );
    final mapped = FacilityReport.fromMap(report.toMap());
    expect(mapped.localId, 'test-1');
    expect(mapped.latitude, isNull);
    expect(mapped.photoPath, isNull);
    expect(mapped.status, ReportStatus.draft);
    expect(mapped.terkirim, isFalse);
  });
}
