import 'package:flutter/widgets.dart';

import '../../data/datasources/local_preferences_data_source.dart';
import '../../l10n/l10n.dart';

/// The app language: a saved choice, or the device language when none.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._prefs, {this.onLanguageChanged});

  final LocalPreferencesDataSource _prefs;

  /// Told the effective language code whenever it may have changed, so the
  /// API can ask the server for answers in that language.
  final ValueChanged<String>? onLanguageChanged;

  Locale? _selected;

  /// The user's choice; null follows the device language.
  Locale? get selected => _selected;

  /// The language actually shown.
  Locale get locale => _selected ?? resolveAppLocale(_deviceLocale);

  Locale? get _deviceLocale =>
      WidgetsBinding.instance.platformDispatcher.locale;

  Future<void> load() async {
    final code = await _prefs.readString(
      LocalPreferencesDataSource.languageKey,
    );
    _selected = code == null ? null : resolveAppLocale(Locale(code));
    _announce();
    notifyListeners();
  }

  Future<void> select(Locale? locale) async {
    _selected = locale;
    _announce();
    notifyListeners();
    await _prefs.writeString(
      LocalPreferencesDataSource.languageKey,
      locale?.languageCode,
    );
  }

  /// Call when the device language changes while following it.
  void deviceLocaleChanged() {
    if (_selected != null) return;
    _announce();
    notifyListeners();
  }

  void _announce() => onLanguageChanged?.call(locale.languageCode);
}
