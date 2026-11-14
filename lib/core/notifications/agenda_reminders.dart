import 'package:flutter/widgets.dart' show Locale;

import '../../domain/entities/cultural_event.dart';
import '../../l10n/app_localizations.dart';

/// One reminder to schedule on the device.
class ReminderPlan {
  const ReminderPlan({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    this.channelName = defaultReminderChannelName,
    this.channelDescription = defaultReminderChannelDescription,
  });

  final int id;

  /// Local wall-clock time to show it.
  final DateTime at;
  final String title;
  final String body;

  /// Android notification channel texts, in the app language.
  final String channelName;
  final String channelDescription;
}

const defaultReminderChannelName = 'Pengingat agenda budaya';
const defaultReminderChannelDescription =
    'Pengingat sehari sebelum dan pada hari agenda budaya berlangsung.';

/// Hours of the two reminders: the evening before and the morning of.
const reminderEveningHour = 18;
const reminderMorningHour = 7;

/// How far ahead reminders are scheduled. Re-planned on every agenda load.
const reminderWindowDays = 30;

/// iOS keeps at most 64 pending notifications per app; stay under it.
const maxPendingReminders = 60;

/// Works out which reminders to schedule for [events], as of [now]: one the
/// evening before ("Besok: ...") and one on the morning of ("Hari ini: ...")
/// each upcoming event starting within [reminderWindowDays]. Times already
/// past are skipped. Soonest first, capped at [maxPendingReminders]. Texts
/// use [languageCode], Indonesian by default.
List<ReminderPlan> planAgendaReminders(
  List<CulturalEvent> events,
  DateTime now, {
  String languageCode = 'id',
}) {
  final l10n = lookupAppLocalizations(Locale(languageCode));
  final today = DateTime(now.year, now.month, now.day);
  final until = today.add(const Duration(days: reminderWindowDays));
  final upcoming =
      events
          .where(
            (e) => !e.startDate.isBefore(today) && e.startDate.isBefore(until),
          )
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  final plans = <ReminderPlan>[];
  for (final e in upcoming) {
    final day = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
    final evening = day
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: reminderEveningHour));
    final morning = day.add(const Duration(hours: reminderMorningHour));
    final where = _where(e, l10n);
    final estimate = e.isEstimate ? ' ${l10n.reminderEstimate}' : '';

    if (evening.isAfter(now)) {
      plans.add(
        ReminderPlan(
          id: e.id * 2,
          at: evening,
          title: l10n.reminderTomorrow(e.name),
          body: '$where$estimate',
          channelName: l10n.reminderChannelName,
          channelDescription: l10n.reminderChannelDescription,
        ),
      );
    }
    if (morning.isAfter(now)) {
      plans.add(
        ReminderPlan(
          id: e.id * 2 + 1,
          at: morning,
          title: l10n.reminderToday(e.name),
          body: '$where$estimate',
          channelName: l10n.reminderChannelName,
          channelDescription: l10n.reminderChannelDescription,
        ),
      );
    }
  }
  plans.sort((a, b) => a.at.compareTo(b.at));
  return plans.take(maxPendingReminders).toList();
}

String _where(CulturalEvent e, AppLocalizations l10n) {
  final place = e.location?.name ?? '';
  final parts = [
    if (place.isNotEmpty) place,
    if (e.region.isNotEmpty) e.region,
  ];
  return parts.isEmpty ? l10n.reminderDefaultPlace : '${parts.join(', ')}.';
}

/// What the app needs from the platform to show reminders. The real one
/// wraps flutter_local_notifications; tests use a fake.
abstract interface class ReminderScheduler {
  /// [onTap] runs when the user taps a reminder while the app is running.
  Future<void> init({required void Function() onTap});

  /// Asks for permission to show notifications; true when allowed.
  Future<bool> requestPermission();

  /// Replaces every pending reminder with [plans].
  Future<void> replaceAll(List<ReminderPlan> plans);

  Future<void> cancelAll();

  /// True when this app launch came from tapping a reminder.
  Future<bool> launchedFromReminder();
}
