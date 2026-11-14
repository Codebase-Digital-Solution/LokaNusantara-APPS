import 'package:bali_guide_map/core/notifications/agenda_reminders.dart';
import 'package:bali_guide_map/domain/entities/cultural_event.dart';
import 'package:bali_guide_map/domain/repositories/reminder_settings_repository.dart';
import 'package:bali_guide_map/presentation/providers/agenda_reminders_provider.dart';
import 'package:flutter_test/flutter_test.dart';

CulturalEvent ev(int id, DateTime start, {bool estimate = false}) =>
    CulturalEvent(
      id: id,
      name: 'Acara $id',
      description: '',
      category: 'tradisi',
      startDate: start,
      isEstimate: estimate,
      region: 'Gianyar',
    );

class FakeScheduler implements ReminderScheduler {
  List<ReminderPlan>? scheduled;
  int permissionRequests = 0;
  int cancels = 0;
  bool grant = true;

  @override
  Future<void> init({required void Function() onTap}) async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async => scheduled = plans;

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled = const [];
  }

  @override
  Future<bool> launchedFromReminder() async => false;
}

class MemSettings implements ReminderSettingsRepository {
  bool enabled = true;
  bool asked = false;

  @override
  Future<bool> isEnabled() async => enabled;
  @override
  Future<void> setEnabled(bool v) async => enabled = v;
  @override
  Future<bool> wasAsked() async => asked;
  @override
  Future<void> setAsked() async => asked = true;
}

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  final now = DateTime(2026, 11, 12, 10); // Thursday 10:00

  test('plans an evening-before and a morning-of reminder per event', () {
    final plans = planAgendaReminders([ev(1, DateTime(2026, 11, 20))], now);
    expect(plans.map((p) => p.at), [
      DateTime(2026, 11, 19, 18),
      DateTime(2026, 11, 20, 7),
    ]);
    expect(plans.first.title, 'Besok: Acara 1');
    expect(plans.last.title, 'Hari ini: Acara 1');
    expect(plans.first.body, 'Gianyar.');
    expect(plans.map((p) => p.id).toSet(), hasLength(2));
  });

  test('reminder texts follow the app language', () {
    final plans = planAgendaReminders(
      [ev(1, DateTime(2026, 11, 20), estimate: true)],
      now,
      languageCode: 'en',
    );
    expect(plans.first.title, 'Tomorrow: Acara 1');
    expect(plans.last.title, 'Today: Acara 1');
    expect(
      plans.first.body,
      'Gianyar. Estimated date, check local announcements.',
    );
    expect(plans.first.channelName, 'Cultural event reminders');
  });

  test('skips past times, past events, and events beyond the window', () {
    final plans = planAgendaReminders([
      ev(1, DateTime(2026, 11, 12)), // today: 07:00 already passed
      ev(2, DateTime(2026, 11, 13)), // tomorrow: both still ahead
      ev(3, DateTime(2026, 11, 1)), // over
      ev(4, DateTime(2027, 1, 30)), // too far
    ], now);
    expect(plans.map((p) => p.title), ['Besok: Acara 2', 'Hari ini: Acara 2']);
  });

  test('estimated dates say so', () {
    final plans = planAgendaReminders([
      ev(1, DateTime(2026, 11, 20), estimate: true),
    ], now);
    expect(plans.first.body, contains('perkiraan'));
  });

  test('never exceeds the pending limit', () {
    final many = [
      for (var i = 1; i <= 50; i++) ev(i, DateTime(2026, 11, 14 + (i % 15))),
    ];
    expect(planAgendaReminders(many, now).length, maxPendingReminders);
  });

  group('AgendaRemindersProvider', () {
    test(
      'asks permission once, then schedules from the loaded agenda',
      () async {
        final scheduler = FakeScheduler();
        final settings = MemSettings();
        final p = AgendaRemindersProvider(
          scheduler: scheduler,
          settings: settings,
          clock: () => now,
        );
        await p.load();
        p.onEvents([ev(1, DateTime(2026, 11, 20))], loaded: false);
        await settle();
        expect(scheduler.scheduled, isNull, reason: 'agenda not loaded yet');

        p.onEvents([ev(1, DateTime(2026, 11, 20))], loaded: true);
        await settle();
        expect(scheduler.permissionRequests, 1);
        expect(scheduler.scheduled, hasLength(2));

        // Same agenda again: nothing to redo, no second prompt.
        scheduler.scheduled = null;
        p.onEvents([ev(1, DateTime(2026, 11, 20))], loaded: true);
        await settle();
        expect(scheduler.scheduled, isNull);
        expect(scheduler.permissionRequests, 1);
      },
    );

    test('turning reminders off cancels them and is remembered', () async {
      final scheduler = FakeScheduler();
      final settings = MemSettings();
      final p = AgendaRemindersProvider(
        scheduler: scheduler,
        settings: settings,
        clock: () => now,
      );
      await p.load();
      p.onEvents([ev(1, DateTime(2026, 11, 20))], loaded: true);
      await settle();

      await p.setEnabled(false);
      expect(scheduler.scheduled, isEmpty);
      expect(settings.enabled, isFalse);

      await p.setEnabled(true);
      expect(scheduler.scheduled, hasLength(2));
    });
  });
}
