/// Model representing the low-cost ESP32 wearable device status.
class WearableDevice {
  final String deviceName;
  final String deviceId;
  final bool isConnected;
  final int batteryLevel; // 0-100%
  final String firmwareVersion;
  final bool isHeartRateSensorOk;
  final bool isSpO2SensorOk;
  final bool isMotionSensorOk;
  final bool isTemperatureSensorOk;
  final bool isAirQualitySensorOk;
  final DateTime lastSyncTime;

  const WearableDevice({
    required this.deviceName,
    required this.deviceId,
    required this.isConnected,
    required this.batteryLevel,
    required this.firmwareVersion,
    required this.isHeartRateSensorOk,
    required this.isSpO2SensorOk,
    required this.isMotionSensorOk,
    required this.isTemperatureSensorOk,
    required this.isAirQualitySensorOk,
    required this.lastSyncTime,
  });

  factory WearableDevice.defaultDemo() {
    return WearableDevice(
      deviceName: 'LL Lifelink Watch',
      deviceId: 'ESP32-LL-9482',
      isConnected: true,
      batteryLevel: 88,
      firmwareVersion: 'v1.4.2-SIH',
      isHeartRateSensorOk: true,
      isSpO2SensorOk: true,
      isMotionSensorOk: true,
      isTemperatureSensorOk: true,
      isAirQualitySensorOk: true,
      lastSyncTime: DateTime.now(),
    );
  }

  WearableDevice copyWith({
    String? deviceName,
    String? deviceId,
    bool? isConnected,
    int? batteryLevel,
    String? firmwareVersion,
    bool? isHeartRateSensorOk,
    bool? isSpO2SensorOk,
    bool? isMotionSensorOk,
    bool? isTemperatureSensorOk,
    bool? isAirQualitySensorOk,
    DateTime? lastSyncTime,
  }) {
    return WearableDevice(
      deviceName: deviceName ?? this.deviceName,
      deviceId: deviceId ?? this.deviceId,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      isHeartRateSensorOk: isHeartRateSensorOk ?? this.isHeartRateSensorOk,
      isSpO2SensorOk: isSpO2SensorOk ?? this.isSpO2SensorOk,
      isMotionSensorOk: isMotionSensorOk ?? this.isMotionSensorOk,
      isTemperatureSensorOk: isTemperatureSensorOk ?? this.isTemperatureSensorOk,
      isAirQualitySensorOk: isAirQualitySensorOk ?? this.isAirQualitySensorOk,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_name': deviceName,
      'device_id': deviceId,
      'is_connected': isConnected,
      'battery_level': batteryLevel,
      'firmware_version': firmwareVersion,
      'heart_rate_sensor_ok': isHeartRateSensorOk,
      'spo2_sensor_ok': isSpO2SensorOk,
      'motion_sensor_ok': isMotionSensorOk,
      'temperature_sensor_ok': isTemperatureSensorOk,
      'air_quality_sensor_ok': isAirQualitySensorOk,
      'last_sync_time': lastSyncTime.toIso8601String(),
    };
  }
}
