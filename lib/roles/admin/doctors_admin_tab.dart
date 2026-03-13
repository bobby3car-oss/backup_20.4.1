import 'package:flutter/material.dart';

import 'doctor_management_tab.dart';
import 'doctor_verification_tab.dart';

/// Wrapper that combines doctor verification and doctor management
/// into a single tabbed view for the admin "Ärzte" section.
class DoctorsAdminTab extends StatelessWidget {
  const DoctorsAdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: cs.surface,
            child: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.verified_outlined),
                  text: 'Verifizierung',
                ),
                Tab(
                  icon: Icon(Icons.manage_accounts_outlined),
                  text: 'Verwaltung',
                ),
              ],
              indicatorColor: cs.primary,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                DoctorVerificationTab(),
                DoctorManagementTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
