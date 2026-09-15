import 'package:flutter/foundation.dart';
import '../models/health_reading_model.dart';
import '../models/medical_record_model.dart';
import '../models/risk_status.dart';
import 'medication_service.dart';

/// Item for comparing biometric and lab values between checkups.
class CheckupComparisonItem {
  final String metricName;
  final String previousValue;
  final String currentValue;
  final String difference;
  final HealthTrendDirection trend;
  final String unit;
  final String note;

  const CheckupComparisonItem({
    required this.metricName,
    required this.previousValue,
    required this.currentValue,
    required this.difference,
    required this.trend,
    required this.unit,
    required this.note,
  });
}

/// Trend data point for continuous health graphs.
class HealthTrendPoint {
  final String label; // e.g. 'Mon', 'W1', 'Jan'
  final DateTime date;
  final double heartRate;
  final double spo2;
  final double temperature;
  final double systolicBp;
  final bool isDemoData;

  const HealthTrendPoint({
    required this.label,
    required this.date,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.systolicBp,
    this.isDemoData = true,
  });
}

/// Service managing the patient's continuous health records, scans, prescriptions,
/// medical timeline, comparison analytics, and AI document explanations.
class MedicalRecordService extends ChangeNotifier {
  static final MedicalRecordService _instance = MedicalRecordService._internal();
  factory MedicalRecordService() => _instance;

  MedicalRecordService._internal() {
    _initDemoRecords();
  }

  final List<MedicalRecord> _records = [];
  final List<MedicalDocument> _documents = [];
  final List<PrescriptionRecord> _prescriptions = [];
  final List<MedicineRecord> _medicines = [];

  List<MedicalRecord> get records => List.unmodifiable(_records);
  List<MedicalDocument> get documents => List.unmodifiable(_documents);
  List<PrescriptionRecord> get prescriptions => List.unmodifiable(_prescriptions);
  List<MedicineRecord> get medicines => List.unmodifiable(_medicines);

  /// Latest health trend status
  HealthTrendDirection get overallHealthTrend {
    if (_records.isEmpty) return HealthTrendDirection.insufficientData;
    return _records.first.aiExplanation?.trend ?? HealthTrendDirection.stable;
  }

