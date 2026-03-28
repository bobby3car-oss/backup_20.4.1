import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../domain/packing_item.dart';
import '../../../l10n/app_localizations.dart';

/// Result from the item editor sheet.
class PackingItemEditorResult {
  const PackingItemEditorResult({
    required this.title,
    required this.category,
    required this.isRequired,
    this.quantity = 1,
    this.note,
    this.priority = PackingPriority.normal,
  });

  final String title;
  final PackingCategory category;
  final bool isRequired;
  final int quantity;
  final String? note;
  final PackingPriority priority;
}

/// A premium bottom‑sheet editor for creating or editing a packing item.
class PackingItemEditorSheet extends StatefulWidget {
  const PackingItemEditorSheet({
    super.key,
    this.initialTitle,
    this.initialCategory,
    this.initialRequired,
    this.initialQuantity,
    this.initialNote,
    this.initialPriority,
  });

  final String? initialTitle;
  final PackingCategory? initialCategory;
  final bool? initialRequired;
  final int? initialQuantity;
  final String? initialNote;
  final PackingPriority? initialPriority;

  bool get isEditing => initialTitle != null;

  @override
  State<PackingItemEditorSheet> createState() => _PackingItemEditorSheetState();
}

class _PackingItemEditorSheetState extends State<PackingItemEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late PackingCategory _category;
  late PackingPriority _priority;
  late int _quantity;
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialTitle ?? '');
    _noteController =
        TextEditingController(text: widget.initialNote ?? '');
    _category = widget.initialCategory ?? PackingCategory.other;
    _priority = widget.initialPriority ?? PackingPriority.normal;
    _quantity = widget.initialQuantity ?? 1;
    _isRequired = widget.initialRequired ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    Navigator.of(context).pop(
      PackingItemEditorResult(
        title: title,
        category: _category,
        isRequired: _isRequired,
        quantity: _quantity,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        priority: _priority,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle ───────────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Title ────────────────────────────────────────
              Text(
                widget.isEditing ? 'Item bearbeiten' : 'Neues Item',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Name field ───────────────────────────────────
              TextField(
                controller: _titleController,
                autofocus: !widget.isEditing,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Titel',
                  hintText: l.zBZahnbuerste,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Category picker ──────────────────────────────
              DropdownButtonFormField<PackingCategory>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Kategorie',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                ),
                items: PackingCategory.values
                    .map(
                      (cat) => DropdownMenuItem<PackingCategory>(
                        value: cat,
                        child: Text(cat.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Quantity & Priority row ──────────────────────
              Row(
                children: [
                  // Quantity
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      borderRadius: AppRadius.borderRadiusMd,
                      variant: GlassVariant.thin,
                      child: Row(
                        children: [
                          const Text(
                            'Menge',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 20),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 20),
                            onPressed: _quantity < 99
                                ? () => setState(() => _quantity++)
                                : null,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Priority
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      borderRadius: AppRadius.borderRadiusMd,
                      variant: GlassVariant.thin,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PackingPriority>(
                          value: _priority,
                          isExpanded: true,
                          isDense: true,
                          items: PackingPriority.values
                              .map(
                                (p) => DropdownMenuItem<PackingPriority>(
                                  value: p,
                                  child: Text(
                                    p.label,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _priority = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Note field ───────────────────────────────────
              TextField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l.packingItemEditorSheetNotizOptional,
                  hintText: l.zbDieBlaue,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Required toggle ──────────────────────────────
              GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                borderRadius: AppRadius.borderRadiusMd,
                variant: GlassVariant.thin,
                child: Row(
                  children: [
                    const Icon(Icons.priority_high_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        l.taskRequired,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _isRequired,
                      onChanged: (v) => setState(() => _isRequired = v),
                      activeTrackColor: AppColors.error,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Submit button ────────────────────────────────
              GlassButton(
                onPressed: _submit,
                label: widget.isEditing ? l.save : l.add,
                icon: widget.isEditing
                    ? Icons.check_rounded
                    : Icons.add_rounded,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
