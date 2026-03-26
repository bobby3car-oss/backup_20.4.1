import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the current [Locale] to the app and persists it via
/// [SharedPreferences].
///
/// Usage:
/// ```dart
/// LocaleProvider.of(context).setLocale(const Locale('en'));
/// ```
class LocaleProvider extends ChangeNotifier {
  LocaleProvider();

  static const _prefKey = 'app_locale';

  static const supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
    Locale('ar'),
  ];

  /// Human-readable labels + flag emoji, ordered the same as
  /// [supportedLocales].
  static const localeLabels = <String, ({String flag, String name})>{
    'de': (flag: '🇩🇪', name: 'Deutsch'),
    'en': (flag: '🇬🇧', name: 'English'),
    'ru': (flag: '🇷🇺', name: 'Русский'),
    'tr': (flag: '🇹🇷', name: 'Türkçe'),
    'ar': (flag: '🇸🇦', name: 'العربية'),
  };

  Locale _locale = const Locale('de');

  /// The currently active locale.
  Locale get locale => _locale;

  /// Loads the persisted locale from disk.  Call once before [runApp].
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null && supportedLocales.any((l) => l.languageCode == code)) {
      _locale = Locale(code);
    }
    // no notifyListeners – we're called before the widget tree exists.
  }

  /// Sets a new locale, persists it, and notifies listeners so the
  /// [MaterialApp] rebuilds immediately.
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    if (_locale == locale) return;
    debugPrint('[LocaleProvider] switching locale: $_locale → $locale');
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  // ── InheritedWidget-style accessor ──

  static LocaleProvider of(BuildContext context) {
    return _LocaleScope.of(context);
  }

  static LocaleProvider? maybeOf(BuildContext context) {
    return _LocaleScope.maybeOf(context);
  }
}

// ---------------------------------------------------------------------------
// Widget helpers
// ---------------------------------------------------------------------------

/// Provides [LocaleProvider] to the widget tree using an
/// [InheritedNotifier] so that dependants rebuild automatically.
class LocaleScope extends StatelessWidget {
  const LocaleScope({super.key, required this.provider, required this.child});

  final LocaleProvider provider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _LocaleScope(notifier: provider, child: child);
  }
}

class _LocaleScope extends InheritedNotifier<LocaleProvider> {
  const _LocaleScope({required super.notifier, required super.child});

  static LocaleProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_LocaleScope>();
    final notifier = scope?.notifier;
    if (notifier == null) {
      throw FlutterError('No LocaleScope found in context');
    }
    return notifier;
  }

  static LocaleProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_LocaleScope>()
        ?.notifier;
  }
}
