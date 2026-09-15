import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../models/health_reading_model.dart';
import '../../models/risk_status.dart';
import '../../services/environment_service.dart';
import '../../services/health_data_service.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';
import '../../widgets/live_pulse_chart.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/risk_badge.dart';

/// Screen 5: LiveMonitoringPage
/// Displays real-time telemetry stream from ESP32 wearable sensors:
/// - Heart Rate (MAX30102)
/// - SpO2 (MAX30102)
/// - Temperature (BME280)
/// - Activity (MPU6050)
/// - Air Quality (MQ135)
/// - Risk Status (TinyML / Edge AI classification)
///
/// FUTURE INTEGRATION POINT:
/// Hook into FastAPI WebSocket (`wss://.../ws/telemetry`) or ESP32 BLE GATT notifications.
class LiveMonitoringPage extends StatefulWidget {
  const LiveMonitoringPage({super.key});

  @override
  State<LiveMonitoringPage> createState() => _LiveMonitoringPageState();
}

class _LiveMonitoringPageState extends State<LiveMonitoringPage> {
  final HealthDataService _healthService = HealthDataService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(loc.liveTelemetryStream),
        actions: [
          IconButton(
            tooltip: loc.selectLanguage,
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
          IconButton(
            tooltip: 'Simulate Normal / Warning / Emergency for Hackathon Demo',
            icon: const Icon(Icons.tune_rounded, color: AppColors.accent),
            onPressed: _showDemoSimulationDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(
              message: 'LIVE TELEMETRY • SIMULATED ESP32 BLE DATA STREAM',
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([_healthService, EnvironmentService()]),
                builder: (context, _) {
                  final reading = _healthService.currentReading;
                  final env = EnvironmentService().currentReading;
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      // Stream Header Bar
                      _buildStreamStatusHeader(reading),

                      const SizedBox(height: 12),

                      // Live ECG Waveform Container
                      _buildEcgVisualizer(reading),

                      const SizedBox(height: 16),

                      // Live Body Metric Grid
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.heartRate,
                              value: reading.heartRate.toStringAsFixed(0),
                              unit: 'BPM',
                              icon: Icons.favorite_rounded,
                              accentColor: AppColors.heartRate,
                              subtitle: 'MAX30102 Optical Sensor',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.spo2,
                              value: reading.spo2.toStringAsFixed(0),
                              unit: '%',
                              icon: Icons.water_drop_rounded,
                              accentColor: AppColors.spo2,
                              subtitle: 'Blood Oxygen Saturation',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.temperature,
                              value: reading.temperature.toStringAsFixed(1),
                              unit: '°C',
                              icon: Icons.thermostat_rounded,
                              accentColor: AppColors.temperature,
                              subtitle: 'BME280 Body Temp',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.activity,
                              value: reading.activity,
                              unit: '',
                              icon: Icons.directions_walk_rounded,
                              accentColor: AppColors.activity,
                              subtitle: 'MPU6050 6-Axis IMU',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Context-Aware Environmental Intelligence Section
                      _buildEnvironmentalTelemetrySection(env),

                      const SizedBox(height: 16),

                      // Future Integration Architecture Callout
                      _buildArchitectureCallout(),

                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamStatusHeader(HealthReading reading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reading.isWearableConnected
                      ? AppColors.statusNormal
                      : AppColors.statusEmergency,
                  boxShadow: [
                    BoxShadow(
                      color: (reading.isWearableConnected
                              ? AppColors.statusNormal
                              : AppColors.statusEmergency)
                          .withOpacity(0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                reading.isWearableConnected
                    ? 'ESP32 STREAM: ACTIVE'
                    : 'ESP32 STREAM: OFFLINE',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Text(
            'Updated: ${Formatters.formatTime(reading.timestamp)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcgVisualizer(HealthReading reading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monitor_heart_outlined,
                        color: AppColors.heartRate,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Live PPG / Waveform Stream',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                RiskBadge(status: reading.riskStatus, isCompact: true),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF070D1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.cardBorderDark.withOpacity(0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: LivePulseChart(
                height: 70,
                lineColor: reading.riskStatus == RiskStatus.emergency
                    ? AppColors.statusEmergency
                    : (reading.riskStatus == RiskStatus.warning
                        ? AppColors.statusWarning
                        : AppColors.heartRate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalTelemetrySection(dynamic env) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.thermostat_auto_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Environmental Air Quality',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Context-Aware Ambient Status (BME280 + MQ135)',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMutedLight,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                RiskBadge(status: env.riskLevel, isCompact: true),
              ],
            ),
            const SizedBox(height: 14),

            // Heat Wave Warning Alert Banner (if applicable)
            if (env.isHeatWaveRisk) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.statusEmergencyBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.statusEmergency.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.statusEmergency, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'HIGH HEAT INDEX (${env.heatIndexCelsius.toStringAsFixed(1)}°C) — Elevated heat exhaustion risk.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.statusEmergency,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 3-Column environmental metrics: Ambient Temp, Humidity, Air Quality
            Row(
              children: [
                Expanded(
                  child: _buildEnvMiniMetric(
                    title: 'Ambient Temp',
                    value: '${env.ambientTemperature.toStringAsFixed(1)}°C',
                    icon: Icons.device_thermostat_rounded,
                    color: env.ambientTemperature > 38 ? AppColors.temperature : AppColors.accent,
                    sensor: 'BME280',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEnvMiniMetric(
                    title: 'Rel. Humidity',
                    value: '${env.relativeHumidity.toStringAsFixed(0)}%',
                    icon: Icons.water_rounded,
                    color: AppColors.spo2,
                    sensor: 'BME280',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEnvMiniMetric(
                    title: 'Air Quality',
                    value: '${env.aqiValue} AQI',
                    subtitle: env.airQuality,
                    icon: Icons.air_rounded,
                    color: AppColors.airQuality,
                    sensor: 'MQ135',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Location Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorderDark.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Station: ${env.locationName} (${env.latitude.toStringAsFixed(3)}°N, ${env.longitude.toStringAsFixed(3)}°E)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMutedLight,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Risk: ${env.environmentalRisk}',
                    style: TextStyle(
                      color: env.riskLevel == RiskStatus.emergency
                          ? AppColors.statusEmergency
                          : (env.riskLevel == RiskStatus.warning
                              ? AppColors.statusWarning
                              : AppColors.statusNormal),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvMiniMetric({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    required String sensor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textMutedLight,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            sensor,
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              color: AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureCallout() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorderDark,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Hardware Pipeline (SIH 2026 Ready)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ESP32 → MAX30102 + MPU6050 + BME280 → Edge TinyML → FastAPI WebSocket → Flutter App.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMutedLight,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showDemoSimulationDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hackathon Demonstration Mode',
                    style: AppTextStyles.headline.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select a health or environmental state to test real-time UI adaptation:',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.check_circle,
                        color: AppColors.statusNormal),
                    title: const Text('NORMAL (Resting Vitals)'),
                    subtitle: const Text('HR: 78 BPM, SpO2: 98%, Temp: 36.7°C'),
                    onTap: () {
                      _healthService.setSimulatedRiskStatus(RiskStatus.normal);
                      EnvironmentService().resetToBaseline();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.statusWarning),
                    title: const Text('WARNING (Elevated Vitals)'),
                    subtitle: const Text('HR: 108 BPM, SpO2: 94%, Temp: 38.2°C'),
                    onTap: () {
                      _healthService.setSimulatedRiskStatus(RiskStatus.warning);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.emergency,
                        color: AppColors.statusEmergency),
                    title: const Text('EMERGENCY (Critical Arrhythmia)'),
                    subtitle: const Text('HR: 138 BPM, SpO2: 89%, Temp: 39.4°C'),
                    onTap: () {
                      _healthService.setSimulatedRiskStatus(RiskStatus.emergency);
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(color: AppColors.cardBorderDark),
                  ListTile(
                    leading: const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.statusEmergency),
                    title: const Text('ENVIRONMENT: Heat Wave (39.5°C, 75% Hum)'),
                    subtitle: const Text('Triggers context-aware environmental risk'),
                    onTap: () {
                      EnvironmentService().triggerHeatWaveSimulation();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh_rounded,
                        color: AppColors.accent),
                    title: const Text('Reset Environmental Baseline'),
                    subtitle: const Text('34.8°C, 72% Hum, Moderate AQI (Anna Nagar)'),
                    onTap: () {
                      EnvironmentService().resetToBaseline();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
