// settings_service.dart
import 'package:hive/hive.dart';

class SettingsService {
  static const String _boxName = "settings";
  static const String _biometricKey = "biometric_enabled";

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static bool isBiometricEnabled() {
    final box = Hive.box(_boxName);
    return box.get(_biometricKey, defaultValue: false);
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final box = Hive.box(_boxName);
    await box.put(_biometricKey, enabled);
  }
}
