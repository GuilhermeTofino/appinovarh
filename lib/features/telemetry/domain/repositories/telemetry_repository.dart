import 'package:appinovarh/features/telemetry/domain/entities/telemetry_data.dart';


abstract class ITelemetryRepository {
  /// Um stream que emite dados de telemetria combinados.
  Stream<TelemetryData> get telemetryStream;

  /// Inicia a coleta de dados dos sensores.
  Future<void> startTelemetry();

  /// Para a coleta de dados dos sensores.
  Future<void> stopTelemetry();
}