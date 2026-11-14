/// On-device settings for agenda reminders.
abstract interface class ReminderSettingsRepository {
  /// Reminders are on unless the user turned them off.
  Future<bool> isEnabled();
  Future<void> setEnabled(bool enabled);

  /// Whether the notification permission prompt was already shown once.
  Future<bool> wasAsked();
  Future<void> setAsked();
}
