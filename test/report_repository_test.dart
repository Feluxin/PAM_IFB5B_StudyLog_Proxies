// Uji alur sinkronisasi Campus Report tanpa SQLite dan tanpa jaringan:
// sumber lokal dan API diganti tiruan (fake) di memori.
import 'package:flutter_test/flutter_test.dart';
import 'package:studylog_flutter/data/database_helper.dart';
import 'package:studylog_flutter/data/report_local_source.dart';
import 'package:studylog_flutter/data/report_repository.dart';
import 'package:studylog_flutter/models/report.dart';
import 'package:studylog_flutter/services/report_api_service.dart';

class FakeLocal implements ReportLocalSource {
  final Map<String, FacilityReport> rows = {};
  final List<String> riwayat = [];

  @override
  DatabaseHelper get helper => throw UnimplementedError();

  @override
  Future<List<FacilityReport>> all() async => rows.values.toList();

  @override
  Future<List<FacilityReport>> awaitingSync() async => rows.values
      .where((r) => r.status == ReportStatus.pending || r.status == ReportStatus.failed)
      .toList();

  @override
  Future<void> insert(FacilityReport report) async => rows[report.localId] = report;

  @override
  Future<void> delete(String localId) async => rows.remove(localId);

  @override
  Future<void> recoverInterruptedSending() async {
    for (final r in rows.values.toList()) {
      if (r.status == ReportStatus.sending) {
        await setStatus(r.localId, ReportStatus.failed,
            lastError: 'Pengiriman sebelumnya terputus');
      }
    }
  }

  @override
  Future<void> setStatus(String localId, String status,
      {String? serverId, String? lastError}) async {
    final r = rows[localId]!;
    riwayat.add(status);
    rows[localId] = FacilityReport.fromMap({
      ...r.toMap(),
      'status': status,
      'server_id': serverId,
      'last_error': lastError,
    });
  }
}

/// Server tiruan: menyimpan serverId per clientReportId (idempoten).
class FakeApi implements ReportApiService {
  bool online = false;
  final Map<String, String> server = {};

  @override
  String get baseUrl => 'http://fake';

  @override
  Future<String> send(FacilityReport report) async {
    if (!online) throw Exception('Connection refused');
    return server.putIfAbsent(report.localId, () => 'srv-${server.length + 1}');
  }
}

void main() {
  late FakeLocal local;
  late FakeApi api;
  late ReportRepository repo;

  setUp(() {
    local = FakeLocal();
    api = FakeApi();
    repo = ReportRepository(local, api);
  });

  Future<FacilityReport> draft() => repo.saveDraft(
        title: 'Lampu lab padam',
        category: 'Laboratorium',
        description: 'Lampu laboratorium komputer padam sejak pagi',
        priority: 'Tinggi',
      );

  test('AT-01: laporan baru tersimpan lokal sebagai DRAFT tanpa API', () async {
    final r = await draft();
    expect(local.rows[r.localId]!.status, ReportStatus.draft);
    expect(local.rows[r.localId]!.latitude, isNull); // lokasi boleh kosong (AT-03)
  });

  test('AT-05: API mati -> FAILED, data lokal tetap utuh', () async {
    final r = await draft();
    await repo.queue(r.localId);
    await repo.syncQueued();
    final hasil = local.rows[r.localId]!;
    expect(hasil.status, ReportStatus.failed);
    expect(hasil.lastError, contains('Connection refused'));
    expect(hasil.title, 'Lampu lab padam');
    expect(local.riwayat, [ReportStatus.pending, ReportStatus.sending, ReportStatus.failed]);
  });

  test('AT-06 & AT-07: retry -> SUCCESS dengan serverId yang sama, tanpa duplikasi', () async {
    final r = await draft();
    await repo.queue(r.localId);
    await repo.syncQueued(); // gagal
    api.online = true;
    await repo.syncQueued(); // retry
    final pertama = local.rows[r.localId]!;
    expect(pertama.status, ReportStatus.success);
    expect(pertama.serverId, 'srv-1');

    // Kirim ulang laporan yang sama (misalnya respons hilang) -> server
    // mengembalikan serverId yang sama dan tidak membuat data baru.
    await repo.queue(r.localId);
    await repo.syncQueued();
    expect(local.rows[r.localId]!.serverId, 'srv-1');
    expect(api.server.length, 1);
  });

  test('App terhenti saat SENDING -> dipulihkan menjadi FAILED saat startup', () async {
    final r = await draft();
    await local.setStatus(r.localId, ReportStatus.sending);
    await repo.initialize();
    expect(local.rows[r.localId]!.status, ReportStatus.failed);
  });

  test('DRAFT tidak ikut terkirim sebelum diantrekan', () async {
    final r = await draft();
    api.online = true;
    await repo.syncQueued();
    expect(local.rows[r.localId]!.status, ReportStatus.draft);
    expect(api.server, isEmpty);
  });
}
