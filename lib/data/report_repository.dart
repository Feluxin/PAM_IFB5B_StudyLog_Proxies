import 'package:uuid/uuid.dart';

import '../models/report.dart';
import '../services/report_api_service.dart';
import 'report_local_source.dart';

/// Local-first: laporan selalu disimpan ke SQLite dulu, baru dikirim ke API.
/// API tidak pernah menjadi syarat pembuatan laporan.
class ReportRepository {
  final ReportLocalSource local;
  final ReportApiService api;
  ReportRepository(this.local, this.api);

  Future<void> initialize() => local.recoverInterruptedSending();
  Future<List<FacilityReport>> all() => local.all();

  Future<FacilityReport> saveDraft({
    required String title,
    required String category,
    required String description,
    required String priority,
    String? photoPath,
    double? latitude,
    double? longitude,
  }) async {
    final report = FacilityReport(
      localId: const Uuid().v4(),
      title: title.trim(),
      category: category,
      description: description.trim(),
      priority: priority,
      photoPath: photoPath,
      latitude: latitude,
      longitude: longitude,
      status: ReportStatus.draft,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    await local.insert(report);
    return report;
  }

  Future<void> queue(String localId) =>
      local.setStatus(localId, ReportStatus.pending);

  Future<void> remove(String localId) => local.delete(localId);

  /// Mengirim semua laporan `pending` dan `failed`.
  /// localId dipakai sebagai clientReportId, sehingga pengiriman ulang
  /// laporan yang sama selalu mendapat serverId yang sama dari server.
  Future<void> syncQueued() async {
    final reports = await local.awaitingSync();
    for (final report in reports) {
      await local.setStatus(report.localId, ReportStatus.sending);
      try {
        final serverId = await api.send(report);
        await local.setStatus(report.localId, ReportStatus.success,
            serverId: serverId);
      } catch (error) {
        await local.setStatus(report.localId, ReportStatus.failed,
            lastError: '$error');
      }
    }
  }
}