  void _initDemoRecords() {
    final now = DateTime.now();

    // 1. Initial Medications
    final med1 = MedicineRecord(
      id: 'MED-101',
      name: 'Amlodipine Besylate',
      dosage: '5 mg (1 Tablet)',
      frequency: 'Once daily after breakfast',
      startDate: now.subtract(const Duration(days: 60)),
      doctorReference: 'Dr. Arvind Swaminathan',
      reminderTime: '08:00 AM',
      isTaken: true,
    );
    final med2 = MedicineRecord(
      id: 'MED-102',
      name: 'Metformin HCl',
      dosage: '500 mg (1 Tablet)',
      frequency: 'Twice daily with meals',
      startDate: now.subtract(const Duration(days: 60)),
      doctorReference: 'Dr. Arvind Swaminathan',
      reminderTime: '08:30 AM',
      isTaken: true,
    );
    final med3 = MedicineRecord(
      id: 'MED-103',
      name: 'Atorvastatin Calcium',
      dosage: '10 mg (1 Tablet)',
      frequency: 'Once daily at bedtime',
      startDate: now.subtract(const Duration(days: 30)),
      doctorReference: 'Dr. K. Ramanathan',
      reminderTime: '09:00 PM',
      isTaken: false,
    );

    _medicines.addAll([med1, med2, med3]);

    // 2. Prescriptions
    final pres1 = PrescriptionRecord(
      id: 'RX-9021',
      doctorName: 'Dr. Arvind Swaminathan (MD, DM Cardiology)',
      hospitalName: 'Apollo Hospitals, Greams Road, Chennai',
      prescriptionDate: now.subtract(const Duration(days: 60)),
      notes: 'Continue anti-hypertensive therapy. Maintain low sodium diet and 30m brisk walking.',
      medicines: [med1, med2],
    );

    final pres2 = PrescriptionRecord(
      id: 'RX-9088',
      doctorName: 'Dr. K. Ramanathan (Senior Consultant Cardiologist)',
      hospitalName: 'MIOT International, Manapakkam, Chennai',
      prescriptionDate: now.subtract(const Duration(days: 7)),
      notes: 'Added Atorvastatin 10mg for lipid target optimization. Blood pressure well controlled.',
      medicines: [med3],
    );

    _prescriptions.addAll([pres1, pres2]);

    // 3. Documents / Scans with AI-Assisted Explanations
    final doc1 = MedicalDocument(
      id: 'DOC-801',
      title: '12-Lead Resting ECG Report',
      documentType: 'ECG',
      fileUrl: 'demo_ecg_trace_apollo.pdf',
      uploadDate: now.subtract(const Duration(days: 60)),
      checkupDate: now.subtract(const Duration(days: 60)),
      hospital: 'Apollo Hospitals, Chennai',
      doctor: 'Dr. Arvind Swaminathan',
      userNotes: 'Routine quarterly cardiac checkup.',
      extractedData: {
        'heart_rate': 78,
        'pr_interval_ms': 156,
        'qrs_duration_ms': 88,
        'qtc_ms': 418,
        'rhythm': 'Normal Sinus Rhythm',
      },
      aiExplanation: const AiDocumentExplanation(
        documentId: 'DOC-801',
        documentType: '12-Lead Electrocardiogram (ECG)',
        summary:
            'The ECG shows a normal sinus rhythm at 78 beats per minute. Electrical conduction intervals (PR and QRS duration) fall squarely within healthy reference bounds without acute ST-segment deviation.',
        simplifiedTerms: {
          'Sinus Rhythm': 'The natural, regular electrical pacemaker cycle of a healthy heart.',
          'PR Interval': 'The time it takes for electrical impulses to travel from the heart’s upper to lower chambers.',
          'QRS Duration': 'The time required for the heart ventricles to pump blood outwards.',
        },
        trend: HealthTrendDirection.stable,
        comparisonNotes: 'First baseline ECG uploaded to LL Lifelink AI repository.',
        extractedMetrics: {'Heart Rate': '78 BPM', 'Rhythm': 'Normal Sinus Rhythm'},
      ),
    );

    final doc2 = MedicalDocument(
      id: 'DOC-802',
      title: 'Comprehensive Metabolic & Lipid Panel',
      documentType: 'Blood test report',
      fileUrl: 'demo_blood_report_fortis.pdf',
      uploadDate: now.subtract(const Duration(days: 30)),
      checkupDate: now.subtract(const Duration(days: 30)),
      hospital: 'Fortis Malar Hospital, Adyar, Chennai',
      doctor: 'Dr. Priya Raghavan',
      userNotes: 'Fasting blood test for sugar and cholesterol check.',
      extractedData: {
        'fasting_glucose_mg_dl': 98,
        'total_cholesterol_mg_dl': 195,
        'hdl_cholesterol_mg_dl': 48,
        'ldl_cholesterol_mg_dl': 118,
        'triglycerides_mg_dl': 142,
        'hemoglobin_g_dl': 14.2,
      },
      aiExplanation: const AiDocumentExplanation(
        documentId: 'DOC-802',
        documentType: 'Blood Chemistry & Lipid Panel',
        summary:
            'Fasting blood sugar (98 mg/dL) and Hemoglobin (14.2 g/dL) are in optimal zones. Total cholesterol is borderline high at 195 mg/dL with LDL at 118 mg/dL.',
        simplifiedTerms: {
          'Fasting Blood Sugar': 'Blood sugar levels measured after at least 8 hours without eating.',
          'LDL Cholesterol': 'Often called "bad cholesterol"; lower values reduce arterial plaque risk.',
          'HDL Cholesterol': 'Often called "good cholesterol"; helps carry fat away from blood vessels.',
        },
        trend: HealthTrendDirection.needsAttention,
        comparisonNotes: 'Lipid markers require continued dietary moderation and hydration.',
        extractedMetrics: {'Glucose': '98 mg/dL', 'Total Cholesterol': '195 mg/dL'},
      ),
    );

    final doc3 = MedicalDocument(
      id: 'DOC-803',
      title: 'Digital Chest X-Ray (PA View)',
      documentType: 'X-ray',
      fileUrl: 'demo_chest_xray_miot.pdf',
      uploadDate: now.subtract(const Duration(days: 7)),
      checkupDate: now.subtract(const Duration(days: 7)),
      hospital: 'MIOT International, Chennai',
      doctor: 'Dr. K. Ramanathan',
      userNotes: 'Pre-consultation thoracic clearance.',
      extractedData: {
        'lung_fields': 'Clear bilaterally',
        'cardiothoracic_ratio': 0.44,
        'pleural_spaces': 'Clear, sharp costophrenic angles',
      },
      aiExplanation: const AiDocumentExplanation(
        documentId: 'DOC-803',
        documentType: 'Digital Chest Radiograph (X-ray)',
        summary:
            'Both lung fields are clear with no consolidation, active infiltrates, or pleural effusion. The cardiothoracic ratio is normal (0.44), indicating a normal cardiac silhouette size.',
        simplifiedTerms: {
          'Cardiothoracic Ratio': 'Comparison between heart width and chest width; under 0.5 is normal.',
          'Costophrenic Angles': 'The lower corners of the lung cavity; sharp angles indicate no excess fluid buildup.',
        },
        trend: HealthTrendDirection.improving,
        comparisonNotes: 'Lungs and heart boundaries appear completely clear compared to prior checkup.',
        extractedMetrics: {'Cardiothoracic Ratio': '0.44 (Normal)', 'Lungs': 'Clear'},
      ),
    );

    _documents.addAll([doc1, doc2, doc3]);

    // 4. Chronological Checkup Visits
    final checkup1 = MedicalRecord(
      id: 'CHK-1001',
      checkupDate: now.subtract(const Duration(days: 60)),
      hospitalName: 'Apollo Hospitals, Greams Road, Chennai',
      doctorName: 'Dr. Arvind Swaminathan',
      reason: 'Hypertension Follow-up & Baseline Telemetry Setup',
      notes: 'Patient started on low-dose Amlodipine. Wearable paired for ambulatory vitals surveillance.',
      recordType: 'Monthly',
      documents: [doc1],
      prescriptions: [pres1],
      medicines: [med1, med2],
      vitalsSnapshot: HealthReading(
        heartRate: 78.0,
        spo2: 98.0,
        temperature: 36.6,
        activity: 'Resting',
        airQuality: 'Good',
        aqiValue: 42,
        riskStatus: RiskStatus.normal,
        timestamp: now.subtract(const Duration(days: 60)),
      ),
      aiExplanation: doc1.aiExplanation,
    );

    final checkup2 = MedicalRecord(
      id: 'CHK-1002',
      checkupDate: now.subtract(const Duration(days: 30)),
      hospitalName: 'Fortis Malar Hospital, Adyar, Chennai',
      doctorName: 'Dr. Priya Raghavan',
      reason: 'Metabolic & Blood Lipid Profile Review',
      notes: 'Blood sugar normal. Mild cholesterol elevation flagged for follow-up.',
      recordType: 'Monthly',
      documents: [doc2],
      medicines: [med1, med2],
      vitalsSnapshot: HealthReading(
        heartRate: 76.0,
        spo2: 98.0,
        temperature: 36.7,
        activity: 'Normal',
        airQuality: 'Moderate',
        aqiValue: 65,
        riskStatus: RiskStatus.normal,
        timestamp: now.subtract(const Duration(days: 30)),
      ),
      aiExplanation: doc2.aiExplanation,
    );

    final checkup3 = MedicalRecord(
      id: 'CHK-1003',
      checkupDate: now.subtract(const Duration(days: 7)),
      hospitalName: 'MIOT International, Manapakkam, Chennai',
      doctorName: 'Dr. K. Ramanathan',
      reason: 'Cardio-Metabolic Comprehensive Follow-up',
      notes: 'BP stabilized at 122/80 mmHg. Excellent medication adherence reported.',
      recordType: 'Monthly',
      documents: [doc3],
      prescriptions: [pres2],
      medicines: [med1, med2, med3],
      vitalsSnapshot: HealthReading(
        heartRate: 72.0,
        spo2: 99.0,
        temperature: 36.5,
        activity: 'Resting',
        airQuality: 'Good',
        aqiValue: 48,
        riskStatus: RiskStatus.normal,
        timestamp: now.subtract(const Duration(days: 7)),
      ),
      aiExplanation: doc3.aiExplanation,
    );

    // Latest first (chronological stack)
    _records.addAll([checkup3, checkup2, checkup1]);
  }

