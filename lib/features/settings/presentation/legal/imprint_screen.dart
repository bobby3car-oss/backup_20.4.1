import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../../../ui/theme/app_icons.dart';
import '../../data/legal_text_repository.dart';

class ImprintScreen extends StatefulWidget {
  const ImprintScreen({super.key});

  @override
  State<ImprintScreen> createState() => _ImprintScreenState();
}

class _ImprintScreenState extends State<ImprintScreen> {
  final _repo = LegalTextRepository();
  late List<LegalSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = _repo.fallbackFor('imprint');
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final remote = await _repo.fetch('imprint');
    if (mounted && remote != _sections) {
      setState(() => _sections = remote);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPage(
      title: l.settingsImprint,
      titleIcon: AppIcons.documents,
      titleColor: AppColors.textSecondary,
      children: [
        for (final s in _sections)
          _LegalSection(title: s.title, body: s.body),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
