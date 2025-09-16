// auth_service.dart
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) return false;

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to access your expenses',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      print("Biometric error: $e");
      return false;
    }
  }
}
