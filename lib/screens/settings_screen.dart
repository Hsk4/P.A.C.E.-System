import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../utils/app_theme.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _box;
  String _name = 'Hammad';

  @override
  void initState() {
    super.initState();
    _box = Hive.box('settings');
    _name = _box.get('user_name', defaultValue: 'Hammad');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile
          _buildGroup(
            title: 'PROFILE',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'Your name',
                trailing: Text(
                  _name,
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.accent),
                ),
                onTap: () => _editName(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroup(
            title: 'NOTIFICATIONS',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notification preferences',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroup(
            title: 'DATA',
            children: [
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                label: 'Clear all data',
                iconColor: AppTheme.danger,
                labelColor: AppTheme.danger,
                onTap: () => _confirmClear(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Schedulr v1.0.0\nBuilt with Flutter ❤️',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 1.2,
          ),
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

  void _editName(BuildContext context) {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Text(
              'Your name',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
            ),
            content: TextField(
              controller: ctrl,
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Enter your name'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    _box.put('user_name', ctrl.text.trim());
                    setState(() => _name = ctrl.text.trim());
                  }
                  Navigator.pop(ctx);
                },
                child: Text(
                  'Save',
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.accent),
                ),
              ),
            ],
          ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Text(
              'Clear all data?',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
            ),
            content: Text(
              'This will permanently delete all tasks, alarms, and Pomodoro history.',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Hive.box('tasks').clear();
                  Hive.box('alarms').clear();
                  Hive.box('pomodoro_sessions').clear();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All data cleared',
                        style: GoogleFonts.spaceGrotesk(),
                      ),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                },
                child: Text(
                  'Clear',
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.danger),
                ),
              ),
            ],
          ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppTheme.textSecondary, size: 20),
      title: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: labelColor ?? AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 18),
    );
  }
}
