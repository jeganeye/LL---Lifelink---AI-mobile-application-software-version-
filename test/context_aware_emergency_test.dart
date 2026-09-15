import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ll_lifelink_ai/models/emergency_event_model.dart';
import 'package:ll_lifelink_ai/models/emergency_evidence_model.dart';
import 'package:ll_lifelink_ai/models/environmental_reading_model.dart';
import 'package:ll_lifelink_ai/models/risk_status.dart';
import 'package:ll_lifelink_ai/screens/emergency/emergency_page.dart';
import 'package:ll_lifelink_ai/services/emergency_service.dart';
import 'package:ll_lifelink_ai/services/environment_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Context-Aware Risk Engine & Partial Sensor Availability Tests', () {
    test('Risk engine does NOT treat unavailable HR sensor data as safe when fall is detected', () {
      final service = EmergencyService();

      // Fall detected, but HR sensor contact lost with abnormal posture
      final riskWithLostSensor = service.evaluateRiskWithEvidence(
        fallDetected: true,
        hrAvailable: false,
        heartRate: null,
        abnormalOrientation: true,
        inactivityDetected: true,
        safetyPromptTimedOut: true,
        ambientTemp: 39.1,
      );

      // Must be evaluated as EMERGENCY, not ignored because of missing HR
      expect(riskWithLostSensor, equals(RiskStatus.emergency));
    });

    test('Risk engine evaluates sensor detachment without fall as warning, not safe', () {
      final service = EmergencyService();

      final riskDetached = service.evaluateRiskWithEvidence(
        fallDetected: false,
        hrAvailable: false,
        heartRate: null,
        abnormalOrientation: false,
        inactivityDetected: false,
        safetyPromptTimedOut: false,
        ambientTemp: 34.8,
      );

      expect(riskDetached, equals(RiskStatus.warning));
    });

    test('Risk engine evaluates normal baseline as RiskStatus.normal', () {
      final service = EmergencyService();

      final normalRisk = service.evaluateRiskWithEvidence(
        fallDetected: false,
        hrAvailable: true,
        heartRate: 75.0,
        abnormalOrientation: false,
        inactivityDetected: false,
        safetyPromptTimedOut: false,
        ambientTemp: 34.8,
      );

      expect(normalRisk, equals(RiskStatus.normal));
    });

    test('Simulate Fall and Lost Pulse scenario generates complete event evidence and caregiver alert', () {
      final service = EmergencyService();

      service.simulateFallAndLostPulseScenario();

      // Safety prompt is immediately triggered
      expect(service.isSafetyPromptActive, isTrue);

      final EmergencyEvidence evidence = service.currentEvidence;
      expect(evidence.isFallDetected, isTrue);
      expect(evidence.isHrAvailable, isFalse);
      expect(evidence.heartRate, isNull);
      expect(evidence.ambientTemp, equals(39.1));
      expect(evidence.humidity, equals(68.0));
      expect(evidence.airQuality, equals('Poor'));
      expect(evidence.assessmentExplanation, contains('Heart-rate data is currently unavailable'));

      // Check checklist items
      final checklist = evidence.evidenceChecklist;
      expect(checklist.any((item) => item.label.contains('Fall detected')), isTrue);
      expect(checklist.any((item) => item.label.contains('Heart-rate data unavailable')), isTrue);
      expect(checklist.any((item) => item.label.contains('Inactivity detected')), isTrue);

      // Clean up timer by responding to safety prompt
      service.respondToSafetyPrompt(true);
      expect(service.isSafetyPromptActive, isFalse);
    });

    test('EnvironmentService tracks ambient parameters and triggers heat-wave scenario', () {
      final envService = EnvironmentService();

      expect(envService.currentReading.temperature, greaterThan(20.0));
      expect(envService.currentReading.humidity, greaterThan(30.0));

      envService.triggerHeatWaveSimulation();
      expect(envService.currentReading.temperature, equals(39.5));
      expect(envService.currentReading.humidity, equals(82.0));
      expect(envService.currentReading.isHeatWaveRisk, isTrue);
      expect(envService.currentReading.riskLevel, equals(RiskStatus.emergency));

      envService.resetToBaseline();
      expect(envService.currentReading.temperature, equals(34.8));
    });

    test('EmergencyEvent serializes and deserializes environmental context and evidence correctly', () {
      final event = EmergencyEvent(
        id: 'TEST-EV-01',
        triggerType: 'Fall Impact & Sensor Lost',
        timestamp: DateTime.now(),
        status: 'Critical Alert Escalated',
        latitude: 13.0827,
        longitude: 80.2707,
        locationAddress: 'IIT Madras Research Park, Chennai',
        heartRateAtEvent: 0.0,
        environmentalContext: EnvironmentalReading.defaultDemo(),
        caregiverAlertStatus: 'Caregiver Alert: DEMO — Emergency notification prepared',
      );

      final json = event.toJson();
      final reconstructed = EmergencyEvent.fromJson(json);

      expect(reconstructed.id, equals('TEST-EV-01'));
      expect(reconstructed.environmentalContext, isNotNull);
      expect(reconstructed.environmentalContext!.temperature, equals(34.8));
      expect(reconstructed.caregiverAlertStatus, contains('Caregiver Alert'));
    });
  });

  group('EmergencyPage Widget Tests', () {
    testWidgets('EmergencyPage renders SOS button, demo scenario, evidence checklist, and caregiver badge',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: EmergencyPage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Header & SOS button
      expect(find.text('Emergency Assistance'), findsOneWidget);
      expect(find.text('TAP TO TRIGGER EMERGENCY SOS'), findsOneWidget);

      // Verify Demo Scenario Card
      expect(find.text('SIH 2026 Demonstration Scenario'), findsOneWidget);
      expect(find.text('RUN FALL + LOST SENSOR SCENARIO'), findsOneWidget);

      // Verify Evidence Used card
      expect(find.text('Evidence Used in Assessment'), findsOneWidget);
      expect(find.text('Multi-sensor fusion evaluation checklist for explainable AI triage:'), findsOneWidget);

      // Verify Environmental context card
      expect(find.text('Environmental Context at Event'), findsOneWidget);
      expect(find.text('Ambient Temp'), findsWidgets);
      expect(find.text('Rel. Humidity'), findsWidgets);

      // Verify Caregiver Alert Card
      expect(find.text('Caregiver Alert: DEMO — Emergency notification prepared'), findsWidgets);
      expect(find.text('Priya Sharma (Daughter)'), findsWidgets);
    });
  });
}
