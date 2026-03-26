import 'package:flutter/material.dart';

import '../domain/doctor_question.dart';
import '../../../l10n/app_localizations.dart';

class QuestionEditorResult {
  const QuestionEditorResult({required this.text, required this.category});

  final String text;
  final QuestionCategory category;
}

class QuestionEditorDialog extends StatefulWidget {
  const QuestionEditorDialog({
    super.key,
    this.initialText,
    this.initialCategory = QuestionCategory.surgeon,
    this.title = 'Neue Frage',
  });

  final String? initialText;
  final QuestionCategory initialCategory;
  final String title;

  @override
  State<QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<QuestionEditorDialog> {
  late final TextEditingController _controller;
  late QuestionCategory _category;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Frage'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<QuestionCategory>(
            initialValue: _category,
            items: QuestionCategory.values
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _category = value);
            },
            decoration: const InputDecoration(labelText: 'Kategorie'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            Navigator.of(
              context,
            ).pop(QuestionEditorResult(text: text, category: _category));
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}
