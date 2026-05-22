import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/pomodoro_session_model.dart';
import '../services/notification_service.dart';

enum PomodoroPhase { work, shortBreak, longBreak }

enum PomodoroState { idle, running, paused }

class PomodoroProvider extends ChangeNotifier {
  // ── Settings ──────────────────────────────────────────────
  int workDuration = 25; // minutes
  int shortBreakDuration = 5;
  int longBreakDuration = 15;
  int sessionsBeforeLongBreak = 4;

  // ── State ──────────────────────────────────────────────────
  PomodoroPhase _phase = PomodoroPhase.work;
  PomodoroState _state = PomodoroState.idle;
  int _secondsLeft = 25 * 60;
  int _completedSessions = 0;
  int _todaySessions = 0;
  String? _linkedTaskId;
  String? _linkedTaskTitle;
  Timer? _timer;

  PomodoroPhase get phase => _phase;
  PomodoroState get state => _state;
  int get secondsLeft => _secondsLeft;
  int get completedSessions => _completedSessions;
  int get todaySessions => _todaySessions;
  String? get linkedTaskId => _linkedTaskId;
  String? get linkedTaskTitle => _linkedTaskTitle;

  double get progress {
    final total = _phaseDuration * 60;
    return 1 - (_secondsLeft / total);
  }

  int get _phaseDuration {
    switch (_phase) {
      case PomodoroPhase.work:
        return workDuration;
      case PomodoroPhase.shortBreak:
        return shortBreakDuration;
      case PomodoroPhase.longBreak:
        return longBreakDuration;
    }
  }

  String get timeDisplay {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get phaseLabel {
    switch (_phase) {
      case PomodoroPhase.work:
        return 'Focus';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  PomodoroProvider() {
    _loadSettings();
    _loadTodayStats();
  }

  void _loadSettings() {
    final box = Hive.box('settings');
    workDuration = box.get('pomo_work', defaultValue: 25);
    shortBreakDuration = box.get('pomo_short', defaultValue: 5);
    longBreakDuration = box.get('pomo_long', defaultValue: 15);
    sessionsBeforeLongBreak = box.get('pomo_sessions', defaultValue: 4);
    _secondsLeft = workDuration * 60;
  }

  void saveSettings({
    required int work,
    required int shortBreak,
    required int longBreak,
    required int sessions,
  }) {
    workDuration = work;
    shortBreakDuration = shortBreak;
    longBreakDuration = longBreak;
    sessionsBeforeLongBreak = sessions;
    final box = Hive.box('settings');
    box.put('pomo_work', work);
    box.put('pomo_short', shortBreak);
    box.put('pomo_long', longBreak);
    box.put('pomo_sessions', sessions);
    if (_state == PomodoroState.idle) {
      _secondsLeft = workDuration * 60;
    }
    notifyListeners();
  }

  void _loadTodayStats() {
    final box = Hive.box<PomodoroSessionModel>('pomodoro_sessions');
    final today = DateTime.now();
    _todaySessions = box.values
        .where((s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day)
        .fold(0, (sum, s) => sum + s.completedPomodoros);
    notifyListeners();
  }

  void linkTask(String? taskId, String? taskTitle) {
    _linkedTaskId = taskId;
    _linkedTaskTitle = taskTitle;
    notifyListeners();
  }

  void start() {
    if (_state == PomodoroState.running) return;
    _state = PomodoroState.running;
    WakelockPlus.enable();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _state = PomodoroState.paused;
    WakelockPlus.disable();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _state = PomodoroState.idle;
    _phase = PomodoroPhase.work;
    _secondsLeft = workDuration * 60;
    WakelockPlus.disable();
    notifyListeners();
  }

  void skipPhase() {
    _timer?.cancel();
    _completePhase();
  }

  void _tick(Timer timer) {
    if (_secondsLeft > 0) {
      _secondsLeft--;
      notifyListeners();
    } else {
      _completePhase();
    }
  }

  void _completePhase() {
    _timer?.cancel();
    WakelockPlus.disable();

    if (_phase == PomodoroPhase.work) {
      _completedSessions++;
      _todaySessions++;
      _saveSession();
      NotificationService.instance.showPomodoroComplete(
        isBreak: true,
        sessionCount: _completedSessions,
      );

      if (_completedSessions % sessionsBeforeLongBreak == 0) {
        _phase = PomodoroPhase.longBreak;
        _secondsLeft = longBreakDuration * 60;
      } else {
        _phase = PomodoroPhase.shortBreak;
        _secondsLeft = shortBreakDuration * 60;
      }
    } else {
      NotificationService.instance.showPomodoroComplete(
        isBreak: false,
        sessionCount: _completedSessions,
      );
      _phase = PomodoroPhase.work;
      _secondsLeft = workDuration * 60;
    }

    _state = PomodoroState.idle;
    notifyListeners();
  }

  void _saveSession() {
    final box = Hive.box<PomodoroSessionModel>('pomodoro_sessions');
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    // Find existing session for today or create new
    final existing = box.values.where((s) =>
      s.date.year == today.year &&
      s.date.month == today.month &&
      s.date.day == today.day
    ).firstOrNull;

    if (existing != null) {
      existing.completedPomodoros++;
      existing.totalFocusMinutes += workDuration;
      if (_linkedTaskId != null) existing.taskId = _linkedTaskId;
      if (_linkedTaskTitle != null) existing.taskTitle = _linkedTaskTitle;
      existing.save();
    } else {
      box.put(
        todayKey,
        PomodoroSessionModel(
          id: const Uuid().v4(),
          date: today,
          completedPomodoros: 1,
          totalFocusMinutes: workDuration,
          taskId: _linkedTaskId,
          taskTitle: _linkedTaskTitle,
        ),
      );
    }
  }

  // Get last 7 days stats
  List<Map<String, dynamic>> getWeeklyStats() {
    final box = Hive.box<PomodoroSessionModel>('pomodoro_sessions');
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final session = box.values.where((s) =>
          s.date.year == day.year &&
          s.date.month == day.month &&
          s.date.day == day.day).firstOrNull;
      return {
        'day': day,
        'pomodoros': session?.completedPomodoros ?? 0,
        'minutes': session?.totalFocusMinutes ?? 0,
      };
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }
}
