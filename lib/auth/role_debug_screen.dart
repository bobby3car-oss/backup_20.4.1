import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_profile_service.dart';

class RoleDebugScreen extends StatefulWidget {
  const RoleDebugScreen({super.key, UserProfileService? profileService})
    : _profileService = profileService;

  final UserProfileService? _profileService;

  @override
  State<RoleDebugScreen> createState() => _RoleDebugScreenState();
}

class _RoleDebugScreenState extends State<RoleDebugScreen> {
  final _profileService = UserProfileService();

  @override
  Widget build(BuildContext context) {
    final service = widget._profileService ?? _profileService;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Role Debug')),
      body: FutureBuilder<(AppUserRole, int)>(
        future: _loadDebug(service),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final role = snapshot.data!.$1;
          final linkedCount = snapshot.data!.$2;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('UID'), subtitle: Text(uid)),
              ListTile(title: const Text('Role'), subtitle: Text(role.name)),
              ListTile(
                title: const Text('Linked Patients'),
                subtitle: Text('$linkedCount'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<(AppUserRole, int)> _loadDebug(UserProfileService service) async {
    final role = await service.getMyRole();
    final linkedCount = await service.getLinkedPatientsCount();
    return (role, linkedCount);
  }
}
