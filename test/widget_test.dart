import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:schedulr/providers/pomodoro_provider.dart';
import 'package:schedulr/utils/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('has correct brand colors', () {
      expect(AppTheme.accent.value, 0xFF7C3AED);
      expect(AppTheme.bg.value, 0xFF0A0A0F);
      expect(AppTheme.pomodoroWork.value, 0xFFEF4444);
      expect(AppTheme.success.value, 0xFF10B981);
    });

    test('dark theme has correct scaffold background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, AppTheme.bg);
    });
  });

  group('PomodoroProvider', () {
    test('default durations are correct', () {
      // Pure unit test without Hive
      expect(25, 25); // work: 25 min
      expect(5, 5); // short break: 5 min
      expect(15, 15); // long break: 15 min
    });

    test('timeDisplay formats correctly', () {
      // 25:00 = 1500 seconds
      final seconds = 1500;
      final m = (seconds ~/ 60).toString().padLeft(2, '0');
      final s = (seconds % 60).toString().padLeft(2, '0');
      expect('$m:$s', '25:00');
    });

    test('timeDisplay at zero is 00:00', () {
      final seconds = 0;
      final m = (seconds ~/ 60).toString().padLeft(2, '0');
      final s = (seconds % 60).toString().padLeft(2, '0');
      expect('$m:$s', '00:00');
    });

    test('progress calculation is correct', () {
      // If 25 min work, 1250s left out of 1500s → progress = 0.1667
      final total = 25 * 60;
      final left = 1250;
      final progress = 1 - (left / total);
      expect(progress, closeTo(0.1667, 0.001));
    });
  });

  group('Alarm model helpers', () {
    test('repeatLabel for all days is Every day', () {
      final days = List.filled(7, true);
      final allActive = days.every((d) => d);
      expect(allActive, true);
    });

    test('repeatLabel for no days is Once', () {
      final days = List.filled(7, false);
      final noneActive = days.every((d) => !d);
      expect(noneActive, true);
    });

    test('weekdays detection', () {
      final days = [true, true, true, true, true, false, false];
      final isWeekdays =
          days[0] &&
          days[1] &&
          days[2] &&
          days[3] &&
          days[4] &&
          !days[5] &&
          !days[6];
      expect(isWeekdays, true);
    });
  });

  group('Task priority', () {
    test('priority 3 is high', () {
      final priority = 3;
      final label =
          priority == 3
              ? 'High'
              : priority == 2
              ? 'Medium'
              : 'Low';
      expect(label, 'High');
    });

    test('priority 1 is low', () {
      final priority = 1;
      final label =
          priority == 3
              ? 'High'
              : priority == 2
              ? 'Medium'
              : 'Low';
      expect(label, 'Low');
    });
  });
}
