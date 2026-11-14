import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/location.dart';
import '../models/models.dart';

/// Non-sensitive app state stored with shared_preferences.
///
/// Storage failures (for example a missing native plugin after a hot restart)
/// are logged and treated as empty state, so they never block the UI.
class LocalPreferencesDataSource {
  LocalPreferencesDataSource();

  // getInstance() caches internally and retries after a failure, so it is
  // called per access instead of holding on to a possibly failed future.
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<T> _safe<T>(Future<T> Function() body, T fallback) async {
    try {
      return await body();
    } catch (e) {
      debugPrint('[LocalPreferences] $e');
      return fallback;
    }
  }

  static const savedKey = 'saved_places';
  static const recentKey = 'recent_places';
  static const onboardingKey = 'onboarding_completed';
  static const remindersOffKey = 'agenda_reminders_off';
  static const remindersAskedKey = 'agenda_reminders_asked';
  static const languageKey = 'app_language';

  Future<List<Location>> readPlaces(String key) => _safe(() async {
    final raw = (await _prefs).getString(key);
    if (raw == null) return const <Location>[];
    final list = jsonDecode(raw) as List;
    return list.whereType<Json>().map(LocationModel.fromJson).toList();
  }, const <Location>[]);

  Future<bool> writePlaces(String key, List<Location> places) => _safe(
    () async => (await _prefs).setString(
      key,
      jsonEncode([for (final p in places) p.toJson()]),
    ),
    false,
  );

  Future<bool> readBool(String key) =>
      _safe(() async => (await _prefs).getBool(key) ?? false, false);

  Future<bool> writeBool(String key, bool value) =>
      _safe(() async => (await _prefs).setBool(key, value), false);

  Future<String?> readString(String key) =>
      _safe(() async => (await _prefs).getString(key), null);

  Future<bool> writeString(String key, String? value) => _safe(() async {
    final prefs = await _prefs;
    return value == null ? prefs.remove(key) : prefs.setString(key, value);
  }, false);
}
