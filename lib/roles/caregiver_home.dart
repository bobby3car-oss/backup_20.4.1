import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class CaregiverHome extends StatelessWidget {
  const CaregiverHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Caregiver Home'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async => AuthService().signOut(),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
