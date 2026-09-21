import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'innerscape_daily';
  static const _channelName = 'Daily Reminder';
  static const _notificationId = 0;

  static const _keyReminderHour = 'reminder_hour';
  static const _keyReminderMinute = 'reminder_minute';
  static const _keyReminderEnabled = 'reminder_enabled';

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await cancelReminder(); // Cancel existing notification before rescheduling

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily journaling reminder',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        'Take a moment to reflect on your day. Your aura is waiting ✨',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _notificationId,
      'Time to reflect ✨',
      'Take a moment to journal your day on Innerscape',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
    );

    // Save preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderHour, time.hour);
    await prefs.setInt(_keyReminderMinute, time.minute);
    await prefs.setBool(_keyReminderEnabled, true);
  }

  static Future<void> cancelReminder() async {
    await _plugin.cancel(_notificationId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, false);
  }

  static Future<TimeOfDay> getSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyReminderHour) ?? 20; // Default 8:00 PM
    final minute = prefs.getInt(_keyReminderMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReminderEnabled) ?? false;
  }
}
