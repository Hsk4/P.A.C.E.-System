import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  late Box<TaskModel> _box;
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
        if (t.scheduledAt == null) return false;
        final s = t.scheduledAt!;
        return s.year == now.year && s.month == now.month && s.day == now.day;
      }).toList()
      ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
  }

  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get completedToday {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      final c = t.completedAt!;
      return c.year == now.year && c.month == now.month && c.day == now.day;
    }).toList();
  }

  double get todayCompletionRate {
    final today = todayTasks;
    if (today.isEmpty) return 0;
    return today.where((t) => t.isCompleted).length / today.length;
  }

  TaskProvider() {
    _box = Hive.box<TaskModel>('tasks');
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? scheduledAt,
    String category = 'personal',
    int priority = 2,
    bool notificationEnabled = true,
    bool isRecurring = false,
    String? recurrenceRule,
  }) async {
    final id = const Uuid().v4();
    final notifId = DateTime.now().millisecondsSinceEpoch % 100000;

    final task = TaskModel(
      id: id,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
      category: category,
      priority: priority,
      notificationEnabled: notificationEnabled,
      notificationId: notifId,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
    );

    await _box.put(id, task);
    _tasks = _box.values.toList();

    if (notificationEnabled && scheduledAt != null) {
      await NotificationService.instance.scheduleTaskReminder(
        id: notifId,
        title: title,
        body: description ?? 'Time to work on this task!',
        scheduledAt: scheduledAt,
      );
    }

    notifyListeners();
  }

  Future<void> toggleComplete(String taskId) async {
    final task = _box.get(taskId);
    if (task == null) return;
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await task.save();
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    final task = _box.get(taskId);
    if (task != null && task.notificationId != null) {
      await NotificationService.instance.cancelNotification(
        task.notificationId!,
      );
    }
    await _box.delete(taskId);
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    await _box.put(updatedTask.id, updatedTask);
    _tasks = _box.values.toList();
    notifyListeners();
  }

  List<TaskModel> getTasksByCategory(String category) =>
      _tasks.where((t) => t.category == category).toList();

  Map<String, int> getCategoryStats() {
    final categories = ['work', 'personal', 'health', 'learning'];
    return {
      for (var c in categories) c: _tasks.where((t) => t.category == c).length,
    };
  }
}
