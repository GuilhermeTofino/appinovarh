import 'dart:async';

import 'package:appinovarh/features/telemetry/domain/entities/telemetry_data.dart';
import 'package:appinovarh/features/telemetry/domain/repositories/telemetry_repository.dart';
import 'package:appinovarh/features/telemetry/presentation/controllers/telemetry_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'telemetry_controller_test.mocks.dart';

// 1. Anotação para gerar o mock
@GenerateMocks([ITelemetryRepository])
void main() {
  // 2. Declaração das variáveis de teste
  late MockITelemetryRepository mockTelemetryRepository;
  late TelemetryController telemetryController;
  late StreamController<TelemetryData> telemetryStreamController;

  // 3. Configuração inicial para cada teste
  setUp(() {
    mockTelemetryRepository = MockITelemetryRepository();
    telemetryStreamController = StreamController<TelemetryData>.broadcast();

    // Stub (simula) o getter do stream para retornar nosso controller
    when(mockTelemetryRepository.telemetryStream)
        .thenAnswer((_) => telemetryStreamController.stream);

    telemetryController = TelemetryController(mockTelemetryRepository);
  });

  tearDown(() {
    telemetryStreamController.close();
    telemetryController.dispose();
  });

  // Dummy data para os testes
  const tTelemetryData = TelemetryData(
    latitude: -23.5,
    longitude: -46.6,
    speed: 15.0,
    heading: 90.0,
    deviceHeading: 95.0,
    gForce: 1.1,
    accuracy: 5.0,
  );

  test('O estado inicial deve ser o correto', () {
    // Assert
    expect(telemetryController.isCollecting, isFalse);
    expect(telemetryController.telemetryData, isNull);
    expect(telemetryController.error, isNull);
  });

  group('Controle de Coleta', () {
    test(
        'startCollection deve mudar isCollecting para true e chamar o repositório',
        () async {
      // Arrange
      when(mockTelemetryRepository.startTelemetry())
          .thenAnswer((_) async => {});

      // Act
      await telemetryController.startCollection();

      // Assert
      expect(telemetryController.isCollecting, isTrue);
      verify(mockTelemetryRepository.startTelemetry()).called(1);
    });

    test(
        'stopCollection deve mudar isCollecting para false e chamar o repositório',
        () async {
      // Arrange
      // Primeiro, inicia a coleta para poder parar
      await telemetryController.startCollection();
      when(mockTelemetryRepository.stopTelemetry()).thenAnswer((_) async => {});

      // Act
      await telemetryController.stopCollection();

      // Assert
      expect(telemetryController.isCollecting, isFalse);
      verify(mockTelemetryRepository.stopTelemetry()).called(1);
    });
  });

  group('Manipulação do Stream', () {
    test('Deve atualizar telemetryData quando o stream emitir dados', () async {
      // Arrange
      // Garante que o teste vai esperar pelo evento do stream
      final future = telemetryController.telemetryData;

      // Act
      telemetryStreamController.add(tTelemetryData);

      // Assert
      // Aguarda um ciclo de eventos para o listener do stream ser processado
      await Future.delayed(Duration.zero);
      expect(telemetryController.telemetryData, tTelemetryData);
      expect(telemetryController.error, isNull);
    });

    test('Deve atualizar o erro e parar a coleta quando o stream emitir um erro',
        () async {
      // Arrange
      final exception = Exception('Falha no GPS');
      await telemetryController.startCollection(); // Simula que estava coletando
      when(mockTelemetryRepository.stopTelemetry()).thenAnswer((_) async => {});

      // Act
      telemetryStreamController.addError(exception);

      // Assert
      await Future.delayed(Duration.zero);
      expect(telemetryController.error, 'Erro: $exception');
      expect(telemetryController.isCollecting, isFalse);
      verify(mockTelemetryRepository.stopTelemetry()).called(1);
    });

    test('Deve notificar os listeners quando o estado muda', () {
      // Arrange
      int listenerCallCount = 0;
      telemetryController.addListener(() => listenerCallCount++);

      // Act
      telemetryStreamController.add(tTelemetryData);

      // Assert
      expect(listenerCallCount, 1);
    });
  });
}