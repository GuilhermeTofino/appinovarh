import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

abstract class ISensorDataSource {
  Stream<UserAccelerometerEvent> getAccelerometerStream();
  Stream<CompassEvent> getCompassStream();
}

class SensorDataSource implements ISensorDataSource {
  @override
  Stream<UserAccelerometerEvent> getAccelerometerStream() {
    return userAccelerometerEvents;
  }

  @override
  Stream<CompassEvent> getCompassStream() {
    return FlutterCompass.events ??
        Stream.error('Bússola não disponível neste dispositivo.');
  }
}