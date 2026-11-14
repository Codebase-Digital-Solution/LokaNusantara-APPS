import 'package:flutter/material.dart';

import 'di/service_locator.dart';
import 'presentation/app.dart';
import 'presentation/navigation/root_navigator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locator = ServiceLocator();
  try {
    await locator.reminderScheduler.init(onTap: openNotificationsFromReminder);
  } catch (e) {
    // Reminders are optional: the app still runs without them.
    debugPrint('[Reminders] init failed: $e');
  }
  runApp(LokaNusantaraApp(locator: locator));
}
