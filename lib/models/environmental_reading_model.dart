import 'risk_status.dart';

/// Model representing ambient environmental conditions captured from BME280 / MQ135 / ESP32.
class EnvironmentalReading {
  final double temperature; // Ambient temperature in °C (e.g. 34.8°C)
  final double humidity; // Relative humidity in % (e.g. 72%)
  final String airQuality; // 'Good', 'Moderate', 'Poor', 'Hazardous'
  final int aqiValue; // Numerical AQI (e.g. 68)
  final String environmentalRisk; // 'LOW', 'MODERATE', 'HIGH'
  final DateTime timestamp;
  final String locationAddress;
  final double? latitude;
  final double? longitude;

  const EnvironmentalReading({
    required this.temperature,
    required this.humidity,
    required this.airQuality,
    required this.aqiValue,
    required this.environmentalRisk,
    required this.timestamp,
    this.locationAddress = 'Anna Nagar / IIT Madras Research Park, Chennai',
    this.latitude = 13.0827,
    this.longitude = 80.2707,
  });

  double get ambientTemperature => temperature;
  double get relativeHumidity => humidity;
  String get locationName => locationAddress;
  RiskStatus get riskLevel => environmentalRisk == 'HIGH'
      ? RiskStatus.emergency
      : (environmentalRisk == 'MODERATE' ? RiskStatus.warning : RiskStatus.normal);
  double get heatIndexCelsius => temperature + (humidity * 0.1);
  bool get isHeatWaveRisk => temperature >= 38.0 || environmentalRisk == 'HIGH';

  EnvironmentalReading copyWith({
    double? temperature,
    double? humidity,
    String? airQuality,
    int? aqiValue,
    String? environmentalRisk,
    DateTime? timestamp,
    String? locationAddress,
    double? latitude,
    double? longitude,
  }) {
    return EnvironmentalReading(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      airQuality: airQuality ?? this.airQuality,
      aqiValue: aqiValue ?? this.aqiValue,
      environmentalRisk: environmentalRisk ?? this.environmentalRisk,
      timestamp: timestamp ?? this.timestamp,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'air_quality': airQuality,
      'aqi_value': aqiValue,
      'environmental_risk': environmentalRisk,
      'timestamp': timestamp.toIso8601String(),
      'location_address': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory EnvironmentalReading.fromJson(Map<String, dynamic> json) {
    return EnvironmentalReading(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 34.8,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 72.0,
      airQuality: json['air_quality'] as String? ?? 'Moderate',
      aqiValue: (json['aqi_value'] as num?)?.toInt() ?? 68,
      environmentalRisk: json['environmental_risk'] as String? ?? 'MODERATE',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      locationAddress: json['location_address'] as String? ?? 'Chennai, India',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Default realistic tropical Chennai baseline for demo
  factory EnvironmentalReading.defaultDemo() {
    return EnvironmentalReading(
      temperature: 34.8,
      humidity: 72.0,
      airQuality: 'Moderate',
      aqiValue: 68,
      environmentalRisk: 'MODERATE',
      timestamp: DateTime.now(),
      locationAddress: 'IIT Madras Research Park / Anna Nagar, Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
    );
  }
}
