import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'health_reading_model.dart';

/// Health trend direction indicator for continuous records and AI explanations.
enum HealthTrendDirection {
  stable,
  improving,
  needsAttention,
  insufficientData;

  String get label {
    switch (this) {
      case HealthTrendDirection.stable:
        return 'Stable';
      case HealthTrendDirection.improving:
        return 'Improving';
      case HealthTrendDirection.needsAttention:
        return 'Needs Attention';
      case HealthTrendDirection.insufficientData:
        return 'Insufficient Data';
    }
  }

  Color get color {
    switch (this) {
      case HealthTrendDirection.stable:
        return AppColors.statusNormal;
      case HealthTrendDirection.improving:
        return const Color(0xFF00E5FF);
      case HealthTrendDirection.needsAttention:
        return AppColors.statusWarning;
      case HealthTrendDirection.insufficientData:
        return AppColors.textMutedLight;
    }
  }

  IconData get icon {
    switch (this) {
      case HealthTrendDirection.stable:
        return Icons.trending_flat_rounded;
      case HealthTrendDirection.improving:
        return Icons.trending_up_rounded;
      case HealthTrendDirection.needsAttention:
        return Icons.warning_amber_rounded;
      case HealthTrendDirection.insufficientData:
        return Icons.help_outline_rounded;
    }
  }
}

/// Structured AI-assisted plain language explanation for medical reports and scans.
class AiDocumentExplanation {
  final String documentId;
  final String documentType;
  final String summary;
  final Map<String, String> simplifiedTerms;
  final HealthTrendDirection trend;
  final String safetyDisclaimer;
  final String comparisonNotes;
  final Map<String, dynamic> extractedMetrics;

  const AiDocumentExplanation({
    required this.documentId,
    required this.documentType,
    required this.summary,
    required this.simplifiedTerms,
    required this.trend,
    this.safetyDisclaimer =
        'AI-assisted explanation only — consult a qualified healthcare professional for medical decisions. This is not a diagnosis.',
    required this.comparisonNotes,
    this.extractedMetrics = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'document_type': documentType,
      'summary': summary,
      'simplified_terms': simplifiedTerms,
      'trend': trend.name,
      'safety_disclaimer': safetyDisclaimer,
      'comparison_notes': comparisonNotes,
      'extracted_metrics': extractedMetrics,
    };
  }

  factory AiDocumentExplanation.fromJson(Map<String, dynamic> json) {
    return AiDocumentExplanation(
      documentId: json['document_id'] as String? ?? '',
      documentType: json['document_type'] as String? ?? 'General Report',
      summary: json['summary'] as String? ?? '',
      simplifiedTerms: Map<String, String>.from(json['simplified_terms'] ?? {}),
      trend: HealthTrendDirection.values.firstWhere(
        (e) => e.name == json['trend'],
        orElse: () => HealthTrendDirection.stable,
      ),
      safetyDisclaimer: json['safety_disclaimer'] as String? ??
          'AI-assisted explanation only — consult a qualified healthcare professional for medical decisions.',
      comparisonNotes: json['comparison_notes'] as String? ?? '',
      extractedMetrics: Map<String, dynamic>.from(json['extracted_metrics'] ?? {}),
    );
  }
}

/// A medical document or imaging scan (X-ray, ECG, Blood Test, MRI, CT, Ultrasound, etc.).
class MedicalDocument {
  final String id;
  final String title;
  final String documentType; // X-ray, ECG, Blood test report, Scan report, CT, MRI, Ultrasound, Other
  final String fileUrl;
  final DateTime uploadDate;
  final DateTime checkupDate;
  final String hospital;
  final String doctor;
  final String userNotes;
  final AiDocumentExplanation? aiExplanation;
  final Map<String, dynamic> extractedData;

  const MedicalDocument({
    required this.id,
    required this.title,
    required this.documentType,
    required this.fileUrl,
    required this.uploadDate,
    required this.checkupDate,
    required this.hospital,
    required this.doctor,
    this.userNotes = '',
    this.aiExplanation,
    this.extractedData = const {},
  });

