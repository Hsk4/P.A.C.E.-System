import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:just_audio/just_audio.dart';

import '../models/alarm_model.dart';
import '../services/notification_service.dart';

class AlarmProvider extends ChangeNotifier {
  late Box<AlarmModel> _box;
  List<AlarmModel> _alarms = [];
  final AudioPlayer _player = AudioPlayer();

  List<AlarmModel> get alarms => _alarms;
  List<AlarmModel> get enabledAlarms =>
      _alarms.where((a) => a.isEnabled).toList();

  AlarmProvider() {
    _box = Hive.box<AlarmModel>('alarms');
    _alarms =
        _box.values.toList()..sort((a, b) {
          final at = a.hour * 60 + a.minute;
          final bt = b.hour * 60 + b.minute;
          return at.compareTo(bt);
        });
  }

  Future<void> addAlarm({
    required String label,
    required int hour,
    required int minute,
    List<bool>? repeatDays,
    String? customRingtonePath,
    String ringtoneName = 'Default',
    int volume = 80,
    bool vibrate = true,
  }) async {
    final id = const Uuid().v4();
    final notifId = DateTime.now().millisecondsSinceEpoch % 100000;
    final days = repeatDays ?? List.filled(7, false);

    final alarm = AlarmModel(
      id: id,
      label: label,
      hour: hour,
      minute: minute,
      repeatDays: days,
      customRingtonePath: customRingtonePath,
      ringtoneName: ringtoneName,
      notificationId: notifId,
      volume: volume,
      vibrate: vibrate,
      isEnabled: true,
    );

    await _box.put(id, alarm);
    await _scheduleAlarmNotification(alarm);
    _refreshList();
  }

  Future<void> toggleAlarm(String alarmId) async {
    final alarm = _box.get(alarmId);
    if (alarm == null) return;
    alarm.isEnabled = !alarm.isEnabled;
    await alarm.save();

    if (alarm.isEnabled) {
      await _scheduleAlarmNotification(alarm);
    } else {
      await NotificationService.instance.cancelNotification(
        alarm.notificationId,
      );
    }
    _refreshList();
  }

  Future<void> deleteAlarm(String alarmId) async {
    final alarm = _box.get(alarmId);
    if (alarm != null) {
      await NotificationService.instance.cancelNotification(
        alarm.notificationId,
      );
    }
    await _box.delete(alarmId);
    _refreshList();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    await _box.put(alarm.id, alarm);
    if (alarm.isEnabled) {
      await _scheduleAlarmNotification(alarm);
    }
    _refreshList();
  }

  Future<void> previewRingtone(String? path) async {
    await _player.stop();
    if (path != null) {
      await _player.setFilePath(path);
    } else {
      // Play system default beep (placeholder)
      return;
    }
    await _player.play();
    Future.delayed(const Duration(seconds: 5), () => _player.stop());
  }

  Future<void> stopPreview() async {
    await _player.stop();
  }

  Future<void> _scheduleAlarmNotification(AlarmModel alarm) async {
    await NotificationService.instance.scheduleAlarm(
      id: alarm.notificationId,
      label: alarm.label,
      hour: alarm.hour,
      minute: alarm.minute,
      repeatDays: alarm.repeatDays,
      customSoundPath: alarm.customRingtonePath,
    );
  }

  void _refreshList() {
    _alarms =
        _box.values.toList()..sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
        );
    notifyListeners();
  }

  String getNextAlarmText() {
    final enabled = enabledAlarms;
    if (enabled.isEmpty) return 'No alarms set';
    final now = DateTime.now();
    AlarmModel? next;
    Duration? minDiff;
    for (final alarm in enabled) {
      var alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.hour,
        alarm.minute,
      );
      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }
      final diff = alarmTime.difference(now);
      if (minDiff == null || diff < minDiff) {
        minDiff = diff;
        next = alarm;
      }
    }
    if (next == null) return 'No alarms set';
    final h = minDiff!.inHours;
    final m = minDiff.inMinutes % 60;
    return 'Next: ${next.displayHour}:${next.minute.toString().padLeft(2, '0')} ${next.periodString} (in ${h}h ${m}m)';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
