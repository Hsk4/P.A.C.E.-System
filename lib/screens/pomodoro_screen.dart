import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pomodoro_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _PhaseSelector(),
                    const SizedBox(height: 32),
                    _TimerRing(),
                    const SizedBox(height: 32),
                    _Controls(),
                    const SizedBox(height: 24),
                    _LinkedTask(),
                    const SizedBox(height: 24),
                    _SessionCount(),
                    const SizedBox(height: 24),
                    _SettingsCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Text(
            '🍅 Focus',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomo, _) {
        return Row(
          children: [
            _PhasePill(
              label: 'Focus',
              phase: PomodoroPhase.work,
              currentPhase: pomo.phase,
              color: AppTheme.pomodoroWork,
            ),
            const SizedBox(width: 8),
            _PhasePill(
              label: 'Short Break',
              phase: PomodoroPhase.shortBreak,
              currentPhase: pomo.phase,
              color: AppTheme.pomodoroBreak,
            ),
            const SizedBox(width: 8),
            _PhasePill(
              label: 'Long Break',
              phase: PomodoroPhase.longBreak,
              currentPhase: pomo.phase,
              color: AppTheme.pomodoroLong,
            ),
          ],
        );
      },
    );
  }
}

class _PhasePill extends StatelessWidget {
  final String label;
  final PomodoroPhase phase;
  final PomodoroPhase currentPhase;
  final Color color;

  const _PhasePill({
    required this.label,
    required this.phase,
    required this.currentPhase,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = phase == currentPhase;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : AppTheme.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? color : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomo, _) {
        final color = _phaseColor(pomo.phase);
        return SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(260, 260),
                painter: _RingPainter(
                  progress: pomo.progress,
                  color: color,
                  state: pomo.state,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pomo.timeDisplay,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    pomo.phaseLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _phaseColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return AppTheme.pomodoroWork;
      case PomodoroPhase.shortBreak:
        return AppTheme.pomodoroBreak;
      case PomodoroPhase.longBreak:
        return AppTheme.pomodoroLong;
    }
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final PomodoroState state;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 8.0;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppTheme.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress ring
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // Glow effect when running
    if (state == PomodoroState.running) {
      final glowPaint =
          Paint()
            ..color = color.withOpacity(0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(center, radius - 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.state != state;
}

class _Controls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomo, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset
            _ControlButton(
              icon: Icons.replay,
              onTap: pomo.reset,
              color: AppTheme.textSecondary,
              size: 48,
            ),
            const SizedBox(width: 20),
            // Play/Pause
            GestureDetector(
              onTap: () {
                if (pomo.state == PomodoroState.running) {
                  pomo.pause();
                } else {
                  pomo.start();
                }
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.pomodoroWork,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.pomodoroWork.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  pomo.state == PomodoroState.running
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Skip
            _ControlButton(
              icon: Icons.skip_next,
              onTap: pomo.skipPhase,
              color: AppTheme.textSecondary,
              size: 48,
            ),
          ],
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _LinkedTask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PomodoroProvider, TaskProvider>(
      builder: (context, pomo, tasks, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.link, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pomo.linkedTaskTitle ?? 'No task linked',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        pomo.linkedTaskTitle != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showTaskPicker(context, pomo, tasks),
                child: Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTaskPicker(
    BuildContext context,
    PomodoroProvider pomo,
    TaskProvider tasks,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final pending = tasks.pendingTasks;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Link a Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.clear, color: AppTheme.textSecondary),
                title: Text(
                  'No task',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                onTap: () {
                  pomo.linkTask(null, null);
                  Navigator.pop(ctx);
                },
              ),
              ...pending.map(
                (t) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.accent,
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  onTap: () {
                    pomo.linkTask(t.id, t.title);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionCount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomo, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pomo.sessionsBeforeLongBreak,
            (i) => Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    i < (pomo.completedSessions % pomo.sessionsBeforeLongBreak)
                        ? AppTheme.pomodoroWork
                        : AppTheme.border,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomo, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Timer Settings',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showSettings(context, pomo),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SettingChip(label: 'Focus', value: '${pomo.workDuration}m'),
                  const SizedBox(width: 8),
                  _SettingChip(
                    label: 'Short',
                    value: '${pomo.shortBreakDuration}m',
                  ),
                  const SizedBox(width: 8),
                  _SettingChip(
                    label: 'Long',
                    value: '${pomo.longBreakDuration}m',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext context, PomodoroProvider pomo) {
    int work = pomo.workDuration;
    int shortB = pomo.shortBreakDuration;
    int longB = pomo.longBreakDuration;
    int sessions = pomo.sessionsBeforeLongBreak;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pomodoro Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _DurationRow(
                        label: 'Focus Duration',
                        value: work,
                        onChanged: (v) => setState(() => work = v),
                      ),
                      _DurationRow(
                        label: 'Short Break',
                        value: shortB,
                        onChanged: (v) => setState(() => shortB = v),
                      ),
                      _DurationRow(
                        label: 'Long Break',
                        value: longB,
                        onChanged: (v) => setState(() => longB = v),
                      ),
                      _DurationRow(
                        label: 'Sessions before long break',
                        value: sessions,
                        onChanged: (v) => setState(() => sessions = v),
                        min: 1,
                        max: 8,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            pomo.saveSettings(
                              work: work,
                              shortBreak: shortB,
                              longBreak: longB,
                              sessions: sessions,
                            );
                            Navigator.pop(ctx);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

class _DurationRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const _DurationRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                color: AppTheme.textSecondary,
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: AppTheme.accent,
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingChip extends StatelessWidget {
  final String label;
  final String value;

  const _SettingChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
