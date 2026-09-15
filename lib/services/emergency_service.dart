import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/emergency_event_model.dart';
import '../models/emergency_evidence_model.dart';
import '../models/environmental_reading_model.dart';
import '../models/risk_status.dart';
import 'environment_service.dart';

/// Emergency management service with Context-Aware Risk Intelligence.
/// Coordinates SOS triggers, simulated GPS dispatch, fall detection,
/// partial sensor availability evaluation, and environmental context capture.
///
/// NOTE FOR FUTURE HARDWARE / BACKEND INTEGRATION:
/// 1. Hook into GSM Module (SIM800L / SIM7600) on the wearable for automated SMS/Call.
/// 2. Post emergency payload to FastAPI endpoint `/api/v1/emergency/dispatch`.
/// 3. Read real GPS coordinates from NEO-6M / ESP32 GPS module.
class EmergencyService extends ChangeNotifier {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;

  EmergencyService._internal() {
    _events = EmergencyEvent.getDemoEvents();
    _currentEvidence = _events.first.evidence ?? _buildDefaultEvidence();
  }

  bool _isSosTriggered = false;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;

  bool _isFallDetectionEnabled = true;
  bool _isHeatStressMonitorEnabled = true;

  // Safety Confirmation Prompt state
  bool _isSafetyPromptActive = false;
  int _safetyPromptCountdown = 10;
  Timer? _safetyPromptTimer;

  // Mock GPS Telemetry (Anna Nagar, Chennai)
  final double _latitude = 13.0827;
  final double _longitude = 80.2707;
  final String _gpsAddress = 'IIT Madras Research Park / Anna Nagar, Chennai';
  final double _gpsAccuracyMeters = 3.8;

  List<EmergencyEvent> _events = [];
  late EmergencyEvidence _currentEvidence;

  bool get isSosTriggered => _isSosTriggered;
  int get countdownSeconds => _countdownSeconds;
  bool get isFallDetectionEnabled => _isFallDetectionEnabled;
  bool get isHeatStressMonitorEnabled => _isHeatStressMonitorEnabled;

  bool get isSafetyPromptActive => _isSafetyPromptActive;
  int get safetyPromptCountdown => _safetyPromptCountdown;

  double get latitude => _latitude;
  double get longitude => _longitude;
  String get gpsAddress => _gpsAddress;
  double get gpsAccuracyMeters => _gpsAccuracyMeters;

  List<EmergencyEvent> get events => List.unmodifiable(_events);
  EmergencyEvidence get currentEvidence => _currentEvidence;

  EmergencyEvidence _buildDefaultEvidence() {
    return EmergencyEvidence(
      isFallDetected: false,
      isHrAvailable: true,
      heartRate: 78.0,
      orientation: 'Normal Upright',
      activityState: 'Normal Motion',
      safetyPromptResponse: 'Pending',
      ambientTemp: 34.8,
      humidity: 72.0,
      airQuality: 'Moderate',
      isGpsAvailable: true,
      latitude: _latitude,
      longitude: _longitude,
      assessmentExplanation:
          'Biometrics and environmental factors within normal baseline parameters.',
      evidenceChecklist: EmergencyEvidence.buildStandardChecklist(
        fallDetected: false,
        hrAvailable: true,
        abnormalOrientation: false,
        inactivityDetected: false,
        noSafetyResponse: false,
        highTemp: false,
        gpsAvailable: true,
      ),
    );
  }

