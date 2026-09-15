import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/health_reading_model.dart';
import '../models/risk_status.dart';

/// Health telemetry service.
/// Provides real-time simulated telemetry from wearable sensors:
/// - MAX30102: Heart Rate & SpO2
/// - BME280: Body / Ambient Temperature
/// - MPU6050: Activity & Motion
/// - MQ135: Air Quality Index
///
/// NOTE FOR FUTURE HARDWARE / BACKEND INTEGRATION:
/// 1. Replace the simulated [_updateTimer] with ESP32 Bluetooth Low Energy (BLE) GATT stream
///    or WebSocket connection to FastAPI backend (`wss://api.lifelink.ai/ws/telemetry`).
/// 2. Stream incoming packets through [HealthReading.fromJson].
class HealthDataService extends ChangeNotifier {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal() {
    _initHistory();
    _startSimulation();
  }

  late HealthReading _currentReading;
  final List<HealthReading> _history = [];
  Timer? _simulationTimer;
  final Random _random = Random();

  HealthReading get currentReading => _currentReading;
  List<HealthReading> get history => List.unmodifiable(_history);

  void _initHistory() {
    _currentReading = HealthReading.defaultDemo();
    final now = DateTime.now();

    // Populate past 12 readings for trends & history cards
    for (int i = 12; i >= 1; i--) {
      final time = now.subtract(Duration(hours: i * 2));
      _history.add(
        HealthReading(
          heartRate: 72.0 + _random.nextInt(12),
          spo2: 97.0 + _random.nextInt(3),
          temperature: 36.5 + (_random.nextInt(4) / 10.0),
          activity: i % 3 == 0 ? 'Resting' : (i % 2 == 0 ? 'Walking' : 'Normal'),
          airQuality: 'Good',
          aqiValue: 35 + _random.nextInt(20),
          riskStatus: RiskStatus.normal,
          timestamp: time,
          isWearableConnected: true,
        ),
      );
    }
  }

  /// Starts realistic simulated telemetry updates every 3 seconds.
  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_currentReading.isWearableConnected) return;

      // Slight natural variations around baseline
      final hrDelta = (_random.nextDouble() * 2) - 1.0; // +/- 1 BPM
      final tempDelta = (_random.nextDouble() * 0.1) - 0.05;

      double newHr = (_currentReading.heartRate + hrDelta).clamp(65.0, 130.0);
      double newSpo2 = (98.0 + (_random.nextInt(2) - 0.5)).clamp(94.0, 100.0);
      double newTemp = (_currentReading.temperature + tempDelta).clamp(36.2, 38.5);

      // Keep user-overridden risk status or compute automatically
      RiskStatus status = _currentReading.riskStatus;
      if (status == RiskStatus.normal) {
        if (newHr > 105 || newSpo2 < 95) {
          status = RiskStatus.warning;
        }
      }

      _currentReading = _currentReading.copyWith(
        heartRate: double.parse(newHr.toStringAsFixed(1)),
        spo2: double.parse(newSpo2.toStringAsFixed(1)),
        temperature: double.parse(newTemp.toStringAsFixed(1)),
        timestamp: DateTime.now(),
        riskStatus: status,
      );

      notifyListeners();
    });
  }

  /// Hackathon Demonstration Trigger: Manually switch risk mode to showcase UI states
  void setSimulatedRiskStatus(RiskStatus status) {
    double hr = 78.0;
    double spo2 = 98.0;
    double temp = 36.7;
    String aqi = 'Good';

    if (status == RiskStatus.warning) {
      hr = 108.0;
      spo2 = 94.0;
      temp = 38.2;
      aqi = 'Moderate';
    } else if (status == RiskStatus.emergency) {
      hr = 138.0;
      spo2 = 89.0;
      temp = 39.4;
      aqi = 'Poor';
    }

    _currentReading = _currentReading.copyWith(
      riskStatus: status,
      heartRate: hr,
      spo2: spo2,
      temperature: temp,
      airQuality: aqi,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  /// Toggle wearable connection for demonstration
  void toggleWearableConnection() {
    _currentReading = _currentReading.copyWith(
      isWearableConnected: !_currentReading.isWearableConnected,
    );
    notifyListeners();
  }

  /// Stops the periodic simulation timer (useful for tests and background pausing)
  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Resumes the periodic simulation timer
  void resumeSimulation() {
    if (_simulationTimer == null || !_simulationTimer!.isActive) {
      _startSimulation();
    }
  }

  @override
  void dispose() {
    stopSimulation();
    super.dispose();
  }
}
