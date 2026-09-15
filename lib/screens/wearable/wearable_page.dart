import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../models/wearable_device_model.dart';
import '../../services/wearable_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';

/// Screen 10: WearablePage
/// Displays hardware diagnostics and sensor subsystem health:
/// - LL Lifelink Watch (ESP32 IoT Wearable)
/// - Connection status (DEMO CONNECTED)
/// - Battery level (88%)
/// - MAX30102 Heart Rate Sensor
/// - MAX30102 SpO2 Sensor
/// - MPU6050 Motion / Fall Sensor
/// - BME280 Temperature Sensor
/// - MQ135 Air Quality Sensor
class WearablePage extends StatefulWidget {
  const WearablePage({super.key});

  @override
  State<WearablePage> createState() => _WearablePageState();
}

class _WearablePageState extends State<WearablePage> {
  final WearableService _wearableService = WearableService();
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
    });
    await _wearableService.refreshDiagnostics();
    if (!mounted) return;
    setState(() {
      _isSyncing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diagnostics synchronized with LL Lifelink Watch.'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(loc.wearableDevice),
        actions: [
          IconButton(
            tooltip: loc.selectLanguage,
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(
              message: 'ESP32 WEARABLE • SIMULATED BLE CONNECTION',
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _wearableService,
                builder: (context, _) {
                  final device = _wearableService.device;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // Hardware Hero Card
                      _buildDeviceHeroCard(device),

                      const SizedBox(height: 16),

                      // Sensor Subsystem Diagnostic Cards
                      Text(
                        'Sensor Subsystem Health (SIH 2026)',
                        style: AppTextStyles.title.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 8),

                      _buildSensorStatusTile(
                        sensorName: AppStrings.max30102,
                        description: 'Optical PPG • Heart Rate & Pulse Oximetry',
                        isHealthy: device.isHeartRateSensorOk && device.isSpO2SensorOk,
                        icon: Icons.monitor_heart_rounded,
                        accentColor: AppColors.heartRate,
                      ),

                      _buildSensorStatusTile(
                        sensorName: AppStrings.mpu6050,
                        description: '6-Axis Gyro + Accelerometer • Fall & Motion',
                        isHealthy: device.isMotionSensorOk,
                        icon: Icons.accessibility_new_rounded,
                        accentColor: AppColors.activity,
                      ),

                      _buildSensorStatusTile(
                        sensorName: AppStrings.bme280,
                        description: 'High-Precision Temperature & Humidity',
                        isHealthy: device.isTemperatureSensorOk,
                        icon: Icons.thermostat_rounded,
                        accentColor: AppColors.temperature,
                      ),

                      _buildSensorStatusTile(
                        sensorName: AppStrings.aqiSensor,
                        description: 'Gas & Air Quality (VOC / CO2 / Smoke)',
                        isHealthy: device.isAirQualitySensorOk,
                        icon: Icons.air_rounded,
                        accentColor: AppColors.airQuality,
                      ),

                      const SizedBox(height: 16),

                      // Future BLE Architecture Notice
                      _buildBleNotice(),

                      const SizedBox(height: 16),

                      // Action Button
                      CustomButton(
                        label: 'Sync Hardware Diagnostics',
                        icon: Icons.sync_rounded,
                        isLoading: _isSyncing,
                        onPressed: _handleSync,
                      ),

                      const SizedBox(height: 12),

                      CustomButton(
                        label: device.isConnected
                            ? 'Simulate Disconnect'
                            : 'Simulate Reconnect',
                        isSecondary: true,
                        onPressed: () => _wearableService.toggleConnection(),
                      ),

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

  Widget _buildDeviceHeroCard(WearableDevice device) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.surfaceDark,
              AppColors.primaryDark.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Smartwatch Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: const Icon(
                    Icons.watch_rounded,
                    size: 38,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Device ID: ${device.deviceId} • ${device.firmwareVersion}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: device.isConnected
                                  ? AppColors.statusNormal
                                  : AppColors.statusEmergency,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            device.isConnected
                                ? 'DEMO CONNECTED (BLE Ready)'
                                : 'DISCONNECTED',
                            style: AppTextStyles.caption.copyWith(
                              color: device.isConnected
                                  ? AppColors.statusNormal
                                  : AppColors.statusEmergency,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Battery and Sync Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.battery_charging_full_rounded,
                          color: AppColors.statusNormal,
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${device.batteryLevel}%',
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('LiPo Battery (~36h)', style: AppTextStyles.caption),
                  ],
                ),
                Container(height: 30, width: 1, color: AppColors.cardBorderDark),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatTime(device.lastSyncTime),
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Last Telemetry Sync', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorStatusTile({
    required String sensorName,
    required String description,
    required bool isHealthy,
    required IconData icon,
    required Color accentColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        title: Text(
          sensorName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(description, style: AppTextStyles.caption),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHealthy ? AppColors.statusNormalBg : AppColors.statusEmergencyBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHealthy ? AppColors.statusNormal : AppColors.statusEmergency,
            ),
          ),
          child: Text(
            isHealthy ? 'ONLINE' : 'ERROR',
            style: TextStyle(
              color: isHealthy ? AppColors.statusNormal : AppColors.statusEmergency,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBleNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Real ESP32 Bluetooth Low Energy (BLE) scanning and GATT telemetry pairing will be connected in Step 2.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMutedLight),
            ),
          ),
        ],
      ),
    );
  }
}
