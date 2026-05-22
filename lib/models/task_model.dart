import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? scheduledAt;

  @HiveField(6)
  String category; // 'work', 'personal', 'health', 'learning'

  @HiveField(7)
  int priority; // 1=low, 2=medium, 3=high

  @HiveField(8)
  bool notificationEnabled;

  @HiveField(9)
  int? notificationId;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  bool isRecurring;

  @HiveField(12)
  String? recurrenceRule; // 'daily', 'weekdays', 'weekly'

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.scheduledAt,
    this.category = 'personal',
    this.priority = 2,
    this.notificationEnabled = true,
    this.notificationId,
    this.completedAt,
    this.isRecurring = false,
    this.recurrenceRule,
  });

  TaskModel copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? scheduledAt,
    String? category,
    int? priority,
    bool? notificationEnabled,
    DateTime? completedAt,
    bool? isRecurring,
    String? recurrenceRule,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationId: notificationId,
      completedAt: completedAt ?? this.completedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    );
  }
}
