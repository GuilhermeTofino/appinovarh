import 'dart:async';
import 'dart:math';

import 'package:appinovarh/features/telemetry/data/datasources/location_datasource.dart';
import 'package:appinovarh/features/telemetry/data/datasources/sensor_datasource.dart';
import 'package:appinovarh/features/telemetry/domain/entities/telemetry_data.dart';
import 'package:appinovarh/features/telemetry/domain/repositories/telemetry_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';

class TelemetryRepositoryImpl implements ITelemetryRepository {
  final ILocationDataSource _locationDataSource;
  final ISensorDataSource _sensorDataSource;

  final _telemetryStreamController = StreamController<TelemetryData>.broadcast();
  StreamSubscription? _combinedSubscription;

  TelemetryRepositoryImpl(this._locationDataSource, this._sensorDataSource);

  @override
  Stream<TelemetryData> get telemetryStream => _telemetryStreamController.stream;

  @override
  Future<void> startTelemetry() async {
    try {
      await _locationDataSource.handlePermission();

      final positionStream = _locationDataSource.getPositionStream();
      final accelerometerStream = _sensorDataSource.getAccelerometerStream();
      final compassStream = _sensorDataSource.getCompassStream();

      _combinedSubscription = CombineLatestStream.combine3(
        positionStream,
        accelerometerStream,
        compassStream,
        (Position pos, UserAccelerometerEvent acc, CompassEvent compass) {
          
          final gForce = _calculateGForce(acc);

          return TelemetryData(
            latitude: pos.latitude,
            longitude: pos.longitude,
            speed: pos.speed,
            heading: pos.heading,
            accuracy: pos.accuracy,
            deviceHeading: compass.heading ?? 0.0,
            gForce: gForce,
          );
        },
      ).listen(
        (telemetryData) {
          _telemetryStreamController.add(telemetryData);
        },
        onError: (error) {
          _telemetryStreamController.addError(error);
        },
      );
    } catch (e) {
      _telemetryStreamController.addError(e);
    }
  }

  @override
  Future<void> stopTelemetry() async {
    await _combinedSubscription?.cancel();
    _combinedSubscription = null;
  }

  double _calculateGForce(UserAccelerometerEvent acc) {
    final magnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z);
    return magnitude / 9.8; // Converte m/s^2 para G-force
  }

  void dispose() {
    _telemetryStreamController.close();
  }
}