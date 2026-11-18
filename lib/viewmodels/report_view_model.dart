import 'package:flutter/foundation.dart';

import '../data/report_repository.dart';
import '../models/report.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository repo;
  ReportViewModel(this.repo);

  List<FacilityReport> _reports = [];
  List<FacilityReport> get reports => List.unmodifiable(_reports);
  bool busy = false;
  bool isLoading = false;
  String? error;

  /// Jumlah laporan yang belum dikonfirmasi server.
  int get belumTerkirim => _reports.where((r) => !r.terkirim).length;

  FacilityReport? byId(String localId) {
    for (final r in _reports) {
      if (r.localId == localId) return r;
    }
    return null;
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    try {
      await repo.initialize();
    } catch (e) {
      error = '$e';
    }
    await refresh();
  }

  Future<void> refresh() async {
    try {
      _reports = await repo.all();
      error = null;
    } catch (exception) {
      error = '$exception';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDraft({
    required String title,
    required String category,
    required String description,
    required String priority,
    String? photoPath,
    double? latitude,
    double? longitude,
  }) async {
    await repo.saveDraft(
      title: title,
      category: category,
      description: description,
      priority: priority,
      photoPath: photoPath,
      latitude: latitude,
      longitude: longitude,
    );
    await refresh();
  }

  Future<void> queueAndSend(String localId) async {
    await repo.queue(localId);
    await refresh();
    await sync();
  }

  Future<void> sync() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await repo.syncQueued();
    } finally {
      busy = false;
      await refresh();
    }
  }

  Future<void> remove(String localId) async {
    await repo.remove(localId);
    await refresh();
  }
}
