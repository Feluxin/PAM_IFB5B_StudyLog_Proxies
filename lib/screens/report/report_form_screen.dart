import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../services/device_services.dart';
import '../../viewmodels/report_view_model.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});
  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  static const kategori = ['Ruang Kelas', 'Laboratorium', 'Toilet', 'Internet', 'Lainnya'];
  static const prioritas = ['Rendah', 'Normal', 'Tinggi'];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _category = kategori.first;
  String _priority = 'Normal';
  String? _photoPath;
  Position? _position;
  bool _saving = false;
  bool _mencariLokasi = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  DeviceServices get _device => context.read<DeviceServices>();

  void _pesan(String teks) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));

  Future<void> _photo() async {
    try {
      final path = await _device.takePhoto();
      if (mounted && path != null) setState(() => _photoPath = path);
    } catch (e) {
      if (mounted) _pesan('Foto gagal: $e');
    }
  }

  Future<void> _location() async {
    setState(() => _mencariLokasi = true);
    try {
      final position = await _device.getLocationIfAllowed();
      if (!mounted) return;
      setState(() => _position = position);
      if (position == null) {
        _pesan('Lokasi tidak tersedia. Laporan tetap dapat disimpan.');
      }
    } catch (e) {
      if (mounted) _pesan('Lokasi tidak dapat diambil: $e');
    } finally {
      if (mounted) setState(() => _mencariLokasi = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await context.read<ReportViewModel>().addDraft(
            title: _title.text,
            category: _category,
            description: _description.text,
            priority: _priority,
            photoPath: _photoPath,
            latitude: _position?.latitude,
            longitude: _position?.longitude,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _pesan('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan Fasilitas')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Judul laporan'),
            validator: (v) => (v?.trim().length ?? 0) < 5 ? 'Minimal 5 karakter' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: kategori.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Prioritas'),
            items: prioritas.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _priority = v ?? _priority),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Deskripsi kerusakan'),
            validator: (v) => (v?.trim().length ?? 0) < 10 ? 'Minimal 10 karakter' : null,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _photo,
            icon: const Icon(Icons.camera_alt),
            label: Text(_photoPath == null ? 'Ambil foto (opsional)' : 'Ganti foto'),
          ),
          if (_photoPath != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.file(File(_photoPath!), height: 160),
            ),
          OutlinedButton.icon(
            onPressed: _mencariLokasi ? null : _location,
            icon: const Icon(Icons.location_on),
            label: Text(_mencariLokasi ? 'Mencari lokasi...' : 'Ambil lokasi (opsional)'),
          ),
          if (_position != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Koordinat: ${_position!.latitude.toStringAsFixed(5)}, '
                  '${_position!.longitude.toStringAsFixed(5)}'),
            ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Menyimpan...' : 'Simpan Offline'),
          ),
          const SizedBox(height: 10),
          const Text('Laporan disimpan di perangkat sebagai DRAFT. Pengiriman ke '
              'server dilakukan dari halaman detail atau tombol sinkron.'),
        ]),
      ),
    );
  }
}
