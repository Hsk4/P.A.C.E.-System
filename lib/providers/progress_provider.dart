import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/task_model.dart';
import '../models/pomodoro_session_model.dart';

class ProgressProvider extends ChangeNotifier {
  int _currentStreak = 0;
  int _longestStreak = 0;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  ProgressProvider() {
    _calculateStreaks();
  }

  void refresh() {
    _calculateStreaks();
    notifyListeners();
  }

  void _calculateStreaks() {
    final taskBox = Hive.box<TaskModel>('tasks');
    int streak = 0;
    int longest = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final dayTasks =
          taskBox.values.where((t) {
            if (t.scheduledAt == null) return false;
            final s = t.scheduledAt!;
            return s.year == day.year &&
                s.month == day.month &&
                s.day == day.day;
          }).toList();

      if (dayTasks.isEmpty) {
        if (i == 0) continue; // today might not have tasks yet
        break;
      }

      final allDone = dayTasks.every((t) => t.isCompleted);
      if (allDone) {
        streak++;
        if (streak > longest) longest = streak;
      } else {
        if (i > 0) break;
      }
    }

    _currentStreak = streak;
    _longestStreak = Hive.box(
      'settings',
    ).get('longest_streak', defaultValue: 0);
    if (streak > _longestStreak) {
      _longestStreak = streak;
      Hive.box('settings').put('longest_streak', streak);
    }
  }

  Map<String, dynamic> getWeeklySummary() {
    final taskBox = Hive.box<TaskModel>('tasks');
    final pomBox = Hive.box<PomodoroSessionModel>('pomodoro_sessions');
    final now = DateTime.now();
    int totalTasks = 0;
    int completedTasks = 0;
    int totalPomodoros = 0;
    int totalFocusMinutes = 0;

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dayTasks = taskBox.values.where((t) {
        if (t.scheduledAt == null) return false;
        final s = t.scheduledAt!;
        return s.year == day.year && s.month == day.month && s.day == day.day;
      });
      totalTasks += dayTasks.length;
      completedTasks += dayTasks.where((t) => t.isCompleted).length;

      final session =
          pomBox.values
              .where(
                (s) =>
                    s.date.year == day.year &&
                    s.date.month == day.month &&
                    s.date.day == day.day,
              )
              .firstOrNull;
      if (session != null) {
        totalPomodoros += session.completedPomodoros;
        totalFocusMinutes += session.totalFocusMinutes;
      }
    }

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'completionRate': totalTasks > 0 ? completedTasks / totalTasks : 0.0,
      'totalPomodoros': totalPomodoros,
      'totalFocusHours': (totalFocusMinutes / 60).toStringAsFixed(1),
    };
  }

  List<Map<String, dynamic>> getDailyTaskCompletion() {
    final taskBox = Hive.box<TaskModel>('tasks');
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      final dayTasks =
          taskBox.values.where((t) {
            if (t.scheduledAt == null) return false;
            final s = t.scheduledAt!;
            return s.year == day.year &&
                s.month == day.month &&
                s.day == day.day;
          }).toList();
      final completed = dayTasks.where((t) => t.isCompleted).length;
      return {
        'day': day,
        'total': dayTasks.length,
        'completed': completed,
        'rate': dayTasks.isEmpty ? 0.0 : completed / dayTasks.length,
      };
    });
  }
}
