/// Model representing the primary or secondary designated caregiver.
class Caregiver {
  final String id;
  final String name;
  final String relation; // Daughter, Spouse, Son, Guardian, Doctor
  final String phoneNumber;
  final String email;
  final bool isPrimaryEmergencyRecipient;
  final bool isConnected;
  final String lastActive;
  final List<String> recentAlerts;

  const Caregiver({
    required this.id,
    required this.name,
    required this.relation,
    required this.phoneNumber,
    required this.email,
    required this.isPrimaryEmergencyRecipient,
    required this.isConnected,
    required this.lastActive,
    required this.recentAlerts,
  });

  factory Caregiver.defaultDemo() {
    return const Caregiver(
      id: 'CG-801',
      name: 'Priya Sharma',
      relation: 'Daughter / Primary Caregiver',
      phoneNumber: '+91 98401 23456',
      email: 'priya.sharma@example.com',
      isPrimaryEmergencyRecipient: true,
      isConnected: true,
      lastActive: 'Active 5m ago',
      recentAlerts: [
        'Checked SOS notification (Today, 1:20 PM)',
        'Acknowledged morning medication dose (Today, 8:45 AM)',
        'Reviewed weekly ECG trend report (Yesterday)',
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'phone_number': phoneNumber,
      'email': email,
      'is_primary_emergency_recipient': isPrimaryEmergencyRecipient,
      'is_connected': isConnected,
      'last_active': lastActive,
      'recent_alerts': recentAlerts,
    };
  }
}
