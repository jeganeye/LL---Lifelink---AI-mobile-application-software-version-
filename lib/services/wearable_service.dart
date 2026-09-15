import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/wearable_device_model.dart';

/// Service managing wearable hardware status and telemetry sync.
///
/// NOTE FOR FUTURE HARDWARE / BACKEND INTEGRATION:
/// 1. Use `flutter_blue_plus` to scan for `LL-LIFELINK-ESP32` advertising service UUID.
/// 2. Subscribe to GATT characteristics for MAX30102, BME280, MPU6050, MQ135.
/// 3. Read battery level from ESP32 ADC pin voltage divider.
class WearableService extends ChangeNotifier {
  static final WearableService _instance = WearableService._internal();
  factory WearableService() => _instance;
  WearableService._internal() {
    _device = WearableDevice.defaultDemo();
  }

  late WearableDevice _device;

  WearableDevice get device => _device;

  /// Toggles simulated connection for prototype demonstrations.
  void toggleConnection() {
    _device = _device.copyWith(
      isConnected: !_device.isConnected,
      lastSyncTime: DateTime.now(),
    );
    notifyListeners();
  }

  /// Refreshes device diagnostics (simulates BLE handshake).
  Future<void> refreshDiagnostics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _device = _device.copyWith(
      lastSyncTime: DateTime.now(),
      batteryLevel: (_device.batteryLevel > 15) ? _device.batteryLevel - 1 : 95,
    );
    notifyListeners();
  }
}
