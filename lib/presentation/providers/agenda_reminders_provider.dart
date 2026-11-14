import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../../core/notifications/agenda_reminders.dart';
import '../../domain/entities/cultural_event.dart';
import '../../domain/repositories/reminder_settings_repository.dart';

/// Keeps the device's agenda reminders in step with the Agenda Budaya data
/// and the user's on/off setting. Fed by the agenda through [onEvents].
class AgendaRemindersProvider extends ChangeNotifier {
  AgendaRemindersProvider({
    required this._scheduler,
    required this._settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ReminderScheduler _scheduler;
  final ReminderSettingsRepository _settings;
  final DateTime Function() _clock;

  bool _enabled = true;
  bool _settingsLoaded = false;
  bool _agendaLoaded = false;
  bool? _permissionGranted;
  List<CulturalEvent> _events = const [];
  String _signature = '';
  String _languageCode = 'id';

  /// Runs syncs one after another so they never interleave.
  Future<void> _queue = Future.value();

  bool get enabled => _enabled;

  /// False when the user declined notifications; null when not asked yet.
  bool? get permissionGranted => _permissionGranted;

  Future<void> load() async {
    _enabled = await _settings.isEnabled();
    _settingsLoaded = true;
    notifyListeners();
    _sync();
  }

  /// Called whenever the agenda changes. Only a loaded agenda is used, so a
  /// failed (offline) load never wipes reminders already scheduled.
  void onEvents(List<CulturalEvent> events, {required bool loaded}) {
    if (!loaded) return;
    final signature = [
      for (final e in events)
        '${e.id}:${e.name}:${e.startDate.toIso8601String()}:${e.isEstimate}',
    ].join('|');
    if (_agendaLoaded && signature == _signature) return;
    _agendaLoaded = true;
    _signature = signature;
    _events = events;
    _sync();
  }

  /// Sets the language of reminder texts and re-plans them when it changes.
  void setLanguage(String languageCode) {
    if (languageCode == _languageCode) return;
    _languageCode = languageCode;
    _sync();
  }

  /// Turns reminders on or off. Turning them on asks for permission again.
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    notifyListeners();
    await _settings.setEnabled(enabled);
    if (enabled) {
      _permissionGranted = await _scheduler.requestPermission();
      await _settings.setAsked();
      notifyListeners();
    }
    await _sync();
  }

  Future<void> _sync() => _queue = _queue.then((_) async {
    if (!_settingsLoaded || !_agendaLoaded) return;
    try {
      if (!_enabled) {
        await _scheduler.cancelAll();
        return;
      }
      if (!await _settings.wasAsked()) {
        await _settings.setAsked();
        _permissionGranted = await _scheduler.requestPermission();
        notifyListeners();
      }
      await _scheduler.replaceAll(
        planAgendaReminders(_events, _clock(), languageCode: _languageCode),
      );
    } catch (e) {
      debugPrint('[Reminders] sync failed: $e');
    }
  });
}
