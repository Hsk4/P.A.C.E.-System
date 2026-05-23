import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final bool showDate;

  const TaskTile({super.key, required this.task, this.showDate = false});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.danger),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<TaskProvider>().deleteTask(task.id),
      child: GestureDetector(
        onLongPress: () => _showOptions(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  task.isCompleted
                      ? AppTheme.border
                      : _priorityColor(task.priority).withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap:
                    () => context.read<TaskProvider>().toggleComplete(task.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        task.isCompleted
                            ? AppTheme.success
                            : Colors.transparent,
                    border: Border.all(
                      color:
                          task.isCompleted ? AppTheme.success : AppTheme.border,
                      width: 2,
                    ),
                  ),
                  child:
                      task.isCompleted
                          ? const Icon(
                            Icons.check,
                            size: 13,
                            color: Colors.white,
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            task.isCompleted
                                ? AppTheme.textMuted
                                : AppTheme.textPrimary,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        decorationColor: AppTheme.textMuted,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                    if (showDate && task.scheduledAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            size: 11,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            DateFormat(
                              'MMM d, h:mm a',
                            ).format(task.scheduledAt!),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right side — category + priority
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _CategoryBadge(category: task.category),
                  const SizedBox(height: 4),
                  _PriorityDot(priority: task.priority),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 3:
        return AppTheme.danger;
      case 2:
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Text(
              'Delete task?',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
            ),
            content: Text(
              'This cannot be undone.',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Delete',
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.danger),
                ),
              ),
            ],
          ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    task.isCompleted
                        ? Icons.radio_button_unchecked
                        : Icons.check_circle_outline,
                    color: AppTheme.success,
                  ),
                  title: Text(
                    task.isCompleted ? 'Mark as pending' : 'Mark as complete',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  onTap: () {
                    context.read<TaskProvider>().toggleComplete(task.id);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.danger,
                  ),
                  title: Text(
                    'Delete task',
                    style: GoogleFonts.spaceGrotesk(color: AppTheme.danger),
                  ),
                  onTap: () {
                    context.read<TaskProvider>().deleteTask(task.id);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final (emoji, color) = switch (category) {
      'work' => ('💼', AppTheme.info),
      'health' => ('💪', AppTheme.success),
      'learning' => ('📚', AppTheme.warning),
      _ => ('🧍', AppTheme.accent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$emoji $category',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final int priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      3 => ('High', AppTheme.danger),
      2 => ('Med', AppTheme.warning),
      _ => ('Low', AppTheme.success),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