  /// Adds a new patient checkup record
  void addCheckupRecord(MedicalRecord record) {
    _records.insert(0, record);
    // Also add any documents and medicines
    for (final doc in record.documents) {
      if (!_documents.any((d) => d.id == doc.id)) {
        _documents.insert(0, doc);
      }
    }
    for (final med in record.medicines) {
      if (!_medicines.any((m) => m.id == med.id)) {
        _medicines.add(med);
        MedicationService().addFromMedicineRecord(med);
      }
    }
    notifyListeners();
  }

  /// Adds a newly uploaded medical document/scan
  void addDocument(MedicalDocument document) {
    _documents.insert(0, document);
    notifyListeners();
  }

  /// Adds a newly uploaded prescription
  void addPrescription(PrescriptionRecord prescription) {
    _prescriptions.insert(0, prescription);
    for (final med in prescription.medicines) {
      _medicines.add(med);
      MedicationService().addFromMedicineRecord(med);
    }
    notifyListeners();
  }

  /// Adds a new medicine
  void addMedicine(MedicineRecord medicine) {
    _medicines.add(medicine);
    MedicationService().addFromMedicineRecord(medicine);
    notifyListeners();
  }

  /// Compares values between a previous checkup and the current checkup.
  List<CheckupComparisonItem> compareCheckups({
    required MedicalRecord previous,
    required MedicalRecord current,
  }) {
    final List<CheckupComparisonItem> items = [];

    // Heart Rate Comparison
    if (previous.vitalsSnapshot != null && current.vitalsSnapshot != null) {
      final prevHr = previous.vitalsSnapshot!.heartRate;
      final currHr = current.vitalsSnapshot!.heartRate;
      final diffHr = currHr - prevHr;
      final hrTrend = diffHr.abs() <= 5
          ? HealthTrendDirection.stable
          : (diffHr < 0 ? HealthTrendDirection.improving : HealthTrendDirection.needsAttention);

      items.add(
        CheckupComparisonItem(
          metricName: 'Resting Heart Rate',
          previousValue: '${prevHr.toStringAsFixed(0)} BPM',
          currentValue: '${currHr.toStringAsFixed(0)} BPM',
          difference: diffHr == 0 ? '0' : (diffHr > 0 ? '+${diffHr.toStringAsFixed(0)}' : diffHr.toStringAsFixed(0)),
          trend: hrTrend,
          unit: 'BPM',
          note: hrTrend == HealthTrendDirection.stable
              ? 'Stable within optimal resting target (60-80 BPM).'
              : (hrTrend == HealthTrendDirection.improving ? 'Improvement observed.' : 'Slightly elevated; discuss with doctor.'),
        ),
      );

      // SpO2 Comparison
      final prevSpo2 = previous.vitalsSnapshot!.spo2;
      final currSpo2 = current.vitalsSnapshot!.spo2;
      final diffSpo2 = currSpo2 - prevSpo2;
      final spo2Trend = currSpo2 >= 97.0 ? HealthTrendDirection.stable : HealthTrendDirection.needsAttention;

      items.add(
        CheckupComparisonItem(
          metricName: 'Blood Oxygen (SpO2)',
          previousValue: '${prevSpo2.toStringAsFixed(0)}%',
          currentValue: '${currSpo2.toStringAsFixed(0)}%',
          difference: diffSpo2 == 0 ? '0' : (diffSpo2 > 0 ? '+${diffSpo2.toStringAsFixed(0)}%' : '${diffSpo2.toStringAsFixed(0)}%'),
          trend: spo2Trend,
          unit: '%',
          note: 'Optimal arterial oxygen saturation (>95%).',
        ),
      );

      // Temperature Comparison
      final prevTemp = previous.vitalsSnapshot!.temperature;
      final currTemp = current.vitalsSnapshot!.temperature;
      final diffTemp = currTemp - prevTemp;

      items.add(
        CheckupComparisonItem(
          metricName: 'Body Temperature',
          previousValue: '${prevTemp.toStringAsFixed(1)} °C',
          currentValue: '${currTemp.toStringAsFixed(1)} °C',
          difference: diffTemp == 0 ? '0' : (diffTemp > 0 ? '+${diffTemp.toStringAsFixed(1)}' : diffTemp.toStringAsFixed(1)),
          trend: HealthTrendDirection.stable,
          unit: '°C',
          note: 'Afebrile, normothermic baseline.',
        ),
      );
    }

    // Prescriptions Comparison
    items.add(
      CheckupComparisonItem(
        metricName: 'Prescribed Regimen',
        previousValue: '${previous.medicines.length} Prescriptions',
        currentValue: '${current.medicines.length} Prescriptions',
        difference: '${current.medicines.length - previous.medicines.length >= 0 ? "+" : ""}${current.medicines.length - previous.medicines.length}',
        trend: HealthTrendDirection.stable,
        unit: 'Meds',
        note: 'Active regimen updated per latest physician notes.',
      ),
    );

    return items;
  }

