import 'dart:async';

import 'package:appinovarh/features/telemetry/domain/entities/telemetry_data.dart';
import 'package:appinovarh/features/telemetry/domain/repositories/telemetry_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TelemetryController extends ChangeNotifier {
  final ITelemetryRepository _telemetryRepository;

  TelemetryController(this._telemetryRepository) {
    _listenToTelemetryStream();
  }

  StreamSubscription<TelemetryData>? _telemetrySubscription;

  bool _isCollecting = false;
  bool get isCollecting => _isCollecting;

  TelemetryData? _telemetryData;
  TelemetryData? get telemetryData => _telemetryData;

  String? _error;
  String? get error => _error;

  GoogleMapController? _mapController;

  void _listenToTelemetryStream() {
    _telemetrySubscription = _telemetryRepository.telemetryStream.listen(
      (data) {
        _telemetryData = data;
        _error = null; // Clear previous errors on new data
        _updateMapCamera(data);
        notifyListeners();
      },
      onError: (e) {
        _error = "Erro: $e";
        stopCollection(); // Stop on error
      },
    );
  }

  Future<void> toggleCollection() async {
    if (_isCollecting) {
      await stopCollection();
    } else {
      await startCollection();
    }
  }

  Future<void> startCollection() async {
    _isCollecting = true;
    notifyListeners();
    await _telemetryRepository.startTelemetry();
  }

  Future<void> stopCollection() async {
    await _telemetryRepository.stopTelemetry();
    _isCollecting = false;
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateMapCamera(TelemetryData data) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(data.latitude, data.longitude)),
    );
  }

  void errorShown() {
    _error = null;
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}