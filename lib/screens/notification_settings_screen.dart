import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../services/notification_service.dart';
import '../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late Box _settings;
  bool _dailyBriefing = true;
  TimeOfDay _briefingTime = const TimeOfDay(hour: 8, minute: 0);
  bool _taskReminders = true;
  bool _pomodoroAlerts = true;
  bool _streakReminder = true;
  TimeOfDay _streakTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _settings = Hive.box('settings');
    _dailyBriefing = _settings.get('notif_daily_briefing', defaultValue: true);
    _taskReminders = _settings.get('notif_task_reminders', defaultValue: true);
    _pomodoroAlerts = _settings.get('notif_pomodoro', defaultValue: true);
    _streakReminder = _settings.get('notif_streak', defaultValue: true);
    final bh = _settings.get('briefing_hour', defaultValue: 8);
    final bm = _settings.get('briefing_minute', defaultValue: 0);
    final sh = _settings.get('streak_hour', defaultValue: 21);
    final sm = _settings.get('streak_minute', defaultValue: 0);
    _briefingTime = TimeOfDay(hour: bh, minute: bm);
    _streakTime = TimeOfDay(hour: sh, minute: sm);
  }

  void _save() {
    _settings.put('notif_daily_briefing', _dailyBriefing);
    _settings.put('notif_task_reminders', _taskReminders);
    _settings.put('notif_pomodoro', _pomodoroAlerts);
    _settings.put('notif_streak', _streakReminder);
    _settings.put('briefing_hour', _briefingTime.hour);
    _settings.put('briefing_minute', _briefingTime.minute);
    _settings.put('streak_hour', _streakTime.hour);
    _settings.put('streak_minute', _streakTime.minute);

    if (_dailyBriefing) {
      NotificationService.instance.scheduleDailyBriefing(
        hour: _briefingTime.hour,
        minute: _briefingTime.minute,
        body: "Good morning! Check your tasks for today.",
      );
    } else {
      NotificationService.instance.cancelNotification(9999);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildGroup(
            title: 'Daily Briefing',
            children: [
              _ToggleRow(
                label: 'Morning summary',
                subtitle: 'Get a daily overview of your tasks',
                value: _dailyBriefing,
                onChanged: (v) => setState(() {
                  _dailyBriefing = v;
                  _save();
                }),
              ),
              if (_dailyBriefing)
                _TimeRow(
                  label: 'Briefing time',
                  time: _briefingTime,
                  onTap: () => _pickTime(
                    _briefingTime,
                    (t) => setState(() {
                      _briefingTime = t;
                      _save();
                    }),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroup(
            title: 'Task Reminders',
            children: [
              _ToggleRow(
                label: 'Task notifications',
                subtitle: 'Get reminded when tasks are due',
                value: _taskReminders,
                onChanged: (v) => setState(() {
                  _taskReminders = v;
                  _save();
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroup(
            title: 'Pomodoro',
            children: [
              _ToggleRow(
                label: 'Session alerts',
                subtitle: 'Notify when focus/break sessions end',
                value: _pomodoroAlerts,
                onChanged: (v) => setState(() {
                  _pomodoroAlerts = v;
                  _save();
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroup(
            title: 'Streak',
            children: [
              _ToggleRow(
                label: 'Daily streak reminder',
                subtitle: "Don't break your streak!",
                value: _streakReminder,
                onChanged: (v) => setState(() {
                  _streakReminder = v;
                  _save();
                }),
              ),
              if (_streakReminder)
                _TimeRow(
                  label: 'Reminder time',
                  time: _streakTime,
                  onTap: () => _pickTime(
                    _streakTime,
                    (t) => setState(() {
                      _streakTime = t;
                      _save();
                    }),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Future<void> _pickTime(TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) async {
    final t = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
        ),
        child: child!,
      ),
    );
    if (t != null) onPicked(t);
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                Text(subtitle,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeRow({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour < 12 ? 'AM' : 'PM';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13, color: AppTheme.textSecondary)),
            Text(
              '${h.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent),
            ),
          ],
        ),
      ),
    );
  }
}