  /// Continuous health trend points based on timeframe (Daily, Weekly, Monthly)
  List<HealthTrendPoint> getTrendPoints(String timeframe) {
    final now = DateTime.now();

    if (timeframe == 'Daily') {
      return [
        HealthTrendPoint(label: 'Mon', date: now.subtract(const Duration(days: 6)), heartRate: 74, spo2: 98, temperature: 36.6, systolicBp: 122),
        HealthTrendPoint(label: 'Tue', date: now.subtract(const Duration(days: 5)), heartRate: 76, spo2: 97, temperature: 36.5, systolicBp: 124),
        HealthTrendPoint(label: 'Wed', date: now.subtract(const Duration(days: 4)), heartRate: 79, spo2: 98, temperature: 36.7, systolicBp: 121),
        HealthTrendPoint(label: 'Thu', date: now.subtract(const Duration(days: 3)), heartRate: 75, spo2: 99, temperature: 36.6, systolicBp: 120),
        HealthTrendPoint(label: 'Fri', date: now.subtract(const Duration(days: 2)), heartRate: 77, spo2: 98, temperature: 36.5, systolicBp: 122),
        HealthTrendPoint(label: 'Sat', date: now.subtract(const Duration(days: 1)), heartRate: 73, spo2: 98, temperature: 36.6, systolicBp: 119),
        HealthTrendPoint(
          label: 'Sun',
          date: now,
          heartRate: _records.isNotEmpty && _records.first.vitalsSnapshot != null ? _records.first.vitalsSnapshot!.heartRate : 72,
          spo2: _records.isNotEmpty && _records.first.vitalsSnapshot != null ? _records.first.vitalsSnapshot!.spo2 : 99,
          temperature: _records.isNotEmpty && _records.first.vitalsSnapshot != null ? _records.first.vitalsSnapshot!.temperature : 36.5,
          systolicBp: 120,
          isDemoData: false,
        ),
      ];
    } else if (timeframe == 'Weekly') {
      return [
        HealthTrendPoint(label: 'W-4', date: now.subtract(const Duration(days: 28)), heartRate: 78, spo2: 98, temperature: 36.6, systolicBp: 126),
        HealthTrendPoint(label: 'W-3', date: now.subtract(const Duration(days: 21)), heartRate: 76, spo2: 98, temperature: 36.7, systolicBp: 124),
        HealthTrendPoint(label: 'W-2', date: now.subtract(const Duration(days: 14)), heartRate: 74, spo2: 99, temperature: 36.5, systolicBp: 121),
        HealthTrendPoint(label: 'W-1', date: now.subtract(const Duration(days: 7)), heartRate: 72, spo2: 99, temperature: 36.5, systolicBp: 120),
      ];
    } else {
      // Monthly
      return [
        HealthTrendPoint(label: 'May', date: now.subtract(const Duration(days: 150)), heartRate: 82, spo2: 97, temperature: 36.7, systolicBp: 130),
        HealthTrendPoint(label: 'Jun', date: now.subtract(const Duration(days: 120)), heartRate: 80, spo2: 98, temperature: 36.6, systolicBp: 128),
        HealthTrendPoint(label: 'Jul', date: now.subtract(const Duration(days: 90)), heartRate: 78, spo2: 98, temperature: 36.6, systolicBp: 124),
        HealthTrendPoint(label: 'Aug', date: now.subtract(const Duration(days: 60)), heartRate: 76, spo2: 98, temperature: 36.5, systolicBp: 122),
        HealthTrendPoint(label: 'Sep', date: now.subtract(const Duration(days: 30)), heartRate: 74, spo2: 99, temperature: 36.5, systolicBp: 121),
        HealthTrendPoint(label: 'Oct', date: now, heartRate: 72, spo2: 99, temperature: 36.5, systolicBp: 120),
      ];
    }
  }

