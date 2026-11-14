import 'package:flutter/widgets.dart';

import '../core/error/errors.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Languages the app ships, in the order the picker lists them.
const appLocales = [
  Locale('id'),
  Locale('en'),
  Locale('ko'),
  Locale('ja'),
  Locale('zh'),
];

/// Each language's own name, shown in the picker.
const languageNames = {
  'id': 'Bahasa Indonesia',
  'en': 'English',
  'ko': '한국어',
  'ja': '日本語',
  'zh': '中文',
};

/// Indonesian is the fallback when the device language is not supported.
Locale resolveAppLocale(Locale? device) {
  for (final locale in appLocales) {
    if (locale.languageCode == device?.languageCode) return locale;
  }
  return appLocales.first;
}

extension AppLocalizationsX on BuildContext {
  /// Strings for the current language. Falls back to Indonesian when no
  /// localizations are in the tree (bare widget tests).
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(appLocales.first);
}

extension LanguageNameL10n on AppLocalizations {
  /// Name of the language [code] written in the current app language,
  /// e.g. "Korea" for "ko" while the app is in Indonesian.
  String languageName(String code) => switch (code) {
    'en' => langNameEn,
    'ko' => langNameKo,
    'ja' => langNameJa,
    'zh' => langNameZh,
    _ => langNameId,
  };

  /// Native name plus, when it differs, the name in the app language:
  /// "한국어 (Korea)".
  String languageLabel(String code) {
    final native = languageNames[code]!;
    final local = languageName(code);
    return native == local ? native : '$native ($local)';
  }
}

extension AppErrorL10n on AppLocalizations {
  /// User-facing message for [error]. Server messages pass through; the
  /// app's own defaults are translated.
  String errorMessage(AppError error) => switch (error) {
    NetworkError(message: NetworkError.defaultMessage) => errorNetwork,
    NotFoundError(message: NotFoundError.defaultMessage) => errorNotFound,
    UnauthorizedError(message: UnauthorizedError.defaultMessage) =>
      errorUnauthorized,
    UnauthorizedError(message: UnauthorizedError.signInToSavePlace) =>
      savedSignInPlaceRequired,
    UnauthorizedError(message: UnauthorizedError.signInToSavePlan) =>
      savedSignInPlanRequired,
    ValidationError(message: ValidationError.defaultMessage) => errorValidation,
    ServerError(message: ServerError.defaultMessage) => errorServer,
    AppError(message: AppError.defaultMessage) => errorUnknown,
    _ => error.message,
  };
}
