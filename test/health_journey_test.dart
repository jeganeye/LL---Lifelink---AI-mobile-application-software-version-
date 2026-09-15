import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ll_lifelink_ai/models/medical_record_model.dart';
import 'package:ll_lifelink_ai/services/medical_record_service.dart';
import 'package:ll_lifelink_ai/services/medication_service.dart';
import 'package:ll_lifelink_ai/screens/health_journey/patient_health_journey_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Patient Health Journey - Service & Model Tests', () {
    test('MedicalRecordService initializes with realistic clinical demo records', () {
      final service = MedicalRecordService();
      expect(service.records.length, greaterThanOrEqualTo(3));
      expect(service.prescriptions.isNotEmpty, isTrue);
      expect(service.documents.isNotEmpty, isTrue);
      expect(service.medicines.isNotEmpty, isTrue);
    });

    test('Comparison logic evaluates checkup deltas correctly', () {
      final service = MedicalRecordService();
      final latest = service.records.first;
      final previous = service.records[1];

      final comparison = service.compareCheckups(previous: previous, current: latest);
      expect(comparison, isNotEmpty);
      expect(comparison.any((c) => c.metricName.contains('Heart Rate')), isTrue);
      expect(comparison.any((c) => c.metricName.contains('Blood Oxygen')), isTrue);
      expect(comparison.any((c) => c.metricName.contains('Body Temperature')), isTrue);

      final hrComp = comparison.firstWhere((c) => c.metricName.contains('Heart Rate'));
      expect(hrComp.previousValue, contains('BPM'));
      expect(hrComp.currentValue, contains('BPM'));
    });

    test('AI Document Explanation contains mandatory strict medical safety disclaimer', () {
      final service = MedicalRecordService();
      final explanation = service.records.first.documents.first.aiExplanation;

      expect(explanation, isNotNull);
      expect(
        explanation!.safetyDisclaimer,
        contains('consult a qualified healthcare professional'),
      );
      expect(
        explanation.safetyDisclaimer,
        contains('This is not a diagnosis'),
      );
      expect(explanation.simplifiedTerms.isNotEmpty, isTrue);
      expect(explanation.summary.isNotEmpty, isTrue);
    });

    test('Adding a medicine record through MedicalRecordService synchronizes with MedicationService', () {
      final medRecordService = MedicalRecordService();
      final medService = MedicationService();

      final initialCount = medService.medications.length;
      final newMed = MedicineRecord(
        id: 'MED-TEST-01',
        name: 'Atorvastatin Test',
        dosage: '20mg',
        frequency: 'Once Daily (Night)',
        startDate: DateTime.now(),
        doctorReference: 'Dr. Test',
        reminderTime: '10:00 PM',
      );

      medRecordService.addMedicine(newMed);

      expect(medService.medications.length, equals(initialCount + 1));
      expect(medService.medications.any((m) => m.name == 'Atorvastatin Test'), isTrue);
    });

    test('Continuous Health Trend aggregation supports Daily, Weekly, and Monthly switches', () {
      final service = MedicalRecordService();

      final dailyPoints = service.getTrendPoints('Daily');
      final weeklyPoints = service.getTrendPoints('Weekly');
      final monthlyPoints = service.getTrendPoints('Monthly');

      expect(dailyPoints.length, equals(7));
      expect(weeklyPoints.length, equals(4));
      expect(monthlyPoints.length, equals(6));
    });
  });

  group('Patient Health Journey - Widget Tests', () {
    testWidgets('PatientHealthJourneyPage renders summary card, toolbar, trends and timeline',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientHealthJourneyPage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Header and title
      expect(find.text('Patient Health Journey'), findsOneWidget);
      expect(find.textContaining('Your Health Trend'), findsOneWidget);

      // Quick Actions Toolbar
      expect(find.textContaining('Checkup'), findsWidgets);
      expect(find.textContaining('Upload Scan'), findsWidgets);
      expect(find.textContaining('Prescription'), findsWidgets);
      expect(find.textContaining('Medicine'), findsWidgets);
      expect(find.textContaining('AI-assisted'), findsWidgets);

      // Trend Graph section
      expect(find.textContaining('Health Trend'), findsWidgets);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);

      // Checkup Comparison Section
      expect(find.textContaining('Comparison'), findsWidgets);

      // Timeline Section
      expect(find.textContaining('Timeline'), findsWidgets);
      expect(find.textContaining('Apollo Hospitals'), findsWidgets);
    });
  });
}
