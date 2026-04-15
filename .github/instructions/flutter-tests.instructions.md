---
applyTo: "test/**"
---

# Flutter Testing Conventions

## Test Setup
- Run: `flutter test` (all) or `flutter test test/path/to_test.dart`
- Analyze: `dart analyze`

## Localization in Tests
Widget tests need `AppLocalizations` mocking. Key pattern:
```dart
await tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('de'),
    home: MyWidget(),
  ),
);
```

## Reference
Read `/memories/repo/widget_test_localization_notes.md` for full mocking patterns.
