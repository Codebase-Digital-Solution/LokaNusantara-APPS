import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

var _dateDataReady = false;

/// Date patterns for [l10n]'s language. The local date data loads
/// synchronously, so this also works before (or without) the Flutter
/// localization delegates, as in plain unit tests.
DateFormat _format(
  AppLocalizations l10n,
  DateFormat Function(String locale) build,
) {
  if (!_dateDataReady) {
    initializeDateFormatting();
    _dateDataReady = true;
  }
  return build(l10n.localeName);
}

/// "Rabu, 13 Januari 2027" / "Wednesday, January 13, 2027"
String longDate(DateTime d, AppLocalizations l10n) =>
    _format(l10n, DateFormat.yMMMMEEEEd).format(d);

/// "Januari 2027"
String monthYear(DateTime d, AppLocalizations l10n) =>
    _format(l10n, DateFormat.yMMMM).format(d);

/// "13 Jan"
String shortDate(DateTime d, AppLocalizations l10n) =>
    _format(l10n, DateFormat.MMMd).format(d);

/// "13 Jan 2027"
String mediumDate(DateTime d, AppLocalizations l10n) =>
    _format(l10n, DateFormat.yMMMd).format(d);

/// "Rab"
String shortWeekday(DateTime d, AppLocalizations l10n) =>
    _format(l10n, DateFormat.E).format(d);

/// "12 Jun - 10 Jul 2027", or a single [longDate] when [end] is null.
String dateRange(DateTime start, DateTime? end, AppLocalizations l10n) {
  if (end == null || !end.isAfter(start)) return longDate(start, l10n);
  final left = start.year == end.year
      ? shortDate(start, l10n)
      : mediumDate(start, l10n);
  return '$left - ${mediumDate(end, l10n)}';
}

/// Relative label from [today] to an event spanning [start]..[end].
String countdownLabel(
  DateTime start,
  DateTime end,
  AppLocalizations l10n, {
  DateTime? today,
}) {
  final now = today ?? DateTime.now();
  final day = DateTime(now.year, now.month, now.day);
  if (!day.isBefore(start) && !day.isAfter(end)) {
    return start == end ? l10n.dateToday : l10n.dateOngoing;
  }
  if (day.isAfter(end)) return l10n.datePast;
  final days = DateTime.utc(
    start.year,
    start.month,
    start.day,
  ).difference(DateTime.utc(day.year, day.month, day.day)).inDays;
  if (days == 1) return l10n.dateTomorrow;
  if (days < 7) return l10n.dateInDays(days);
  if (days < 60) return l10n.dateInWeeks((days / 7).round());
  return l10n.dateInMonths((days / 30).round());
}
