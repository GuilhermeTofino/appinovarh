import 'dart:math' as math;
import 'dart:ui';
import 'package:appinovarh/core/constants/app_styles.dart';
import 'package:appinovarh/core/constants/map_styles.dart';
import 'package:appinovarh/features/telemetry/presentation/controllers/telemetry_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class TelemetryPage extends StatelessWidget {
  const TelemetryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TelemetryController>();

    if (controller.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                controller.error!,
                style: const TextStyle(color: AppStyles.primaryTextColor),
              ),
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(top: 8, right: 16, left: 16),
            ),
          );
          context.read<TelemetryController>().errorShown();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildGoogleMap(context, controller),
          _buildTopStatusPill(context, controller),
          _buildDashboard(context, controller),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context, TelemetryController controller) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: controller.telemetryData != null
            ? LatLng(
                controller.telemetryData!.latitude,
                controller.telemetryData!.longitude,
              )
            : const LatLng(-23.5505, -46.6333), // Posição inicial (São Paulo)
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (mapController) {
        context.read<TelemetryController>().setMapController(mapController);
        mapController.setMapStyle(MapStyles.darkMapStyle);
      },
    );
  }

  Widget _buildTopStatusPill(BuildContext context, TelemetryController controller) {
    final accuracy = controller.telemetryData?.accuracy;
    final statusText = controller.isCollecting
        ? (accuracy != null
              ? 'Precisão: ${accuracy.toStringAsFixed(0)}m'
              : 'Buscando GPS...')
        : 'GPS Inativo';

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppStyles.translucentBlack,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppStyles.subtleBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.gps_fixed_rounded,
                color: controller.isCollecting
                    ? AppStyles.neonGreen
                    : AppStyles.secondaryTextColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: const TextStyle(
                  color: AppStyles.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, TelemetryController controller) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              border: const Border(top: BorderSide(color: AppStyles.subtleBorder)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.isCollecting) ...[
                  _buildSpeedIndicator(context, controller),
                  const SizedBox(height: 16),
                  _buildSecondaryMetrics(context, controller),
                  const SizedBox(height: 24),
                ],
                _buildControlButton(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedIndicator(BuildContext context, TelemetryController controller) {
    final speedKmh = (controller.telemetryData?.speed ?? 0) * 3.6;
    final progress = (speedKmh / 150).clamp(
      0.0,
      1.0,
    ); // Normaliza para 0-150km/h

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              speedKmh.toStringAsFixed(0),
              style: AppStyles.monospacedStyle.copyWith(fontSize: 64, height: 1),
            ),
            const SizedBox(width: 8),
            const Text(
              'km/h',
              style: TextStyle(
                color: AppStyles.secondaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppStyles.neonGreen),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _getCardinalDirection(double? heading) {
    if (heading == null) return '---';
    // N, NE, E, SE, S, SW, W, NW
    const directions = [
      'Norte',
      'Nordeste',
      'Leste',
      'Sudeste',
      'Sul',
      'Sudoeste',
      'Oeste',
      'Noroeste',
    ];
    if (heading > 337.5 || heading <= 22.5) return directions[0];
    if (heading > 22.5 && heading <= 67.5) return directions[1];
    if (heading > 67.5 && heading <= 112.5) return directions[2];
    if (heading > 112.5 && heading <= 157.5) return directions[3];
    if (heading > 157.5 && heading <= 202.5) return directions[4];
    if (heading > 202.5 && heading <= 247.5) return directions[5];
    if (heading > 247.5 && heading <= 292.5) return directions[6];
    if (heading > 292.5 && heading <= 337.5) return directions[7];
    return '---';
  }

  String _getAccelerationValue(TelemetryController controller) {
    final gForce = controller.telemetryData?.gForce;
    if (gForce == null) return '- G';
    return '${gForce.toStringAsFixed(1)} G';
  }

  Widget _buildSecondaryMetrics(
    BuildContext context,
    TelemetryController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricItem(
          icon: Icons.timeline_rounded,
          label: 'G-Force',
          value: _getAccelerationValue(controller),
        ),
        _buildMetricItem(
          icon: Icons.navigation_rounded,
          label: 'Direção',
          value: _getCardinalDirection(controller.telemetryData?.deviceHeading),
          rotation: (controller.telemetryData?.deviceHeading ?? 0) * (math.pi / 180),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    double rotation = 0,
  }) {
    return Column(
      children: [
        Transform.rotate(
          angle: rotation,
          child: Icon(icon, color: AppStyles.neonGreen, size: 28),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppStyles.monospacedStyle.copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppStyles.secondaryTextColor, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildControlButton(BuildContext context, TelemetryController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.read<TelemetryController>().toggleCollection(),
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isCollecting
              ? Colors.red.shade400
              : AppStyles.neonGreen,
          foregroundColor: controller.isCollecting
              ? AppStyles.primaryTextColor
              : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(controller.isCollecting ? 'PARAR COLETA DE DADOS' : 'INICIAR COLETA DE DADOS'),
      ),
    );
  }
}
