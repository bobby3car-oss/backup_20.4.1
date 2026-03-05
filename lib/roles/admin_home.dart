import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Admin Home'),
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
