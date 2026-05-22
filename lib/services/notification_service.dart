import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationResponse(NotificationResponse response) {}

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await _plugin.zonedSchedule(
      id,
      'Task: $title',
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Reminders for your scheduled tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFF7C3AED),
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleDailyBriefing({
    required int hour,
    required int minute,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      9999,
      'Daily Briefing',
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_briefing', 'Daily Briefing',
          channelDescription: 'Morning summary of your tasks',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleAlarm({
    required int id,
    required String label,
    required int hour,
    required int minute,
    required List<bool> repeatDays,
    String? customSoundPath,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final hasRepeat = repeatDays.any((d) => d);

    await _plugin.zonedSchedule(
      id,
      'Alarm: $label',
      'Your alarm is ringing!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarms', 'Alarms',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          icon: '@mipmap/launcher_icon',
          sound: customSoundPath != null ? UriAndroidNotificationSound(customSoundPath) : null,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, sound: customSoundPath),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: hasRepeat ? DateTimeComponents.dayOfWeekAndTime : null,
    );
  }

  Future<void> showPomodoroComplete({required bool isBreak, required int sessionCount}) async {
    await _plugin.show(
      8888,
      isBreak ? 'Break time!' : 'Focus session complete!',
      isBreak ? 'Take a well-deserved break.' : 'Session #$sessionCount done.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro', 'Pomodoro',
          channelDescription: 'Pomodoro timer notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: Color(0xFFEF4444),
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }

  Future<void> cancelNotification(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var s = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (s.isBefore(now)) s = s.add(const Duration(days: 1));
    return s;
  }
}
