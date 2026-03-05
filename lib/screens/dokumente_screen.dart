import 'package:flutter/material.dart';

import '../ui/ui.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

enum DocType { arztbrief, aufklaerung, labor, rezept }

extension DocTypeMeta on DocType {
  String get label => switch (this) {
    DocType.arztbrief => 'Arztbrief',
    DocType.aufklaerung => 'Aufklärung',
    DocType.labor => 'Labor',
    DocType.rezept => 'Rezept',
  };

  IconData get icon => switch (this) {
    DocType.arztbrief => Icons.description_outlined,
    DocType.aufklaerung => Icons.fact_check_outlined,
    DocType.labor => Icons.biotech_outlined,
    DocType.rezept => Icons.medication_outlined,
  };

  Color get color => switch (this) {
    DocType.arztbrief => AppColors.primary,
    DocType.aufklaerung => AppColors.warning,
    DocType.labor => AppColors.error,
    DocType.rezept => AppColors.success,
  };
}

class _DocItem {
  const _DocItem({
    required this.title,
    required this.type,
    required this.date,
    required this.size,
    this.pages = 1,
  });

  final String title;
  final DocType type;
  final String date;
  final String size;
  final int pages;
}

// ─────────────────────────────────────────────────────────────────────────────

class DokumenteScreen extends StatefulWidget {
  const DokumenteScreen({super.key});

  @override
  State<DokumenteScreen> createState() => _DokumenteScreenState();
}

class _DokumenteScreenState extends State<DokumenteScreen> {
  DocType? _activeFilter;

  static const _documents = <_DocItem>[
    _DocItem(
      title: 'OP‑Aufklärung Knie',
      type: DocType.aufklaerung,
      date: '10. März 2026',
      size: '245 KB',
      pages: 3,
    ),
    _DocItem(
      title: 'Laborergebnisse Blutbild',
      type: DocType.labor,
      date: '15. März 2026',
      size: '128 KB',
      pages: 2,
    ),
    _DocItem(
      title: 'Arztbrief Dr. Schneider',
      type: DocType.arztbrief,
      date: '08. März 2026',
      size: '312 KB',
      pages: 4,
    ),
    _DocItem(
      title: 'Rezept Schmerzmittel',
      type: DocType.rezept,
      date: '10. März 2026',
      size: '84 KB',
    ),
    _DocItem(
      title: 'Überweisungsschein',
      type: DocType.arztbrief,
      date: '02. März 2026',
      size: '96 KB',
    ),
    _DocItem(
      title: 'Einwilligung OP',
      type: DocType.aufklaerung,
      date: '10. März 2026',
      size: '180 KB',
      pages: 2,
    ),
  ];

  List<_DocItem> get _filtered => _activeFilter == null
      ? _documents
      : _documents.where((d) => d.type == _activeFilter).toList();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: topPadding + AppSpacing.lg,
          bottom: 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            _Header(count: _filtered.length),
            const SizedBox(height: AppSpacing.xxl),

            // ── Filter chips ──────────────────────────────────
            _FilterRow(
              active: _activeFilter,
              onChanged: (t) => setState(() {
                _activeFilter = _activeFilter == t ? null : t;
              }),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Document list ─────────────────────────────────
            for (final doc in _filtered) ...[
              _DocumentCard(doc: doc),
              const SizedBox(height: AppSpacing.md),
            ],

            if (_filtered.isEmpty) ...[
              const SizedBox(height: AppSpacing.huge),
              Center(
                child: Text(
                  'Keine Dokumente in dieser Kategorie.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // ── Upload button ─────────────────────────────────
            GlassButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload – kommt bald')),
                );
              },
              label: 'Dokument hochladen',
              icon: Icons.upload_file_rounded,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.warning, Color(0xFFFFBB33)],
            ),
            borderRadius: AppRadius.borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.folder_rounded,
            size: 26,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dokumente',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '$count ${count == 1 ? 'Dokument' : 'Dokumente'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Filter chips ─────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.active, required this.onChanged});

  final DocType? active;
  final ValueChanged<DocType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in DocType.values) ...[
            _FilterChip(
              type: type,
              selected: active == type,
              onTap: () => onChanged(type),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final DocType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? type.color.withValues(alpha: 0.12)
              : AppColors.white.withValues(alpha: 0.5),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: selected
                ? type.color.withValues(alpha: 0.35)
                : AppColors.grey200,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 16,
              color: selected ? type.color : AppColors.grey500,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? type.color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Document card ────────────────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc});

  final _DocItem doc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPreview(context),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusLg,
        child: Row(
          children: [
            // ── File type icon ────────────────────────────────
            _FileIcon(type: doc.type),
            const SizedBox(width: AppSpacing.md),

            // ── Info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _TypeLabel(type: doc.type),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${doc.date} · ${doc.size}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Share button ──────────────────────────────────
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Teilen: ${doc.title}')));
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.ios_share_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _DocumentPreviewScreen(doc: doc)),
    );
  }
}

// ── File icon ────────────────────────────────────────────────────────────────

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.type});

  final DocType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: type.color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_rounded, size: 22, color: type.color),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'PDF',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: type.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Type label ───────────────────────────────────────────────────────────────

class _TypeLabel extends StatelessWidget {
  const _TypeLabel({required this.type});

  final DocType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: type.color,
        ),
      ),
    );
  }
}

// ── Document preview screen ──────────────────────────────────────────────────

class _DocumentPreviewScreen extends StatelessWidget {
  const _DocumentPreviewScreen({required this.doc});

  final _DocItem doc;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: Column(
        children: [
          // ── App bar ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: topPadding + AppSpacing.sm,
              bottom: AppSpacing.md,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    borderRadius: AppRadius.borderRadiusMd,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${doc.date} · ${doc.size}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Teilen: ${doc.title}')),
                    );
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    borderRadius: AppRadius.borderRadiusMd,
                    child: const Icon(
                      Icons.ios_share_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Type + meta bar ─────────────────────────────────
          Padding(
            padding: AppSpacing.paddingHorizontalXl,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              borderRadius: AppRadius.borderRadiusMd,
              child: Row(
                children: [
                  _TypeLabel(type: doc.type),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${doc.pages} ${doc.pages == 1 ? 'Seite' : 'Seiten'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 18,
                    color: doc.type.color,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── PDF preview placeholder ─────────────────────────
          Expanded(
            child: Padding(
              padding: AppSpacing.paddingHorizontalXl,
              child: GlassContainer(
                borderRadius: AppRadius.borderRadiusXl,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: doc.type.color.withValues(alpha: 0.08),
                          borderRadius: AppRadius.borderRadiusXxl,
                        ),
                        child: Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 36,
                          color: doc.type.color,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'PDF Vorschau',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${doc.pages} ${doc.pages == 1 ? 'Seite' : 'Seiten'} · ${doc.size}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Page thumbnails ────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          doc.pages.clamp(0, 4),
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: Container(
                              width: 52,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: AppRadius.borderRadiusSm,
                                border: Border.all(
                                  color: AppColors.grey200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withValues(
                                      alpha: 0.06,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.text_snippet_outlined,
                                    size: 18,
                                    color: AppColors.grey300,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Bottom actions ──────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Öffnen – kommt bald')),
                      );
                    },
                    label: 'Öffnen',
                    icon: Icons.open_in_new_rounded,
                    expand: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GlassButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Teilen: ${doc.title}')),
                      );
                    },
                    label: 'Teilen',
                    icon: Icons.ios_share_rounded,
                    variant: GlassButtonVariant.secondary,
                    expand: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
