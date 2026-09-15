import 'package:flutter/material.dart';

/// An explainable item in the emergency evidence checklist.
class EvidenceItem {
  final String label;
  final bool isPresent;
  final bool isAvailable;
  final IconData icon;
  final String? detailsText;

  const EvidenceItem({
    required this.label,
    required this.isPresent,
    this.isAvailable = true,
    this.icon = Icons.check_circle_outline,
    this.detailsText,
  });

  bool get isSupported => isPresent;
  String get details =>
      detailsText ??
      (isAvailable
          ? (isPresent ? 'Active / Confirmed' : 'Baseline / Normal')
          : 'Sensor Detached / Unavailable');

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'is_present': isPresent,
      'is_available': isAvailable,
      'details': details,
    };
  }
}

/// Structured evidence used by the context-aware emergency risk engine.
class EmergencyEvidence {
  final bool isFallDetected;
  final bool isHrAvailable;
  final double? heartRate;
  final String orientation; // e.g. 'Abnormal Lateral / Prone' vs 'Normal Upright'
  final String activityState; // e.g. 'Inactivity Detected (Stationary > 15s)' vs 'Normal Motion'
  final String safetyPromptResponse; // e.g. 'No Response / Timeout' vs 'Responded OK'
  final double ambientTemp;
  final double humidity;
  final String airQuality;
  final bool isGpsAvailable;
  final double? latitude;
  final double? longitude;
  final String assessmentExplanation;
  final List<EvidenceItem> evidenceChecklist;

  const EmergencyEvidence({
    required this.isFallDetected,
    required this.isHrAvailable,
    this.heartRate,
    required this.orientation,
    required this.activityState,
    required this.safetyPromptResponse,
    required this.ambientTemp,
    required this.humidity,
    required this.airQuality,
    required this.isGpsAvailable,
    this.latitude,
    this.longitude,
    required this.assessmentExplanation,
    required this.evidenceChecklist,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_fall_detected': isFallDetected,
      'is_hr_available': isHrAvailable,
      'heart_rate': heartRate,
      'orientation': orientation,
      'activity_state': activityState,
      'safety_prompt_response': safetyPromptResponse,
      'ambient_temp': ambientTemp,
      'humidity': humidity,
      'air_quality': airQuality,
      'is_gps_available': isGpsAvailable,
      'latitude': latitude,
      'longitude': longitude,
      'assessment_explanation': assessmentExplanation,
      'evidence_checklist': evidenceChecklist.map((e) => e.toJson()).toList(),
    };
  }

  /// Generates the standard explainability checklist
  static List<EvidenceItem> buildStandardChecklist({
    required bool fallDetected,
    required bool hrAvailable,
    required bool abnormalOrientation,
    required bool inactivityDetected,
    required bool noSafetyResponse,
    required bool highTemp,
    required bool gpsAvailable,
  }) {
    return [
      EvidenceItem(
        label: fallDetected ? 'Fall detected (MPU6050 trigger)' : 'No fall detected',
        isPresent: fallDetected,
        isAvailable: true,
        icon: Icons.personal_injury_rounded,
      ),
      EvidenceItem(
        label: abnormalOrientation
            ? 'Abnormal orientation (Lateral prone posture)'
            : 'Normal upright orientation',
        isPresent: abnormalOrientation,
        isAvailable: true,
        icon: Icons.screen_rotation_rounded,
      ),
      EvidenceItem(
        label: inactivityDetected
            ? 'Inactivity detected (Stationary > 15s post-impact)'
            : 'Normal active movement',
        isPresent: inactivityDetected,
        isAvailable: true,
        icon: Icons.accessibility_new_rounded,
      ),
      EvidenceItem(
        label: noSafetyResponse
            ? 'No safety response (Prompt timed out without acknowledgment)'
            : 'Safety response confirmed',
        isPresent: noSafetyResponse,
        isAvailable: true,
        icon: Icons.notification_important_rounded,
      ),
      EvidenceItem(
        label: highTemp
            ? 'Elevated environmental heat stress (Ambient > 38°C)'
            : 'Normal ambient temperature',
        isPresent: highTemp,
        isAvailable: true,
        icon: Icons.thermostat_rounded,
      ),
      EvidenceItem(
        label: gpsAvailable
            ? 'GPS location available & locked (Anna Nagar, Chennai)'
            : 'GPS location searching...',
        isPresent: gpsAvailable,
        isAvailable: true,
        icon: Icons.gps_fixed_rounded,
      ),
      EvidenceItem(
        label: hrAvailable
            ? 'Heart rate stream online'
            : 'Heart-rate data unavailable (Skin contact lost post-fall)',
        isPresent: hrAvailable,
        isAvailable: hrAvailable,
        icon: hrAvailable ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      ),
    ];
  }
}
