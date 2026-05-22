import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'models/task_model.dart';
import 'models/alarm_model.dart';
import 'models/pomodoro_session_model.dart';
import 'providers/task_provider.dart';
import 'providers/alarm_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/progress_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init Hive local DB
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(AlarmModelAdapter());
  Hive.registerAdapter(PomodoroSessionModelAdapter());
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<AlarmModel>('alarms');
  await Hive.openBox<PomodoroSessionModel>('pomodoro_sessions');
  await Hive.openBox('settings');

  // Init timezones
  tz.initializeTimeZones();

  // Init notifications
  await NotificationService.instance.initialize();

  runApp(const SchedulrApp());
}

class SchedulrApp extends StatelessWidget {
  const SchedulrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        title: 'Schedulr',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
