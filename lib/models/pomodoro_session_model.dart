import 'package:hive/hive.dart';

part 'pomodoro_session_model.g.dart';

@HiveType(typeId: 2)
class PomodoroSessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int completedPomodoros;

  @HiveField(3)
  int totalFocusMinutes;

  @HiveField(4)
  String? taskId;

  @HiveField(5)
  String? taskTitle;

  PomodoroSessionModel({
    required this.id,
    required this.date,
    this.completedPomodoros = 0,
    this.totalFocusMinutes = 0,
    this.taskId,
    this.taskTitle,
  });
}
