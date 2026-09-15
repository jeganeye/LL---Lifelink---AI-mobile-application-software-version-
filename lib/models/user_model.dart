/// Model representing the registered user/patient profile.
class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final String bloodGroup;
  final double weightKg;
  final double heightCm;
  final List<String> medicalConditions;
  final String emergencyPhone;
  final String preferredLanguage;
  final bool notificationsEnabled;
  final bool biometricsEnabled;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.bloodGroup,
    required this.weightKg,
    required this.heightCm,
    required this.medicalConditions,
    required this.emergencyPhone,
    this.preferredLanguage = 'English (India)',
    this.notificationsEnabled = true,
    this.biometricsEnabled = true,
  });

  factory UserModel.defaultDemo() {
    return const UserModel(
      id: 'USR-2026-SIH',
      name: 'Ramesh Kumar',
      email: 'ramesh.kumar@lifelink.ai',
      age: 58,
      bloodGroup: 'B+ (Positive)',
      weightKg: 72.5,
      heightCm: 172.0,
      medicalConditions: ['Mild Hypertension', 'Type-2 Glycemic Sensitivity'],
      emergencyPhone: '+91 98401 23456',
      preferredLanguage: 'English (India)',
      notificationsEnabled: true,
      biometricsEnabled: true,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? bloodGroup,
    double? weightKg,
    double? heightCm,
    List<String>? medicalConditions,
    String? emergencyPhone,
    String? preferredLanguage,
    bool? notificationsEnabled,
    bool? biometricsEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'blood_group': bloodGroup,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'medical_conditions': medicalConditions,
      'emergency_phone': emergencyPhone,
      'preferred_language': preferredLanguage,
      'notifications_enabled': notificationsEnabled,
      'biometrics_enabled': biometricsEnabled,
    };
  }
}
