import 'risk_status.dart';

/// Health reading snapshot captured from wearable sensors or simulated demo telemetry.
class HealthReading {
  final double heartRate; // BPM (MAX30102)
  final double spo2;      // Percentage % (MAX30102)
  final double temperature; // Celsius °C (BME280)
  final String activity;  // Normal, Resting, Walking, Strenuous (MPU6050)
  final String airQuality; // Good, Moderate, Unhealthy (MQ135/BME680)
  final int aqiValue;     // AQI numeric score
  final RiskStatus riskStatus; // AI Risk Classification
  final DateTime timestamp;
  final bool isWearableConnected;

  const HealthReading({
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.activity,
    required this.airQuality,
    required this.aqiValue,
    required this.riskStatus,
    required this.timestamp,
    this.isWearableConnected = true,
  });

  /// Factory for the default SIH Hackathon demo snapshot.
  factory HealthReading.defaultDemo() {
    return HealthReading(
      heartRate: 78.0,
      spo2: 98.0,
      temperature: 36.7,
      activity: 'Normal',
      airQuality: 'Good',
      aqiValue: 42,
      riskStatus: RiskStatus.normal,
      timestamp: DateTime.now(),
      isWearableConnected: true,
    );
  }

  HealthReading copyWith({
    double? heartRate,
    double? spo2,
    double? temperature,
    String? activity,
    String? airQuality,
    int? aqiValue,
    RiskStatus? riskStatus,
    DateTime? timestamp,
    bool? isWearableConnected,
  }) {
    return HealthReading(
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      temperature: temperature ?? this.temperature,
      activity: activity ?? this.activity,
      airQuality: airQuality ?? this.airQuality,
      aqiValue: aqiValue ?? this.aqiValue,
      riskStatus: riskStatus ?? this.riskStatus,
      timestamp: timestamp ?? this.timestamp,
      isWearableConnected: isWearableConnected ?? this.isWearableConnected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heart_rate': heartRate,
      'spo2': spo2,
      'temperature': temperature,
      'activity': activity,
      'air_quality': airQuality,
      'aqi_value': aqiValue,
      'risk_status': riskStatus.label,
      'timestamp': timestamp.toIso8601String(),
      'wearable_connected': isWearableConnected,
    };
  }

  factory HealthReading.fromJson(Map<String, dynamic> json) {
    return HealthReading(
      heartRate: (json['heart_rate'] as num?)?.toDouble() ?? 78.0,
      spo2: (json['spo2'] as num?)?.toDouble() ?? 98.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 36.7,
      activity: json['activity'] as String? ?? 'Normal',
      airQuality: json['air_quality'] as String? ?? 'Good',
      aqiValue: (json['aqi_value'] as num?)?.toInt() ?? 42,
      riskStatus: RiskStatus.fromString(json['risk_status'] as String? ?? 'NORMAL'),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      isWearableConnected: json['wearable_connected'] as bool? ?? true,
    );
  }
}
