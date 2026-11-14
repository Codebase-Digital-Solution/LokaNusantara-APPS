import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';

/// Bottom sheet listing the app languages plus "use device language".
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<LocaleProvider>();
    final selected = provider.selected;

    Widget option({
      required String label,
      required Locale? value,
      String? subtitle,
    }) {
      final active = selected?.languageCode == value?.languageCode;
      return ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: active
            ? const Icon(Icons.check_circle, color: AppColors.terakota)
            : null,
        onTap: () {
          provider.select(value);
          Navigator.of(context).pop();
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              l10n.chooseLanguage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l10n.contentLanguageNote,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          option(
            label: l10n.followSystem,
            value: null,
            subtitle: l10n.languageLabel(
              resolveAppLocale(
                WidgetsBinding.instance.platformDispatcher.locale,
              ).languageCode,
            ),
          ),
          for (final locale in appLocales)
            option(
              label: languageNames[locale.languageCode]!,
              value: locale,
              subtitle: _translatedName(l10n, locale.languageCode),
            ),
        ],
      ),
    );
  }
}

/// The language's name in the current app language, or null when it reads
/// the same as the native name (the language currently in use).
String? _translatedName(AppLocalizations l10n, String code) {
  final local = l10n.languageName(code);
  return local == languageNames[code] ? null : local;
}
