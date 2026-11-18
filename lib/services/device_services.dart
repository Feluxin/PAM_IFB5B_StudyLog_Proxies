import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DeviceServices {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera, imageQuality: 65, maxWidth: 1280,
    );
    if (picked == null) return null;
    final base = await getApplicationDocumentsDirectory();
    final images = Directory(p.join(base.path, 'report_photos'));
    if (!await images.exists()) await images.create(recursive: true);
    final destination = p.join(images.path,
        'report_${DateTime.now().microsecondsSinceEpoch}.jpg');
    await File(picked.path).copy(destination);
    return destination;
  }

  Future<Position?> getLocationIfAllowed() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 12)),
    );
  }
}
