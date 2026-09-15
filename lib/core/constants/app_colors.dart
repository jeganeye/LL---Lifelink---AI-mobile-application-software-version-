import 'package:flutter/material.dart';

/// Design tokens and medical color palette for LL Lifelink AI.
class AppColors {
  AppColors._();

  // Primary Medical Brand
  static const Color primary = Color(0xFF00A896);
  static const Color primaryDark = Color(0xFF028090);
  static const Color primaryLight = Color(0xFF48CAE4);
  static const Color accent = Color(0xFF00D2D3);

  // Backgrounds & Surfaces (Dark Mode - Primary Hackathon Showcase)
  static const Color bgDark = Color(0xFF0B132B);
  static const Color surfaceDark = Color(0xFF1C2541);
  static const Color surfaceDarkElevated = Color(0xFF243356);
  static const Color cardBorderDark = Color(0xFF324A75);

  // Backgrounds & Surfaces (Light Mode)
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightElevated = Color(0xFFF1F5F9);
  static const Color cardBorderLight = Color(0xFFE2E8F0);

  // Health Status Colors
  static const Color statusNormal = Color(0xFF10B981);
  static const Color statusNormalBg = Color(0x2010B981);

  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusWarningBg = Color(0x20F59E0B);

  static const Color statusEmergency = Color(0xFFEF4444);
  static const Color statusEmergencyBg = Color(0x20EF4444);

  // Metric Specific Accents
  static const Color heartRate = Color(0xFFF43F5E); // Rose
  static const Color spo2 = Color(0xFF0EA5E9);      // Sky Blue
  static const Color temperature = Color(0xFFF97316); // Orange
  static const Color activity = Color(0xFF8B5CF6);    // Purple
  static const Color airQuality = Color(0xFF10B981);  // Emerald

  // Text Colors
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMutedDark = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF028090), Color(0xFF00A896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1C2541), Color(0xFF151D33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
