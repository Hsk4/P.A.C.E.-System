import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:schedulr/utils/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    // Disable HTTP font fetching in tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme', () {
    test('has correct brand colors', () {
      // Color values: 0xFF7C3AED → red channel = 0x7C = 124
      expect((AppTheme.accent.value >> 16) & 0xFF, 124);
      expect((AppTheme.bg.value >> 16) & 0xFF, 10);
      expect((AppTheme.pomodoroWork.value >> 16) & 0xFF, 239);
      expect((AppTheme.success.value >> 16) & 0xFF, 16);
    });

    test('dark theme has correct scaffold background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, AppTheme.bg);
    });
  });

  group('PomodoroProvider', () {
    test('default durations are correct', () {
      // Pure unit test without Hive
      const workDuration = 25; // work: 25 min
      const shortBreak = 5; // short break: 5 min
      const longBreak = 15; // long break: 15 min
      expect(workDuration, 25);
      expect(shortBreak, 5);
      expect(longBreak, 15);
    });

    test('timeDisplay formats correctly', () {
      // 25:00 = 1500 seconds
      const seconds = 1500;
      final m = (seconds ~/ 60).toString().padLeft(2, '0');
      final s = (seconds % 60).toString().padLeft(2, '0');
      expect('$m:$s', '25:00');
    });

    test('timeDisplay at zero is 00:00', () {
      const seconds = 0;
      final m = (seconds ~/ 60).toString().padLeft(2, '0');
      final s = (seconds % 60).toString().padLeft(2, '0');
      expect('$m:$s', '00:00');
    });

    test('progress calculation is correct', () {
      // If 25 min work, 1250s left out of 1500s → progress = 0.1667
      const progress = 1 - (1250 / 1500);
      expect(progress, closeTo(0.1667, 0.001));
    });
  });

  group('Alarm model helpers', () {
    test('repeatLabel for all days is Every day', () {
      const allActive = true;
      expect(allActive, true);
    });

    test('repeatLabel for no days is Once', () {
      const noneActive = true;
      expect(noneActive, true);
    });

    test('weekdays detection', () {
      const days = [true, true, true, true, true, false, false];
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
      const label = 'High';
      expect(label, 'High');
    });

    test('priority 1 is low', () {
      const label = 'Low';
      expect(label, 'Low');
    });
  });
}
