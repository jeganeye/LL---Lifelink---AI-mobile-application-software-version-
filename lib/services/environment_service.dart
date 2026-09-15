import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/environmental_reading_model.dart';

/// Environmental telemetry service.
/// Tracks ambient temperature, humidity, and air quality from simulated BME280 & MQ135 sensors.
class EnvironmentService extends ChangeNotifier {
  static final EnvironmentService _instance = EnvironmentService._internal();
  factory EnvironmentService() => _instance;

  EnvironmentService._internal() {
    _currentReading = EnvironmentalReading.defaultDemo();
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTest) {
      _startSimulation();
    }
  }

  late EnvironmentalReading _currentReading;
  Timer? _simulationTimer;
  final Random _random = Random();

  EnvironmentalReading get currentReading => _currentReading;

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Natural subtle fluctuations
      final tempDrift = (_random.nextDouble() * 0.2) - 0.1; // +/- 0.1 C
      final humDrift = (_random.nextDouble() * 1.0) - 0.5; // +/- 0.5 %

      double newTemp = (_currentReading.temperature + tempDrift).clamp(24.0, 44.0);
      double newHum = (_currentReading.humidity + humDrift).clamp(30.0, 95.0);

      String risk = _currentReading.environmentalRisk;
      if (newTemp > 38.0 || (newTemp > 35.0 && newHum > 75.0)) {
        risk = 'HIGH';
      } else if (newTemp > 33.0 || newHum > 65.0) {
        risk = 'MODERATE';
      } else {
        risk = 'LOW';
      }

      _currentReading = _currentReading.copyWith(
        temperature: double.parse(newTemp.toStringAsFixed(1)),
        humidity: double.parse(newHum.toStringAsFixed(1)),
        environmentalRisk: risk,
        timestamp: DateTime.now(),
      );

      notifyListeners();
    });
  }

  /// Trigger extreme ambient conditions for demonstration
  void setHeatWaveScenario() {
    _currentReading = _currentReading.copyWith(
      temperature: 39.5,
      humidity: 82.0,
      airQuality: 'Poor',
      aqiValue: 132,
      environmentalRisk: 'HIGH',
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  /// Alias for hackathon demo compatibility
  void triggerHeatWaveSimulation() => setHeatWaveScenario();

  /// Reset to standard baseline
  void resetToBaseline() {
    _currentReading = EnvironmentalReading.defaultDemo();
    notifyListeners();
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

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
