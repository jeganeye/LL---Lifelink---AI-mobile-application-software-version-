import 'package:flutter/foundation.dart';
import '../models/medication_model.dart';
import '../models/medical_record_model.dart';

/// Shared medication state service.
/// Connects MedicationPage and PatientHealthJourneyPage so prescriptions and medicines stay in sync.
class MedicationService extends ChangeNotifier {
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;

  MedicationService._internal() {
    _medications = Medication.getDemoMedications();
  }

  late List<Medication> _medications;

  List<Medication> get medications => List.unmodifiable(_medications);

  void toggleMedication(int index) {
    if (index < 0 || index >= _medications.length) return;
    final current = _medications[index];
    _medications[index] = current.copyWith(isTaken: !current.isTaken);
    notifyListeners();
  }

  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
  }

  /// Adds a medicine from the PatientHealthJourneyPage
  void addFromMedicineRecord(MedicineRecord record) {
    final newMed = Medication(
      id: record.id.isNotEmpty ? record.id : 'MED-${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: record.name,
      dosage: record.dosage,
      scheduledTime: record.reminderTime,
      instructions: record.frequency,
      isTaken: record.isTaken,
      category: _determineCategory(record.reminderTime),
    );
    _medications.add(newMed);
    notifyListeners();
  }

  String _determineCategory(String time) {
    final lower = time.toLowerCase();
    if (lower.contains('am') || lower.contains('morning')) return 'Morning';
    if (lower.contains('pm')) {
      if (lower.contains('12:') || lower.contains('1:') || lower.contains('2:') || lower.contains('3:')) {
        return 'Afternoon';
      }
      return 'Evening';
    }
    return 'Morning';
  }
}
