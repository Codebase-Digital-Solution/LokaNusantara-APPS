import 'package:bali_guide_map/core/utils/date_format.dart';
import 'package:bali_guide_map/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final id = lookupAppLocalizations(const Locale('id'));
final en = lookupAppLocalizations(const Locale('en'));

void main() {
  test('longDate uses Indonesian names', () {
    expect(longDate(DateTime(2027, 1, 13), id), 'Rabu, 13 Januari 2027');
  });

  test('dateRange shortens ranges in the same year', () {
    expect(
      dateRange(DateTime(2027, 6, 12), DateTime(2027, 7, 10), id),
      '12 Jun - 10 Jul 2027',
    );
    expect(
      dateRange(DateTime(2026, 12, 30), DateTime(2027, 1, 2), id),
      '30 Des 2026 - 2 Jan 2027',
    );
  });

  test('countdownLabel', () {
    final today = DateTime(2026, 11, 8);
    final d = DateTime(2026, 11, 8);
    expect(countdownLabel(d, d, id, today: today), 'Hari ini');
    expect(
      countdownLabel(
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 9),
        id,
        today: today,
      ),
      'Besok',
    );
    expect(
      countdownLabel(
        DateTime(2026, 11, 12),
        DateTime(2026, 11, 12),
        id,
        today: today,
      ),
      'Dalam 4 hari',
    );
    expect(
      countdownLabel(
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 30),
        id,
        today: today,
      ),
      'Sedang berlangsung',
    );
    expect(
      countdownLabel(
        DateTime(2027, 1, 13),
        DateTime(2027, 1, 13),
        id,
        today: today,
      ),
      'Dalam 2 bulan',
    );
  });
  test('formats follow the app language', () {
    expect(longDate(DateTime(2027, 1, 13), en), 'Wednesday, January 13, 2027');
    final today = DateTime(2026, 11, 8);
    expect(
      countdownLabel(
        DateTime(2026, 11, 12),
        DateTime(2026, 11, 12),
        en,
        today: today,
      ),
      'In 4 days',
    );
  });
}
