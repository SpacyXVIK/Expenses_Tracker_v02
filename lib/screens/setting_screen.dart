import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Fingerprint Lock'),
            value: settingsProvider.useBiometrics,
            onChanged: (value) {
              settingsProvider.toggleBiometrics(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? "Fingerprint lock enabled"
                        : "Fingerprint lock disabled",
                  ),
                ),
              );
            },
          ),
          const Divider(),
          // 🔮 In future: Dark mode, currency, etc.
        ],
      ),
    );
  }
}
