/// Status sinkronisasi laporan Campus Report.
///
/// draft   : tersimpan lokal, belum diantrekan
/// pending : diantrekan, menunggu dikirim
/// sending : sedang dikirim ke API
/// success : server sudah mengonfirmasi dan memberi serverId
/// failed  : pengiriman gagal, data lokal tetap ada dan dapat dikirim ulang
class ReportStatus {
  static const draft = 'draft';
  static const pending = 'pending';
  static const sending = 'sending';
  static const success = 'success';
  static const failed = 'failed';
}

class FacilityReport {
  final String localId;
  final String title;
  final String category;
  final String description;
  final String priority;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final String status;
  final String createdAt;
  final String? serverId;
  final String? lastError;

  const FacilityReport({
    required this.localId,
    required this.title,
    required this.category,
    required this.description,
    required this.priority,
    this.photoPath,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    this.serverId,
    this.lastError,
  });

  bool get terkirim => status == ReportStatus.success;

  Map<String, Object?> toMap() => {
        'local_id': localId,
        'title': title,
        'category': category,
        'description': description,
        'priority': priority,
        'photo_path': photoPath,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'created_at': createdAt,
        'server_id': serverId,
        'last_error': lastError,
      };

  factory FacilityReport.fromMap(Map<String, Object?> map) => FacilityReport(
        localId: map['local_id'] as String,
        title: map['title'] as String,
        category: map['category'] as String,
        description: map['description'] as String,
        priority: map['priority'] as String,
        photoPath: map['photo_path'] as String?,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        status: map['status'] as String,
        createdAt: map['created_at'] as String,
        serverId: map['server_id'] as String?,
        lastError: map['last_error'] as String?,
      );
}
