import '../../domain/entities/location.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/repositories/place_collection_repository.dart';
import '../../domain/repositories/reminder_settings_repository.dart';
import '../datasources/local_preferences_data_source.dart';

class PlaceCollectionRepositoryImpl implements PlaceCollectionRepository {
  const PlaceCollectionRepositoryImpl(this._local);
  final LocalPreferencesDataSource _local;

  @override
  Future<List<Location>> getSaved() =>
      _local.readPlaces(LocalPreferencesDataSource.savedKey);

  @override
  Future<void> setSaved(List<Location> places) =>
      _local.writePlaces(LocalPreferencesDataSource.savedKey, places);

  @override
  Future<List<Location>> getRecent() =>
      _local.readPlaces(LocalPreferencesDataSource.recentKey);

  @override
  Future<void> setRecent(List<Location> places) =>
      _local.writePlaces(LocalPreferencesDataSource.recentKey, places);
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._local);
  final LocalPreferencesDataSource _local;

  @override
  Future<bool> isCompleted() =>
      _local.readBool(LocalPreferencesDataSource.onboardingKey);

  @override
  Future<void> setCompleted(bool completed) =>
      _local.writeBool(LocalPreferencesDataSource.onboardingKey, completed);
}

class ReminderSettingsRepositoryImpl implements ReminderSettingsRepository {
  const ReminderSettingsRepositoryImpl(this._local);
  final LocalPreferencesDataSource _local;

  // Stored as "off" so a missing value means on.
  @override
  Future<bool> isEnabled() async =>
      !await _local.readBool(LocalPreferencesDataSource.remindersOffKey);

  @override
  Future<void> setEnabled(bool enabled) =>
      _local.writeBool(LocalPreferencesDataSource.remindersOffKey, !enabled);

  @override
  Future<bool> wasAsked() =>
      _local.readBool(LocalPreferencesDataSource.remindersAskedKey);

  @override
  Future<void> setAsked() =>
      _local.writeBool(LocalPreferencesDataSource.remindersAskedKey, true);
}
