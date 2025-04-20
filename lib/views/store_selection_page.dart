// lib/views/store_selection_page.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/config.dart';
import 'dashboard.dart';

/// Model untuk Store
class Store {
  final int id;
  final String name;
  final bool isOpen;
  final String? openingTime;
  final String? closingTime;
  final double? latitude;
  final double? longitude;
  final double? distance;

  Store({
    required this.id,
    required this.name,
    required this.isOpen,
    this.openingTime,
    this.closingTime,
    this.latitude,
    this.longitude,
    this.distance,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    // helper untuk parse angka yang bisa berupa String dengan koma/titik
    double? parseNum(dynamic raw) {
      if (raw == null) return null;
      final s = raw.toString().replaceAll(',', '.');
      return double.tryParse(s);
    }

    return Store(
      id: json['id'] as int,
      name: json['store_name'] as String,
      isOpen:
          json['is_open'] is bool
              ? json['is_open'] as bool
              : (json['is_open'].toString() == '1'),
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      latitude: parseNum(json['latitude']),
      longitude: parseNum(json['longitude']),
      distance: parseNum(json['distance']),
    );
  }
}

class StoreSelectionPage extends StatefulWidget {
  const StoreSelectionPage({Key? key}) : super(key: key);

  @override
  _StoreSelectionPageState createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends State<StoreSelectionPage> {
  List<Store> _stores = [];
  bool _loading = true;
  String? _error;
  int? _selectedStoreId;

  @override
  void initState() {
    super.initState();
    _loadSelectedStore();
    _fetchStores();
  }

  Future<void> _loadSelectedStore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedStoreId = prefs.getInt('selected_store_id');
    });
  }

  Future<void> _fetchStores() async {
    try {
      // 1) Ambil posisi user
      final pos = await _determinePosition();

      // 2) Panggil /api/stores/nearby
      final uriNear = Uri.parse(
        '${Config.baseUrl}/api/stores/nearby'
        '?lat=${pos.latitude}&lng=${pos.longitude}',
      );
      final respNear = await http.get(uriNear);

      if (respNear.statusCode == 200) {
        final List data = json.decode(respNear.body);
        _stores = data.map((e) => Store.fromJson(e)).toList();
      } else {
        throw Exception('Nearby failed: ${respNear.statusCode}');
      }
    } catch (_) {
      // fallback ke GET /api/stores
      try {
        final uriAll = Uri.parse('${Config.baseUrl}/api/stores');
        final respAll = await http.get(uriAll);

        if (respAll.statusCode == 200) {
          final List data = json.decode(respAll.body);
          _stores = data.map((e) => Store.fromJson(e)).toList();
        } else {
          throw Exception('All stores failed: ${respAll.statusCode}');
        }
      } catch (er) {
        _error = er.toString();
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location services disabled';
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw 'Location permission denied';
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied';
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _selectStore(Store store) async {
    // Simpan ID store yang dipilih
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_store_id', store.id);
    setState(() => _selectedStoreId = store.id);

    // Tampilkan notifikasi
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Store "${store.name}" dipilih')));

    // Navigasi ke Dashboard, menggantikan halaman ini
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Store'),
        backgroundColor: primary,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : (_error != null)
              ? Center(child: Text('Error: $_error'))
              : ListView.separated(
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: _stores.length,
                itemBuilder: (context, i) {
                  final s = _stores[i];
                  return ListTile(
                    title: Text(s.name),
                    subtitle:
                        s.distance != null
                            ? Text('${s.distance!.toStringAsFixed(1)} km')
                            : null,
                    trailing:
                        s.id == _selectedStoreId
                            ? Icon(Icons.check, color: primary)
                            : null,
                    onTap: () => _selectStore(s),
                  );
                },
              ),
    );
  }
}
