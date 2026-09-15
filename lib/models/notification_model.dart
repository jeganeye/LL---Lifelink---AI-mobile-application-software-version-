import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum NotificationType {
  healthWarning,
  emergencyAlert,
  medicationReminder,
  wearableConnection,
  deviceBattery,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.healthWarning:
        return Icons.favorite_rounded;
      case NotificationType.emergencyAlert:
        return Icons.warning_rounded;
      case NotificationType.medicationReminder:
        return Icons.medication_rounded;
      case NotificationType.wearableConnection:
        return Icons.bluetooth_connected_rounded;
      case NotificationType.deviceBattery:
        return Icons.battery_alert_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.healthWarning:
        return AppColors.statusWarning;
      case NotificationType.emergencyAlert:
        return AppColors.statusEmergency;
      case NotificationType.medicationReminder:
        return AppColors.primaryLight;
      case NotificationType.wearableConnection:
        return AppColors.statusNormal;
      case NotificationType.deviceBattery:
        return AppColors.temperature;
    }
  }

  static List<NotificationItem> getDemoNotifications() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: 'NOTIF-01',
        title: 'Elevated Heart Rate Warning',
        message: 'Heart rate spiked to 112 BPM during light movement. TinyML advisory: take rest.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        type: NotificationType.healthWarning,
        isRead: false,
      ),
      NotificationItem(
        id: 'NOTIF-02',
        title: 'Emergency SOS Test Dispatch',
        message: 'Simulated SOS alert sent to primary caregiver (Priya Sharma - +91 98401 23456).',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        type: NotificationType.emergencyAlert,
        isRead: false,
      ),
      NotificationItem(
        id: 'NOTIF-03',
        title: 'Medication Schedule Due',
        message: 'Time for Afternoon dose: Multivitamin Complex 1 Capsule.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
        type: NotificationType.medicationReminder,
        isRead: true,
      ),
      NotificationItem(
        id: 'NOTIF-04',
        title: 'Wearable Connected via BLE',
        message: 'LL Lifelink Watch (ESP32-LL-9482) successfully synced health telemetry.',
        timestamp: now.subtract(const Duration(hours: 5)),
        type: NotificationType.wearableConnection,
        isRead: true,
      ),
      NotificationItem(
        id: 'NOTIF-05',
        title: 'Wearable Battery Status',
        message: 'Device battery level is 88%. Optimal for 36 hours continuous monitoring.',
        timestamp: now.subtract(const Duration(hours: 8)),
        type: NotificationType.deviceBattery,
        isRead: true,
      ),
    ];
  }
}
