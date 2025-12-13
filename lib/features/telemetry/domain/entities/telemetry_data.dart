import 'package:equatable/equatable.dart';

class TelemetryData extends Equatable {
  final double latitude;
  final double longitude;
  final double speed; // m/s
  final double heading; // Direção do movimento (GPS)
  final double deviceHeading; // Direção do dispositivo (Bússola)
  final double gForce;
  final double accuracy;

  const TelemetryData({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.deviceHeading,
    required this.gForce,
    required this.accuracy,
  });

  @override
  List<Object?> get props =>
      [latitude, longitude, speed, heading, deviceHeading, gForce, accuracy];
}