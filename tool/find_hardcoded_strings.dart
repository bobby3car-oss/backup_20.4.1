#!/usr/bin/env dart
// tool/find_hardcoded_strings.dart
//
// Scans Dart files in lib/ for likely hardcoded German UI strings that
// should be moved to .arb files instead.
//
// Heuristics:
//   • Text('...') / Text("...")  with German content
//   • labelText: '...'
//   • hintText: '...'
//   • title: Text('...')
//   • SnackBar(content: Text('...'))
//   • AppBar(title: Text('...'))
//
// Excludes:
//   • Generated files (l10n/, .g.dart, .freezed.dart)
//   • Lines already using AppLocalizations / l.xxx
//   • Import/export lines
//   • Pure emoji or single-word technical strings ('Pro', 'OK', etc.)
//
// Usage:
//   dart run tool/find_hardcoded_strings.dart
//   dart run tool/find_hardcoded_strings.dart lib/screens/  # scan specific dir

import 'dart:io';

// German-specific patterns (umlauts, common German words in UI):
final _germanIndicators = RegExp(
  r'[äöüÄÖÜß]|'
  r'\b(und|oder|für|ein|eine|der|die|das|nicht|noch|wird|ist|bitte|dein|ihr)\b|'
  r'\b(Fehler|Passwort|Speichern|Abbrechen|Laden|Löschen|Weiter|Zurück)\b|'
  r'\b(Einstellungen|Profil|Konto|erstellen|bearbeiten|hinzuf[üu]gen)\b',
  caseSensitive: false,
);

// Patterns that wrap user-visible text:
final _textPatterns = RegExp(
  r"(?:const\s+)?Text\(\s*'([^']+)'\s*[,)]"
  r'|(?:const\s+)?Text\(\s*"([^"]+)"\s*[,)]'
  r"|labelText:\s*'([^']+)'"
  r'|labelText:\s*"([^"]+)"'
  r"|hintText:\s*'([^']+)'"
  r'|hintText:\s*"([^"]+)"'
  r"|title:\s*'([^']+)'"
  r'|title:\s*"([^"]+)"'
  r"|helpText:\s*'([^']+)'"
  r'|helpText:\s*"([^"]+)"'
  r"|subtitle:\s*'([^']+)'"
  r'|subtitle:\s*"([^"]+)"'
  r"|cancelText:\s*'([^']+)'"
  r"|confirmText:\s*'([^']+)'"
  r"|SnackBar\(content:\s*Text\('([^']+)'\)"
  r"|tooltip:\s*'([^']+)'"
  r"|label:\s*'([^']+)'",
);

final _skipPatterns = RegExp(
  r'AppLocalizations|\.of\(context\)!?\.|import |export |'
  r'// |/// |/\*|l\.\w+|l10n|debugPrint|kDebugMode|assert',
);

void main(List<String> args) {
  final scanDir = args.isNotEmpty ? args.first : 'lib';
  final dir = Directory(scanDir);

  if (!dir.existsSync()) {
    stderr.writeln('Directory not found: $scanDir');
    exit(2);
  }

  final dartFiles = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.contains('/l10n/'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.freezed.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  var totalFindings = 0;
  final fileFindings = <String, List<(int, String, String)>>{};

  for (final file in dartFiles) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip lines that already use localization
      if (_skipPatterns.hasMatch(line)) continue;

      final matches = _textPatterns.allMatches(line);
      for (final match in matches) {
        // Extract the first non-null group (the actual string content)
        String? text;
        for (var g = 1; g <= match.groupCount; g++) {
          if (match.group(g) != null) {
            text = match.group(g);
            break;
          }
        }
        if (text == null) continue;

        // Skip very short or purely technical strings
        if (text.length < 3) continue;
        if (text.startsWith('/') || text.startsWith('http')) continue;
        if (text.contains(r'$')) continue; // interpolation

        // Check if it contains German indicators
        if (_germanIndicators.hasMatch(text)) {
          totalFindings++;
          final relPath = file.path.replaceFirst(RegExp(r'^lib/'), '');
          fileFindings.putIfAbsent(relPath, () => []);
          fileFindings[relPath]!.add((i + 1, text, line.trim()));
        }
      }
    }
  }

  // Report
  if (totalFindings == 0) {
    stdout.writeln('✅ No hardcoded German strings found in $scanDir!');
    exit(0);
  }

  stdout.writeln('');
  stdout.writeln('╔══════════════════════════════════════════════════╗');
  stdout.writeln('║  Hardcoded German Strings Found: $totalFindings');
  stdout.writeln('╚══════════════════════════════════════════════════╝');
  stdout.writeln('');

  for (final entry in fileFindings.entries) {
    stdout.writeln('📄 ${entry.key}');
    for (final (lineNo, text, _) in entry.value) {
      stdout.writeln('   L$lineNo: "$text"');
    }
    stdout.writeln('');
  }

  stdout.writeln('💡 To fix: Move these strings to lib/l10n/app_de.arb as new keys,');
  stdout.writeln('   add translations to all other .arb files, then use');
  stdout.writeln('   AppLocalizations.of(context)!.keyName in the Dart code.');
  stdout.writeln('');
  stdout.writeln('   After adding keys, run:');
  stdout.writeln('   dart run tool/check_translations.dart --fix');
  stdout.writeln('   flutter gen-l10n');

  exit(1);
}
