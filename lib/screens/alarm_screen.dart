import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../utils/app_theme.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                '⏰ Alarms',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer<AlarmProvider>(
                builder:
                    (_, p, __) => Text(
                      p.getNextAlarmText(),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<AlarmProvider>(
                builder: (context, provider, _) {
                  if (provider.alarms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.alarm_off_outlined,
                            size: 48,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No alarms set',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: provider.alarms.length,
                    itemBuilder:
                        (_, i) => _AlarmCard(alarm: provider.alarms[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAlarm(context),
        backgroundColor: AppTheme.info,
        icon: const Icon(Icons.add_alarm, color: Colors.white),
        label: Text(
          'Add Alarm',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAddAlarm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _AddAlarmSheet(),
    );
  }
}

class _AlarmCard extends StatelessWidget {
  final AlarmModel alarm;

  const _AlarmCard({required this.alarm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              alarm.isEnabled
                  ? AppTheme.info.withOpacity(0.3)
                  : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      alarm.displayHour,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color:
                            alarm.isEnabled
                                ? AppTheme.textPrimary
                                : AppTheme.textMuted,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ':${alarm.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color:
                                alarm.isEnabled
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted,
                          ),
                        ),
                        Text(
                          alarm.periodString,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                alarm.isEnabled
                                    ? AppTheme.info
                                    : AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alarm.label,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        alarm.isEnabled
                            ? AppTheme.textSecondary
                            : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      alarm.repeatLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    if (alarm.customRingtonePath != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.music_note,
                        size: 12,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alarm.ringtoneName,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: alarm.isEnabled,
                onChanged:
                    (_) => context.read<AlarmProvider>().toggleAlarm(alarm.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppTheme.textMuted,
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Text(
              'Delete alarm?',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Text(
              'This alarm will be permanently removed.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AlarmProvider>().deleteAlarm(alarm.id);
                  Navigator.pop(ctx);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.danger),
                ),
              ),
            ],
          ),
    );
  }
}

class _AddAlarmSheet extends StatefulWidget {
  const _AddAlarmSheet();

  @override
  State<_AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<_AddAlarmSheet> {
  final _labelController = TextEditingController(text: 'Alarm');
  int _hour = TimeOfDay.now().hour;
  int _minute = TimeOfDay.now().minute;
  final List<bool> _repeatDays = List.filled(7, false);
  String? _customRingtonePath;
  String _ringtoneName = 'Default';
  int _volume = 80;
  bool _vibrate = true;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final displayHour = _hour > 12 ? _hour - 12 : (_hour == 0 ? 12 : _hour);
    final period = _hour < 12 ? 'AM' : 'PM';

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
              'New Alarm',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Time picker
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.info.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${displayHour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.info,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 16),
            Text(
              'Repeat',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _repeatDays[i] = !_repeatDays[i];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _repeatDays[i]
                              ? AppTheme.info
                              : AppTheme.surfaceElevated,
                      border: Border.all(
                        color: _repeatDays[i] ? AppTheme.info : AppTheme.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _dayLabels[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              _repeatDays[i]
                                  ? Colors.white
                                  : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickRingtone,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.music_note_outlined,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _ringtoneName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
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
                  'Vibrate',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Switch(
                  value: _vibrate,
                  onChanged: (v) => setState(() => _vibrate = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Volume',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _volume.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    activeColor: AppTheme.info,
                    label: '$_volume%',
                    onChanged: (v) => setState(() => _volume = v.toInt()),
                  ),
                ),
                Text(
                  '$_volume%',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.info),
                child: const Text('Set Alarm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      builder:
          (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: AppTheme.info),
            ),
            child: child!,
          ),
    );
    if (time != null) {
      setState(() {
        _hour = time.hour;
        _minute = time.minute;
      });
    }
  }

  Future<void> _pickRingtone() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _customRingtonePath = result.files.single.path;
        _ringtoneName = result.files.single.name;
      });
    }
  }

  void _submit() {
    context.read<AlarmProvider>().addAlarm(
      label:
          _labelController.text.trim().isEmpty
              ? 'Alarm'
              : _labelController.text.trim(),
      hour: _hour,
      minute: _minute,
      repeatDays: _repeatDays,
      customRingtonePath: _customRingtonePath,
      ringtoneName: _ringtoneName,
      volume: _volume,
      vibrate: _vibrate,
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
}
