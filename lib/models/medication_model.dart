/// Model for patient medication tracking and adherence reminders.
class Medication {
  final String id;
  final String name;
  final String dosage;
  final String scheduledTime;
  final String instructions;
  final bool isTaken;
  final String category; // Morning, Afternoon, Evening

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.scheduledTime,
    required this.instructions,
    this.isTaken = false,
    required this.category,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? scheduledTime,
    String? instructions,
    bool? isTaken,
    String? category,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      instructions: instructions ?? this.instructions,
      isTaken: isTaken ?? this.isTaken,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'scheduled_time': scheduledTime,
      'instructions': instructions,
      'is_taken': isTaken,
      'category': category,
    };
  }

  static List<Medication> getDemoMedications() {
    return [
      const Medication(
        id: 'MED-01',
        name: 'Amlodipine Besylate',
        dosage: '5 mg (1 Tablet)',
        scheduledTime: '08:00 AM',
        instructions: 'Take after breakfast with water',
        isTaken: true,
        category: 'Morning',
      ),
      const Medication(
        id: 'MED-02',
        name: 'Metformin HCl',
        dosage: '500 mg (1 Tablet)',
        scheduledTime: '08:30 AM',
        instructions: 'Take with food for glycemic control',
        isTaken: true,
        category: 'Morning',
      ),
      const Medication(
        id: 'MED-03',
        name: 'Multivitamin Complex',
        dosage: '1 Capsule',
        scheduledTime: '01:30 PM',
        instructions: 'Take after lunch',
        isTaken: false,
        category: 'Afternoon',
      ),
      const Medication(
        id: 'MED-04',
        name: 'Atorvastatin Calcium',
        dosage: '10 mg (1 Tablet)',
        scheduledTime: '09:00 PM',
        instructions: 'Take before sleep for lipid regulation',
        isTaken: false,
        category: 'Evening',
      ),
    ];
  }
}