  /// Initiates emergency countdown demonstration.
  void triggerSos() {
    if (_isSosTriggered) return;
    _isSosTriggered = true;
    _countdownSeconds = 5;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        _countdownSeconds--;
        notifyListeners();
      } else {
        _countdownTimer?.cancel();
        _countdownSeconds = 0;
        _dispatchSimulatedEmergency(trigger: 'Manual SOS (Prototype Simulation)');
        notifyListeners();
      }
    });
  }

  /// Cancels active SOS before or after simulated dispatch.
  void cancelSos() {
    _countdownTimer?.cancel();
    _safetyPromptTimer?.cancel();
    _isSosTriggered = false;
    _isSafetyPromptActive = false;
    _countdownSeconds = 5;
    notifyListeners();
  }

  /// User responded to safety confirmation prompt
  void respondToSafetyPrompt(bool isOk) {
    _safetyPromptTimer?.cancel();
    _isSafetyPromptActive = false;

    if (isOk) {
      cancelSos();
    } else {
      // User tapped "I NEED HELP"
      triggerSos();
    }
    notifyListeners();
  }

  /// Context-Aware Risk Evaluation Engine.
  /// Does NOT assume the person is safe if HR data is unavailable.
  RiskStatus evaluateRiskWithEvidence({
    required bool fallDetected,
    required bool hrAvailable,
    double? heartRate,
    required bool abnormalOrientation,
    required bool inactivityDetected,
    required bool safetyPromptTimedOut,
    required double ambientTemp,
  }) {
    // Critical Context-Aware Rule:
    // If fall is detected AND HR is lost, evaluate orientation + inactivity + safety response
    if (fallDetected) {
      if (!hrAvailable || (heartRate != null && (heartRate > 125 || heartRate < 45))) {
        if (abnormalOrientation || inactivityDetected || safetyPromptTimedOut) {
          return RiskStatus.emergency;
        }
      }
      return RiskStatus.warning;
    }

    if (!hrAvailable) {
      // Wearable sensor detached without fall
      return RiskStatus.warning;
    }

    if (heartRate != null && heartRate > 130) {
      return RiskStatus.emergency;
    }

    if (ambientTemp > 39.0) {
      return RiskStatus.warning;
    }

    return RiskStatus.normal;
  }

  /// REQUIRED DEMONSTRATION SCENARIO:
  /// "The person falls and the pulse sensor loses contact."
  ///
  /// Execution sequence:
  /// 1. Fall sensor detects a fall.
  /// 2. HR becomes unavailable.
  /// 3. The system does NOT assume the person is safe.
  /// 4. Check orientation (Abnormal Lateral / Prone).
  /// 5. Check inactivity (Stationary > 15s).
  /// 6. Trigger safety confirmation prompt.
  /// 7. Prompt times out (No Response).
  /// 8. Record environmental conditions (39.1°C, 68% humidity, Poor AQI).
  /// 9. Record GPS location (13.0827°N, 80.2707°E).
  /// 10. Determine risk: EMERGENCY.
  /// 11. Start SOS workflow.
  /// 12. Caregiver alert workflow prepared.
  /// 13. Display environmental conditions as event context.
  void simulateFallAndLostPulseScenario() {
    final env = EnvironmentService().currentReading.copyWith(
      temperature: 39.1,
      humidity: 68.0,
      airQuality: 'Poor',
      aqiValue: 124,
      environmentalRisk: 'HIGH',
    );

    _currentEvidence = EmergencyEvidence(
      isFallDetected: true,
      isHrAvailable: false,
      heartRate: null,
      orientation: 'Abnormal Lateral / Prone',
      activityState: 'Inactivity Detected (Stationary > 15s)',
      safetyPromptResponse: 'No Response / Timed Out (Simulated)',
      ambientTemp: 39.1,
      humidity: 68.0,
      airQuality: 'Poor',
      isGpsAvailable: true,
      latitude: _latitude,
      longitude: _longitude,
      assessmentExplanation:
          'Emergency assessment is based on the available evidence. Heart-rate data is currently unavailable, but fall, orientation, inactivity, and safety-response information are being considered.',
      evidenceChecklist: EmergencyEvidence.buildStandardChecklist(
        fallDetected: true,
        hrAvailable: false,
        abnormalOrientation: true,
        inactivityDetected: true,
        noSafetyResponse: true,
        highTemp: true,
        gpsAvailable: true,
      ),
    );

    // Trigger safety prompt modal state for user visibility
    _isSafetyPromptActive = true;
    _safetyPromptCountdown = 8;
    notifyListeners();

    _safetyPromptTimer?.cancel();
    _safetyPromptTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_safetyPromptCountdown > 1) {
        _safetyPromptCountdown--;
        notifyListeners();
      } else {
        _safetyPromptTimer?.cancel();
        _isSafetyPromptActive = false;
        // Prompt timed out -> Escalate to EMERGENCY & dispatch
        _isSosTriggered = true;
        _countdownSeconds = 0;
        _dispatchSimulatedEmergency(
          trigger: 'Fall Detected & Sensor Contact Lost',
          customEvidence: _currentEvidence,
          customEnv: env,
        );
        notifyListeners();
      }
    });
  }

  void _dispatchSimulatedEmergency({
    String trigger = 'Manual SOS (Prototype Simulation)',
    EmergencyEvidence? customEvidence,
    EnvironmentalReading? customEnv,
  }) {
    final env = customEnv ?? EnvironmentService().currentReading;
    final evidence = customEvidence ?? _currentEvidence;

    final newEvent = EmergencyEvent(
      id: 'EV-${DateTime.now().millisecondsSinceEpoch % 10000}',
      triggerType: trigger,
      timestamp: DateTime.now(),
      status: 'Critical Alert Escalated (Evidence-Assessed)',
      latitude: _latitude,
      longitude: _longitude,
      locationAddress: _gpsAddress,
      heartRateAtEvent: evidence.heartRate ?? 0.0,
      isResolved: false,
      environmentalContext: env,
      evidence: evidence,
      caregiverAlertStatus:
          'Caregiver Alert: DEMO — Emergency notification prepared & queued for Cellular dispatch',
    );
    _events.insert(0, newEvent);
    notifyListeners();
  }

  void toggleFallDetection() {
    _isFallDetectionEnabled = !_isFallDetectionEnabled;
    notifyListeners();
  }

  void toggleHeatStressMonitor() {
    _isHeatStressMonitorEnabled = !_isHeatStressMonitorEnabled;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _safetyPromptTimer?.cancel();
    super.dispose();
  }
}