  MedicalDocument copyWith({
    String? id,
    String? title,
    String? documentType,
    String? fileUrl,
    DateTime? uploadDate,
    DateTime? checkupDate,
    String? hospital,
    String? doctor,
    String? userNotes,
    AiDocumentExplanation? aiExplanation,
    Map<String, dynamic>? extractedData,
  }) {
    return MedicalDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadDate: uploadDate ?? this.uploadDate,
      checkupDate: checkupDate ?? this.checkupDate,
      hospital: hospital ?? this.hospital,
      doctor: doctor ?? this.doctor,
      userNotes: userNotes ?? this.userNotes,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      extractedData: extractedData ?? this.extractedData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'document_type': documentType,
      'file_url': fileUrl,
      'upload_date': uploadDate.toIso8601String(),
      'checkup_date': checkupDate.toIso8601String(),
      'hospital': hospital,
      'doctor': doctor,
      'user_notes': userNotes,
      'ai_explanation': aiExplanation?.toJson(),
      'extracted_data': extractedData,
    };
  }
}

/// A prescription uploaded by the patient.
class PrescriptionRecord {
  final String id;
  final String doctorName;
  final String hospitalName;
  final DateTime prescriptionDate;
  final String notes;
  final String prescriptionImageUrl;
  final List<MedicineRecord> medicines;

  const PrescriptionRecord({
    required this.id,
    required this.doctorName,
    required this.hospitalName,
    required this.prescriptionDate,
    this.notes = '',
    this.prescriptionImageUrl = '',
    this.medicines = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_name': doctorName,
      'hospital_name': hospitalName,
      'prescription_date': prescriptionDate.toIso8601String(),
      'notes': notes,
      'prescription_image_url': prescriptionImageUrl,
      'medicines': medicines.map((m) => m.toJson()).toList(),
    };
  }
}

/// Medicine or tablet record linked with prescriptions and MedicationPage.
class MedicineRecord {
  final String id;
  final String name;
  final String imageUrl;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String doctorReference;
  final String reminderTime;
  final bool isTaken;

  const MedicineRecord({
    required this.id,
    required this.name,
    this.imageUrl = '',
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.doctorReference = '',
    this.reminderTime = '09:00 AM',
    this.isTaken = false,
  });

  MedicineRecord copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? doctorReference,
    String? reminderTime,
    bool? isTaken,
  }) {
    return MedicineRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      doctorReference: doctorReference ?? this.doctorReference,
      reminderTime: reminderTime ?? this.reminderTime,
      isTaken: isTaken ?? this.isTaken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'dosage': dosage,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'doctor_reference': doctorReference,
      'reminder_time': reminderTime,
      'is_taken': isTaken,
    };
  }
}

/// Complete patient checkup record representing a hospital/clinic visit.
class MedicalRecord {
  final String id;
  final DateTime checkupDate;
  final String hospitalName;
  final String doctorName;
  final String reason;
  final String notes;
  final String recordType; // 'Daily', 'Weekly', 'Monthly', 'Other'
  final List<MedicalDocument> documents;
  final List<PrescriptionRecord> prescriptions;
  final List<MedicineRecord> medicines;
  final HealthReading? vitalsSnapshot;
  final AiDocumentExplanation? aiExplanation;

  const MedicalRecord({
    required this.id,
    required this.checkupDate,
    required this.hospitalName,
    required this.doctorName,
    required this.reason,
    this.notes = '',
    this.recordType = 'Monthly',
    this.documents = const [],
    this.prescriptions = const [],
    this.medicines = const [],
    this.vitalsSnapshot,
    this.aiExplanation,
  });

  MedicalRecord copyWith({
    String? id,
    DateTime? checkupDate,
    String? hospitalName,
    String? doctorName,
    String? reason,
    String? notes,
    String? recordType,
    List<MedicalDocument>? documents,
    List<PrescriptionRecord>? prescriptions,
    List<MedicineRecord>? medicines,
    HealthReading? vitalsSnapshot,
    AiDocumentExplanation? aiExplanation,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      checkupDate: checkupDate ?? this.checkupDate,
      hospitalName: hospitalName ?? this.hospitalName,
      doctorName: doctorName ?? this.doctorName,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      recordType: recordType ?? this.recordType,
      documents: documents ?? this.documents,
      prescriptions: prescriptions ?? this.prescriptions,
      medicines: medicines ?? this.medicines,
      vitalsSnapshot: vitalsSnapshot ?? this.vitalsSnapshot,
      aiExplanation: aiExplanation ?? this.aiExplanation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkup_date': checkupDate.toIso8601String(),
      'hospital_name': hospitalName,
      'doctor_name': doctorName,
      'reason': reason,
      'notes': notes,
      'record_type': recordType,
      'documents': documents.map((d) => d.toJson()).toList(),
      'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
      'medicines': medicines.map((m) => m.toJson()).toList(),
      'vitals_snapshot': vitalsSnapshot?.toJson(),
      'ai_explanation': aiExplanation?.toJson(),
    };
  }
}
