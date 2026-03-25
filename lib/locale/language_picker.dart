import 'package:flutter/material.dart';

import 'locale_provider.dart';

/// Shows a modal bottom sheet with all supported languages.
///
/// Call this from Settings or anywhere a language switch is needed:
/// ```dart
/// showLanguagePicker(context);
/// ```
Future<void> showLanguagePicker(BuildContext context) {
  final provider = LocaleProvider.of(context);
  final current = provider.locale;

  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded),
                    const SizedBox(width: 10),
                    Text(
                      // We intentionally keep this label static per-locale
                      // so users always recognise the picker.
                      _titleForLocale(current),
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const Divider(),
              ...LocaleProvider.supportedLocales.map((locale) {
                final info = LocaleProvider.localeLabels[locale.languageCode]!;
                final selected = locale == current;
                return ListTile(
                  leading: Text(info.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(info.name),
                  trailing: selected
                      ? const Icon(Icons.check_rounded, color: Colors.green)
                      : null,
                  selected: selected,
                  onTap: () {
                    provider.setLocale(locale);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

String _titleForLocale(Locale locale) {
  return switch (locale.languageCode) {
    'de' => 'Sprache wählen',
    'en' => 'Choose Language',
    'ru' => 'Выбрать язык',
    'tr' => 'Dil Seçin',
    'ar' => 'اختيار اللغة',
    _ => 'Language',
  };
}

/// Inline dropdown for use inside forms (e.g. registration screen).
class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = LocaleProvider.of(context);
    final current = provider.locale;

    return DropdownButtonFormField<Locale>(
      initialValue: current,
      decoration: const InputDecoration(
        labelText: '🌐',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15),
      iconEnabledColor: const Color(0xFF8E8E93),
      items: LocaleProvider.supportedLocales.map((locale) {
        final info = LocaleProvider.localeLabels[locale.languageCode]!;
        return DropdownMenuItem(
          value: locale,
          child: Text('${info.flag}  ${info.name}'),
        );
      }).toList(),
      onChanged: (locale) {
        if (locale != null) provider.setLocale(locale);
      },
    );
  }
}
