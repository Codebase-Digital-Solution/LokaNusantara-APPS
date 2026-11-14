import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'agenda_reminders.dart';

/// Reminders through flutter_local_notifications. Scheduled with inexact
/// timing on Android, so no exact-alarm permission is needed; a reminder
/// may arrive a few minutes late, which is fine for "tomorrow" and "today".
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Channel texts come from the plan so Android settings show them in the
  /// app language (Android updates the name on the next notification).
  static NotificationDetails _details(ReminderPlan plan) => NotificationDetails(
    android: AndroidNotificationDetails(
      'agenda_reminders',
      plan.channelName,
      channelDescription: plan.channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_stat_loka',
      color: const Color(0xFFA9432A),
    ),
    iOS: const DarwinNotificationDetails(),
  );

  @override
  Future<void> init({required void Function() onTap}) async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      // Unknown zone name: fall back to Bali time (WITA).
      debugPrint('[Reminders] timezone: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Makassar'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_loka'),
        // Ask for permission later, when reminders are first scheduled.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (_) => onTap(),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    for (final p in plans) {
      await _plugin.zonedSchedule(
        id: p.id,
        title: p.title,
        body: p.body,
        scheduledDate: tz.TZDateTime(
          tz.local,
          p.at.year,
          p.at.month,
          p.at.day,
          p.at.hour,
          p.at.minute,
        ),
        notificationDetails: _details(p),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'agenda',
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    if (_ready) await _plugin.cancelAll();
  }

  @override
  Future<bool> launchedFromReminder() async {
    if (!_ready) return false;
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }
}
