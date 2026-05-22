import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'all'; // all, pending, completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTask(context),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Task',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Text(
        '✅ Tasks',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            value: 'all',
            current: _filter,
            onTap: (v) => setState(() => _filter = v),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending',
            value: 'pending',
            current: _filter,
            onTap: (v) => setState(() => _filter = v),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Done',
            value: 'completed',
            current: _filter,
            onTap: (v) => setState(() => _filter = v),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        List<TaskModel> tasks;
        switch (_filter) {
          case 'pending':
            tasks = provider.pendingTasks;
            break;
          case 'completed':
            tasks = provider.tasks.where((t) => t.isCompleted).toList();
            break;
          default:
            tasks = provider.tasks;
        }

        // Sort by priority desc, then by scheduled date
        tasks.sort((a, b) {
          if (a.priority != b.priority) return b.priority.compareTo(a.priority);
          if (a.scheduledAt != null && b.scheduledAt != null) {
            return a.scheduledAt!.compareTo(b.scheduledAt!);
          }
          return 0;
        });

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.task_alt, size: 48, color: AppTheme.textMuted),
                const SizedBox(height: 12),
                Text(
                  'No tasks here',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          itemCount: tasks.length,
          itemBuilder: (_, i) => TaskTile(task: tasks[i], showDate: true),
        );
      },
    );
  }

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _AddTaskSheet(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.accent : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'personal';
  int _priority = 2;
  DateTime? _scheduledAt;
  bool _notificationEnabled = true;
  bool _isRecurring = false;
  String? _recurrenceRule;

  final _categories = [
    ('work', '💼', AppTheme.info),
    ('personal', '🧍', AppTheme.accent),
    ('health', '💪', AppTheme.success),
    ('learning', '📚', AppTheme.warning),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Task',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Task title *',
                hintText: 'What do you need to do?',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Category',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children:
                  _categories.map((cat) {
                    final isActive = _category == cat.$1;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _category = cat.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? cat.$3.withOpacity(0.2)
                                    : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive ? cat.$3 : AppTheme.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                cat.$2,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                cat.$1,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  color: isActive ? cat.$3 : AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Priority',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _PriorityBtn(
                  label: 'Low',
                  value: 1,
                  current: _priority,
                  color: AppTheme.success,
                  onTap: (v) => setState(() => _priority = v),
                ),
                const SizedBox(width: 8),
                _PriorityBtn(
                  label: 'Medium',
                  value: 2,
                  current: _priority,
                  color: AppTheme.warning,
                  onTap: (v) => setState(() => _priority = v),
                ),
                const SizedBox(width: 8),
                _PriorityBtn(
                  label: 'High',
                  value: 3,
                  current: _priority,
                  color: AppTheme.danger,
                  onTap: (v) => setState(() => _priority = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _scheduledAt != null
                          ? DateFormat(
                            'MMM d, yyyy  h:mm a',
                          ).format(_scheduledAt!)
                          : 'Set date & time',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color:
                            _scheduledAt != null
                                ? AppTheme.textPrimary
                                : AppTheme.textMuted,
                      ),
                    ),
                    const Spacer(),
                    if (_scheduledAt != null)
                      GestureDetector(
                        onTap: () => setState(() => _scheduledAt = null),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable notification',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Switch(
                  value: _notificationEnabled,
                  onChanged: (v) => setState(() => _notificationEnabled = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder:
          (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
            ),
            child: child!,
          ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder:
          (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
            ),
            child: child!,
          ),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    context.read<TaskProvider>().addTask(
      title: _titleController.text.trim(),
      description:
          _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
      scheduledAt: _scheduledAt,
      category: _category,
      priority: _priority,
      notificationEnabled: _notificationEnabled,
      isRecurring: _isRecurring,
      recurrenceRule: _recurrenceRule,
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

class _PriorityBtn extends StatelessWidget {
  final String label;
  final int value;
  final int current;
  final Color color;
  final ValueChanged<int> onTap;

  const _PriorityBtn({
    required this.label,
    required this.value,
    required this.current,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.2) : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? color : AppTheme.border),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? color : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
