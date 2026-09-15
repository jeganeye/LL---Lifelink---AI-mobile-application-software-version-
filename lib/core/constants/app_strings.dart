/// Centralized strings and prototype disclaimers for LL Lifelink AI.
class AppStrings {
  AppStrings._();

  static const String appName = 'LL Lifelink AI';
  static const String appTagline = 'Low-Cost Wearable & AI Health Companion';
  static const String sihHackathon = 'Smart India Hackathon 2026';

  // Prototype / Safety Disclaimers
  static const String demoModeBadge = 'PROTOTYPE DEMO MODE';
  static const String medicalDisclaimer =
      'DEMO DATA: Sensor readings shown are simulated prototype data for demonstration only. Do not use for clinical diagnosis.';
  static const String emergencyDisclaimer =
      'PROTOTYPE SOS: This simulates the emergency dispatch flow. No actual SMS or voice call will be triggered during this demo.';

  // Status Strings
  static const String statusNormal = 'NORMAL';
  static const String statusWarning = 'WARNING';
  static const String statusEmergency = 'EMERGENCY';

  // Metric Labels
  static const String heartRate = 'Heart Rate';
  static const String spo2 = 'SpO2 Oxygen';
  static const String temperature = 'Body Temperature';
  static const String activity = 'Activity Level';
  static const String airQuality = 'Air Quality';
  static const String aiRisk = 'AI Risk Status';
  static const String wearableConnection = 'Wearable Watch';

  // Subsystems
  static const String max30102 = 'MAX30102 Pulse Oximeter';
  static const String mpu6050 = 'MPU6050 IMU / Fall Sensor';
  static const String bme280 = 'BME280 Temp & Environment';
  static const String aqiSensor = 'MQ135 Gas & Air Quality';
  static const String esp32 = 'ESP32 IoT Controller';
}
