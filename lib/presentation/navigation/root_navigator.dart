import 'package:flutter/material.dart';

import '../screens/notifications_screen.dart';

/// Navigator of the whole app, for navigation started outside the widget
/// tree (tapping an agenda reminder).
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Opens the agenda reminders page; used when a reminder is tapped.
void openNotificationsFromReminder() {
  rootNavigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
  );
}
