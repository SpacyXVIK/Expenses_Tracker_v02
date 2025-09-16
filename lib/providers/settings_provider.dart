import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SettingsProvider with ChangeNotifier {
  static const String _boxName = "user_settings";
  late Box _settingsBox;

  bool _useBiometrics = false;

  bool get useBiometrics => _useBiometrics;

  /// Initialize Hive box (call this in main before runApp)
  Future<void> init() async {
    _settingsBox = await Hive.openBox(_boxName);
    _useBiometrics = _settingsBox.get("useBiometrics", defaultValue: false);
  }

  void toggleBiometrics(bool value) {
    _useBiometrics = value;
    _settingsBox.put("useBiometrics", value);
    notifyListeners();
  }
}
