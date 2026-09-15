import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Health Risk status classification for Edge AI / TinyML inference.
enum RiskStatus {
  normal,
  warning,
  emergency;

  String get label {
    switch (this) {
      case RiskStatus.normal:
        return 'NORMAL';
      case RiskStatus.warning:
        return 'WARNING';
      case RiskStatus.emergency:
        return 'EMERGENCY';
    }
  }

  Color get color {
    switch (this) {
      case RiskStatus.normal:
        return AppColors.statusNormal;
      case RiskStatus.warning:
        return AppColors.statusWarning;
      case RiskStatus.emergency:
        return AppColors.statusEmergency;
    }
  }

  Color get bgColor {
    switch (this) {
      case RiskStatus.normal:
        return AppColors.statusNormalBg;
      case RiskStatus.warning:
        return AppColors.statusWarningBg;
      case RiskStatus.emergency:
        return AppColors.statusEmergencyBg;
    }
  }

  IconData get icon {
    switch (this) {
      case RiskStatus.normal:
        return Icons.check_circle_outline;
      case RiskStatus.warning:
        return Icons.warning_amber_rounded;
      case RiskStatus.emergency:
        return Icons.emergency;
    }
  }

  static RiskStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'WARNING':
        return RiskStatus.warning;
      case 'EMERGENCY':
        return RiskStatus.emergency;
      case 'NORMAL':
      default:
        return RiskStatus.normal;
    }
  }
}
