import 'package:appinovarh/features/telemetry/data/datasources/location_datasource.dart';
import 'package:appinovarh/features/telemetry/data/datasources/sensor_datasource.dart';
import 'package:appinovarh/features/telemetry/data/repositories/telemetry_repository_impl.dart';
import 'package:appinovarh/features/telemetry/domain/repositories/telemetry_repository.dart';
import 'package:appinovarh/features/telemetry/presentation/controllers/telemetry_controller.dart';
import 'package:appinovarh/features/telemetry/presentation/pages/telemetry_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. Camada de Dados (DataSources)
        Provider<ILocationDataSource>(create: (_) => LocationDataSource()),
        Provider<ISensorDataSource>(create: (_) => SensorDataSource()),

        // 2. Camada de Dados (Repository)
        Provider<ITelemetryRepository>(
          create: (context) => TelemetryRepositoryImpl(
            context.read<ILocationDataSource>(),
            context.read<ISensorDataSource>(),
          ),
        ),

        // 3. Camada de Apresentação (Controller)
        ChangeNotifierProvider<TelemetryController>(
          create: (context) => TelemetryController(
            context.read<ITelemetryRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo de Telemetria',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelemetryPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