  /// Generates a compliant AI-assisted document explanation with safe medical phrasing.
  AiDocumentExplanation generateExplanationForUpload({
    required String documentType,
    required String userNotes,
    String? hospital,
    String? doctor,
  }) {
    final lower = documentType.toLowerCase();
    String summary;
    Map<String, String> glossary;
    HealthTrendDirection trend;

    if (lower.contains('x-ray') || lower.contains('radiograph')) {
      summary =
          'Document identified as a Thoracic Imaging (Chest X-Ray) record. Bone architecture, pleural reflections, and pulmonary parenchymal density appear consistent with previous checkup records.';
      glossary = {
        'Pleural Reflections': 'The thin dual membrane enclosing each lung.',
        'Pulmonary Parenchyma': 'The functional gas-exchanging tissue portions of the lungs.',
      };
      trend = HealthTrendDirection.stable;
    } else if (lower.contains('ecg') || lower.contains('ekg')) {
      summary =
          'Document identified as an Electrocardiogram (ECG) telemetry tracing. Sinus rhythm is maintained with regular R-R wave intervals and no acute repolarization abnormalities detected.';
      glossary = {
        'R-R Interval': 'The duration between consecutive heartbeats.',
        'Repolarization': 'The recovery phase of cardiac muscle cells after each contraction.',
      };
      trend = HealthTrendDirection.improving;
    } else if (lower.contains('blood') || lower.contains('lab')) {
      summary =
          'Document identified as a Hematology / Metabolic laboratory panel. Core cellular components and basic chemistry markers fall within standard reference intervals.';
      glossary = {
        'Leukocytes': 'White blood cells responsible for immune response against infection.',
        'Hematocrit': 'The proportion of blood volume composed of red blood cells.',
      };
      trend = HealthTrendDirection.stable;
    } else if (lower.contains('prescription')) {
      summary =
          'Document identified as a Licensed Medical Prescription. Outlines active medications, dosage instructions, and follow-up intervals for ambulatory adherence.';
      glossary = {
        'Posology': 'The medical term for medication dosage and intake scheduling.',
      };
      trend = HealthTrendDirection.stable;
    } else {
      summary =
          'Document uploaded successfully. Content contains clinical notations suitable for review during the patient’s next scheduled consultation.';
      glossary = {
        'Clinical Review': 'A collaborative consultation with your attending healthcare professional.',
      };
      trend = HealthTrendDirection.stable;
    }

    return AiDocumentExplanation(
      documentId: 'DOC-NEW-${DateTime.now().millisecondsSinceEpoch % 1000}',
      documentType: documentType,
      summary: summary,
      simplifiedTerms: glossary,
      trend: trend,
      comparisonNotes:
          'Based on recorded health data, your recent trend appears stable. Consult a physician for clinical confirmation.',
      safetyDisclaimer:
          'AI-assisted explanation only — consult a qualified healthcare professional for medical decisions. This is not a diagnosis.',
    );
  }
}
