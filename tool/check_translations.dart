#!/usr/bin/env dart
// tool/check_translations.dart
//
// Validates that every .arb locale file contains exactly the same message keys
// as the template (app_de.arb).  Exits with code 1 on missing/extra keys.
//
// Usage:
//   dart run tool/check_translations.dart
//   dart run tool/check_translations.dart --fix   # adds missing keys with TODO markers
//
// Integrate into CI or git pre-commit hook to catch translation gaps early.

import 'dart:convert';
import 'dart:io';

const arbDir = 'lib/l10n';
const templateFile = 'app_de.arb';

void main(List<String> args) {
  final fix = args.contains('--fix');

  final templatePath = '$arbDir/$templateFile';
  final templateRaw = File(templatePath).readAsStringSync();
  final template = jsonDecode(templateRaw) as Map<String, dynamic>;

  // Collect message keys (exclude @@locale and @-metadata keys)
  final templateKeys = template.keys
      .where((k) => !k.startsWith('@@') && !k.startsWith('@'))
      .toSet();

  final dir = Directory(arbDir);
  final arbFiles = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb') && !f.path.endsWith(templateFile))
      .where((f) => !f.path.contains('app_localizations')) // skip generated
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  var hasErrors = false;
  final summary = <String, ({int missing, int extra})>{};

  for (final file in arbFiles) {
    final raw = file.readAsStringSync();
    final locale = jsonDecode(raw) as Map<String, dynamic>;
    final localeCode = locale['@@locale'] ?? file.path;

    final localeKeys = locale.keys
        .where((k) => !k.startsWith('@@') && !k.startsWith('@'))
        .toSet();

    final missing = templateKeys.difference(localeKeys);
    final extra = localeKeys.difference(templateKeys);

    if (missing.isNotEmpty || extra.isNotEmpty) {
      hasErrors = true;
    }

    summary[localeCode as String] = (missing: missing.length, extra: extra.length);

    if (missing.isNotEmpty) {
      stdout.writeln('');
      stdout.writeln('❌ $localeCode – ${missing.length} missing key(s):');
      for (final key in missing.toList()..sort()) {
        final templateValue = template[key];
        stdout.writeln('   • $key');
        if (fix) {
          // Add the key with a TODO marker so the translator knows what to translate
          locale[key] = 'TODO:$localeCode: $templateValue';
        }
      }
    }

    if (extra.isNotEmpty) {
      stdout.writeln('');
      stdout.writeln('⚠️  $localeCode – ${extra.length} extra key(s) not in template:');
      for (final key in extra.toList()..sort()) {
        stdout.writeln('   • $key');
      }
    }

    if (fix && missing.isNotEmpty) {
      // Rewrite the file with ordered keys: @@locale first, then sorted message keys
      final orderedMap = <String, dynamic>{};
      orderedMap['@@locale'] = localeCode;

      // Copy keys in template order to keep files aligned
      for (final key in template.keys) {
        if (key == '@@locale') continue;
        if (locale.containsKey(key)) {
          orderedMap[key] = locale[key];
        }
      }
      // Keep any extra keys at the end
      for (final key in locale.keys) {
        if (!orderedMap.containsKey(key)) {
          orderedMap[key] = locale[key];
        }
      }

      final encoder = const JsonEncoder.withIndent('  ');
      file.writeAsStringSync('${encoder.convert(orderedMap)}\n');
      stdout.writeln('   ✏️  Fixed: added missing keys with TODO markers to $localeCode');
    }
  }

  // Print summary
  stdout.writeln('');
  stdout.writeln('─── Translation Summary ───');
  stdout.writeln('Template keys: ${templateKeys.length}');
  for (final entry in summary.entries) {
    final status = (entry.value.missing == 0 && entry.value.extra == 0) ? '✅' : '❌';
    stdout.writeln(
      '$status ${entry.key}: ${entry.value.missing} missing, ${entry.value.extra} extra',
    );
  }
  stdout.writeln('───────────────────────────');

  // Check for TODO markers in any file (translations that haven't been done)
  var todoCount = 0;
  for (final file in arbFiles) {
    final raw = file.readAsStringSync();
    final locale = jsonDecode(raw) as Map<String, dynamic>;
    for (final entry in locale.entries) {
      if (entry.value is String && (entry.value as String).startsWith('TODO:')) {
        todoCount++;
      }
    }
  }
  if (todoCount > 0) {
    stdout.writeln('');
    stdout.writeln('⚠️  $todoCount translation(s) still have TODO markers.');
    stdout.writeln('   Search for "TODO:" in lib/l10n/*.arb to find them.');
  }

  if (hasErrors && !fix) {
    stdout.writeln('');
    stdout.writeln('💡 Run with --fix to auto-add missing keys with TODO markers:');
    stdout.writeln('   dart run tool/check_translations.dart --fix');
    exit(1);
  }

  if (!hasErrors && todoCount == 0) {
    stdout.writeln('');
    stdout.writeln('🎉 All translations are complete!');
  }
}
