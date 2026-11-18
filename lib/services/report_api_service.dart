import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/report.dart';

/// Alamat API diambil dari --dart-define=API_BASE_URL=...
/// 10.0.2.2 adalah alamat laptop jika dilihat dari Android Emulator.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

class ReportApiService {
  final String baseUrl;
  final http.Client _client;
  ReportApiService(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();

  Future<String> send(FacilityReport report) async {
    String? photoBase64;
    if (report.photoPath != null) {
      final photo = File(report.photoPath!);
      if (await photo.exists()) {
        if (await photo.length() > 5 * 1024 * 1024) {
          throw Exception('Foto terlalu besar (maksimal 5 MB)');
        }
        photoBase64 = base64Encode(await photo.readAsBytes());
      }
    }
    final body = jsonEncode({
      'clientReportId': report.localId,
      'title': report.title,
      'category': report.category,
      'description': report.description,
      'priority': report.priority,
      'latitude': report.latitude,
      'longitude': report.longitude,
      'createdAt': report.createdAt,
      'photoBase64': photoBase64,
    });
    final response = await _client
        .post(
          Uri.parse('$baseUrl/reports'),
          headers: {
            'Content-Type': 'application/json',
            'Idempotency-Key': report.localId,
          },
          body: body,
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw HttpException('HTTP ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['serverId'] as String;
  }
}
