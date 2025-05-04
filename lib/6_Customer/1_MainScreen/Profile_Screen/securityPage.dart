import 'package:flutter/material.dart';

class AppSecurityFeaturesPage extends StatelessWidget {
  const AppSecurityFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> securityFeatures = [
      '🔑 Use strong passwords with letters, numbers, and symbols.',
      '🙅‍♂️ Never share your login credentials with anyone.',
      '🚪 Always log out from public or shared devices.',
      '🧑‍💻 Enable fingerprint or face unlock for secure access (if supported).',
      '📥 Install the app only from official stores (Google Play or App Store).',
      '📲 Keep the app updated for the latest security improvements.',
      '📷 Grant permissions only when absolutely necessary.',
      '⚠️ Report any suspicious activity to support immediately.',
      '📶 Avoid using public Wi-Fi for sensitive actions like logins or payments.',
      '📵 Do not use the app on rooted or jailbroken devices.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Security Features'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: securityFeatures.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                securityFeatures[index],
                style: const TextStyle(fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}
