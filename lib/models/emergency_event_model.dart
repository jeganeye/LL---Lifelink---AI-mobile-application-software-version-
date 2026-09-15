import 'emergency_evidence_model.dart';
import 'environmental_reading_model.dart';

/// Represents an emergency dispatch or automated safety trigger event.
class EmergencyEvent {
  final String id;
  final String triggerType; // Manual SOS, Fall Detected, Heat Stress, High HR
  final DateTime timestamp;
  final String status;
  final double latitude;
  final double longitude;
  final String locationAddress;
  final double heartRateAtEvent;
  final bool isResolved;
  final EnvironmentalReading? environmentalContext;
  final EmergencyEvidence? evidence;
  final String caregiverAlertStatus;

  const EmergencyEvent({
    required this.id,
    required this.triggerType,
    required this.timestamp,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.heartRateAtEvent,
    this.isResolved = false,
    this.environmentalContext,
    this.evidence,
    this.caregiverAlertStatus = 'Caregiver Alert: DEMO — Emergency notification prepared',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trigger_type': triggerType,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
      'heart_rate_at_event': heartRateAtEvent,
      'is_resolved': isResolved,
      'environmental_context': environmentalContext?.toJson(),
      'evidence': evidence?.toJson(),
      'caregiver_alert_status': caregiverAlertStatus,
    };
  }

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) {
    return EmergencyEvent(
      id: json['id'] as String? ?? '',
      triggerType: json['trigger_type'] as String? ?? 'Manual SOS',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'Pending',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 13.0827,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 80.2707,
      locationAddress: json['location_address'] as String? ?? 'Chennai, India',
      heartRateAtEvent: (json['heart_rate_at_event'] as num?)?.toDouble() ?? 0.0,
      isResolved: json['is_resolved'] as bool? ?? false,
      environmentalContext: json['environmental_context'] != null
          ? EnvironmentalReading.fromJson(
              json['environmental_context'] as Map<String, dynamic>)
          : null,
      caregiverAlertStatus: json['caregiver_alert_status'] as String? ??
          'Caregiver Alert: DEMO — Emergency notification prepared',
    );
  }

  static List<EmergencyEvent> getDemoEvents() {
    final now = DateTime.now();
    return [
      EmergencyEvent(
        id: 'EV-1092',
        triggerType: 'Manual SOS (Demo Simulation)',
        timestamp: now.subtract(const Duration(minutes: 18)),
        status: 'Prototype alert sent to caregiver',
        latitude: 13.0827,
        longitude: 80.2707,
        locationAddress: 'IIT Madras Research Park, Chennai, India',
        heartRateAtEvent: 114.0,
        isResolved: true,
        environmentalContext: EnvironmentalReading(
          temperature: 34.8,
          humidity: 72.0,
          airQuality: 'Moderate',
          aqiValue: 68,
          environmentalRisk: 'MODERATE',
          timestamp: now.subtract(const Duration(minutes: 18)),
          locationAddress: 'IIT Madras Research Park, Chennai, India',
        ),
        caregiverAlertStatus: 'Caregiver Alert: DEMO — Emergency notification prepared',
      ),
      EmergencyEvent(
        id: 'EV-1088',
        triggerType: 'Fall Detection & Lost Skin Contact (MPU6050)',
        timestamp: now.subtract(const Duration(days: 2, hours: 4)),
        status: 'Auto-escalated based on evidence (Demo Scenario)',
        latitude: 13.0850,
        longitude: 80.2650,
        locationAddress: 'Guindy National Park Area, Chennai, India',
        heartRateAtEvent: 0.0, // HR unavailable
        isResolved: true,
        environmentalContext: EnvironmentalReading(
          temperature: 39.1,
          humidity: 68.0,
          airQuality: 'Poor',
          aqiValue: 124,
          environmentalRisk: 'HIGH',
          timestamp: now.subtract(const Duration(days: 2, hours: 4)),
          locationAddress: 'Guindy National Park Area, Chennai, India',
        ),
        evidence: EmergencyEvidence(
          isFallDetected: true,
          isHrAvailable: false,
          heartRate: null,
          orientation: 'Abnormal Lateral / Prone',
          activityState: 'Inactivity Detected (Stationary > 15s)',
          safetyPromptResponse: 'No Response / Timeout',
          ambientTemp: 39.1,
          humidity: 68.0,
          airQuality: 'Poor',
          isGpsAvailable: true,
          latitude: 13.0850,
          longitude: 80.2650,
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
        ),
        caregiverAlertStatus: 'Caregiver Alert: DEMO — SMS & Alert dispatched to Ananya Kumar',
      ),
      EmergencyEvent(
        id: 'EV-1075',
        triggerType: 'Heat-Stress Environmental Alert',
        timestamp: now.subtract(const Duration(days: 5, hours: 1)),
        status: 'Hydration advisory issued',
        latitude: 13.0604,
        longitude: 80.2496,
        locationAddress: 'T. Nagar, Chennai, India',
        heartRateAtEvent: 89.0,
        isResolved: true,
        environmentalContext: EnvironmentalReading(
          temperature: 40.2,
          humidity: 78.0,
          airQuality: 'Moderate',
          aqiValue: 88,
          environmentalRisk: 'HIGH',
          timestamp: now.subtract(const Duration(days: 5, hours: 1)),
          locationAddress: 'T. Nagar, Chennai, India',
        ),
        caregiverAlertStatus: 'Caregiver Alert: DEMO — Advisory sent',
      ),
    ];
  }
}
