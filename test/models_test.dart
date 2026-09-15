import 'package:flutter_test/flutter_test.dart';
import 'package:ll_lifelink_ai/models/caregiver_model.dart';
import 'package:ll_lifelink_ai/models/emergency_event_model.dart';
import 'package:ll_lifelink_ai/models/health_reading_model.dart';
import 'package:ll_lifelink_ai/models/medication_model.dart';
import 'package:ll_lifelink_ai/models/notification_model.dart';
import 'package:ll_lifelink_ai/models/risk_status.dart';
import 'package:ll_lifelink_ai/models/user_model.dart';
import 'package:ll_lifelink_ai/models/wearable_device_model.dart';

void main() {
  group('LL Lifelink AI - Data Model Unit Tests', () {
    test('RiskStatus enum labels and conversion', () {
      expect(RiskStatus.normal.label, 'NORMAL');
      expect(RiskStatus.warning.label, 'WARNING');
      expect(RiskStatus.emergency.label, 'EMERGENCY');

      expect(RiskStatus.fromString('NORMAL'), RiskStatus.normal);
      expect(RiskStatus.fromString('warning'), RiskStatus.warning);
      expect(RiskStatus.fromString('EMERGENCY'), RiskStatus.emergency);
      expect(RiskStatus.fromString('unknown'), RiskStatus.normal);
    });

    test('HealthReading default demo baseline and JSON serialization', () {
      final demo = HealthReading.defaultDemo();
      expect(demo.heartRate, 78.0);
      expect(demo.spo2, 98.0);
      expect(demo.temperature, 36.7);
      expect(demo.activity, 'Normal');
      expect(demo.airQuality, 'Good');
      expect(demo.riskStatus, RiskStatus.normal);
      expect(demo.isWearableConnected, true);

      final json = demo.toJson();
      expect(json['heart_rate'], 78.0);
      expect(json['spo2'], 98.0);
      expect(json['temperature'], 36.7);
      expect(json['risk_status'], 'NORMAL');

      final fromJson = HealthReading.fromJson(json);
      expect(fromJson.heartRate, 78.0);
      expect(fromJson.spo2, 98.0);
      expect(fromJson.riskStatus, RiskStatus.normal);
    });

    test('WearableDevice default demo configuration', () {
      final watch = WearableDevice.defaultDemo();
      expect(watch.deviceName, 'LL Lifelink Watch');
      expect(watch.isConnected, true);
      expect(watch.batteryLevel, 88);
      expect(watch.isHeartRateSensorOk, true);
      expect(watch.isSpO2SensorOk, true);
      expect(watch.isMotionSensorOk, true);
      expect(watch.isTemperatureSensorOk, true);
      expect(watch.isAirQualitySensorOk, true);

      final disconnected = watch.copyWith(isConnected: false);
      expect(disconnected.isConnected, false);
      expect(disconnected.batteryLevel, 88);
    });

    test('Medication model copyWith and toggle status', () {
      final meds = Medication.getDemoMedications();
      expect(meds.isNotEmpty, true);

      final firstMed = meds.first;
      final toggled = firstMed.copyWith(isTaken: !firstMed.isTaken);
      expect(toggled.isTaken, !firstMed.isTaken);
      expect(toggled.name, firstMed.name);
    });

    test('EmergencyEvent demo logs contain GPS and HR details', () {
      final events = EmergencyEvent.getDemoEvents();
      expect(events.length, greaterThanOrEqualTo(3));
      final first = events.first;
      expect(first.latitude, 13.0827);
      expect(first.longitude, 80.2707);
      expect(first.heartRateAtEvent, 114.0);
    });

    test('UserModel and Caregiver defaults', () {
      final user = UserModel.defaultDemo();
      expect(user.name, 'Ramesh Kumar');
      expect(user.bloodGroup, 'B+ (Positive)');
      expect(user.medicalConditions.length, 2);

      final caregiver = Caregiver.defaultDemo();
      expect(caregiver.name, 'Priya Sharma');
      expect(caregiver.isPrimaryEmergencyRecipient, true);
      expect(caregiver.phoneNumber, '+91 98401 23456');
    });

    test('NotificationItem demo counts and properties', () {
      final notifs = NotificationItem.getDemoNotifications();
      expect(notifs.length, 5);
      expect(notifs.any((n) => n.type == NotificationType.healthWarning), true);
      expect(notifs.any((n) => n.type == NotificationType.emergencyAlert), true);
      expect(notifs.any((n) => n.type == NotificationType.medicationReminder), true);
    });
  });
}
