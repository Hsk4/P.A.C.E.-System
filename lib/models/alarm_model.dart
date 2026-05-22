import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 1)
class AlarmModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  int hour;

  @HiveField(3)
  int minute;

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  List<bool> repeatDays; // [Mon,Tue,Wed,Thu,Fri,Sat,Sun]

  @HiveField(6)
  String? customRingtonePath;

  @HiveField(7)
  String ringtoneName;

  @HiveField(8)
  int notificationId;

  @HiveField(9)
  int volume; // 0-100

  @HiveField(10)
  bool vibrate;

  @HiveField(11)
  DateTime? lastTriggered;

  AlarmModel({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    required this.repeatDays,
    this.customRingtonePath,
    this.ringtoneName = 'Default',
    required this.notificationId,
    this.volume = 80,
    this.vibrate = true,
    this.lastTriggered,
  });

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get periodString => hour < 12 ? 'AM' : 'PM';

  String get displayHour {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return h.toString().padLeft(2, '0');
  }

  String get repeatLabel {
    if (repeatDays.every((d) => !d)) return 'Once';
    if (repeatDays.every((d) => d)) return 'Every day';
    if (repeatDays[0] && repeatDays[1] && repeatDays[2] && repeatDays[3] && repeatDays[4] &&
        !repeatDays[5] && !repeatDays[6]) return 'Weekdays';
    if (!repeatDays[0] && !repeatDays[1] && !repeatDays[2] && !repeatDays[3] && !repeatDays[4] &&
        repeatDays[5] && repeatDays[6]) return 'Weekends';
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final active = <String>[];
    for (int i = 0; i < 7; i++) {
      if (repeatDays[i]) active.add(dayNames[i]);
    }
    return active.join(', ');
  }
}
