import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class CategoryStyle {
  const CategoryStyle({
    required this.color,
    required this.key,
    this.asset,
    this.icon = Icons.place,
  });

  final Color color;

  /// Lowercase category name ("pura"), or "" for unknown categories.
  final String key;

  /// Monochrome SVG glyph in assets/icons; [icon] is the fallback.
  final String? asset;
  final IconData icon;

  /// Category name in the app language.
  String labelOf(AppLocalizations l10n) => switch (key) {
    'tradisi' => l10n.catTradisi,
    'pura' => l10n.catPura,
    'masjid' => l10n.catMasjid,
    'gereja' => l10n.catGereja,
    'vihara' => l10n.catVihara,
    'klenteng' => l10n.catKlenteng,
    'kuliner' => l10n.catKuliner,
    _ => l10n.catOther,
  };

  /// Visiting etiquette shown on the location detail page.
  List<String> etiquetteOf(AppLocalizations l10n) => switch (key) {
    'tradisi' => [
      l10n.etqTradisi1,
      l10n.etqTradisi2,
      l10n.etqTradisi3,
      l10n.etqTradisi4,
      l10n.etqTradisi5,
    ],
    'pura' => [
      l10n.etqPura1,
      l10n.etqPura2,
      l10n.etqPura3,
      l10n.etqPura4,
      l10n.etqPura5,
    ],
    'masjid' => [
      l10n.etqMasjid1,
      l10n.etqMasjid2,
      l10n.etqMasjid3,
      l10n.etqMasjid4,
    ],
    'gereja' => [l10n.etqGereja1, l10n.etqGereja2, l10n.etqGereja3],
    'vihara' => [
      l10n.etqVihara1,
      l10n.etqVihara2,
      l10n.etqVihara3,
      l10n.etqVihara4,
    ],
    'klenteng' => [
      l10n.etqKlenteng1,
      l10n.etqKlenteng2,
      l10n.etqKlenteng3,
      l10n.etqKlenteng4,
    ],
    'kuliner' => [
      l10n.etqKuliner1,
      l10n.etqKuliner2,
      l10n.etqKuliner3,
      l10n.etqKuliner4,
    ],
    _ => [l10n.etqGeneral1, l10n.etqGeneral2, l10n.etqGeneral3],
  };
}

const _styles = <String, CategoryStyle>{
  'tradisi': CategoryStyle(
    color: Color(0xFF8E3B5E),
    key: 'tradisi',
    asset: 'assets/icons/tradisi.svg',
  ),
  'pura': CategoryStyle(
    color: Color(0xFFA87618),
    key: 'pura',
    asset: 'assets/icons/pura.svg',
  ),
  'masjid': CategoryStyle(
    color: Color(0xFF1F7A5C),
    key: 'masjid',
    asset: 'assets/icons/masjid.svg',
  ),
  'gereja': CategoryStyle(
    color: Color(0xFF2B5C8A),
    key: 'gereja',
    asset: 'assets/icons/gereja.svg',
  ),
  'vihara': CategoryStyle(
    color: Color(0xFFE08E1B),
    key: 'vihara',
    asset: 'assets/icons/vihara.svg',
  ),
  'klenteng': CategoryStyle(
    color: Color(0xFFC0262D),
    key: 'klenteng',
    asset: 'assets/icons/klenteng.svg',
  ),
  'kuliner': CategoryStyle(
    color: Color(0xFF6B8E23),
    key: 'kuliner',
    asset: 'assets/icons/kuliner.svg',
  ),
};

const defaultCategoryStyle = CategoryStyle(color: Color(0xFF7A6253), key: '');

CategoryStyle categoryStyleOf(String? categoryName) =>
    _styles[categoryName?.toLowerCase()] ?? defaultCategoryStyle;
