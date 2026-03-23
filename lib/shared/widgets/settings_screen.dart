import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/core/themes/theme_provider.dart';
import 'package:notezen/features/tasks/presentation/tasks_provider.dart';
import 'package:notezen/features/notes/presentation/notes_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // ─── Theme Label ─────────────────────────────────
  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      default:
        return 'System Default';
    }
  }

  // ─── Theme Icon ──────────────────────────────────
  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  // ─── Theme Picker Dialog ─────────────────────────
  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode currentTheme) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final bgColor = Theme.of(context).colorScheme.surface;

    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusDialog)),
        title: Text(
          'Choose Theme',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        children: [
          Divider(height: 1),
          _themeOption(
            context: context,
            ref: ref,
            icon: Icons.brightness_auto,
            label: 'System Default',
            mode: ThemeMode.system,
            currentTheme: currentTheme,
            textColor: textColor,
          ),
          _themeOption(
            context: context,
            ref: ref,
            icon: Icons.light_mode,
            label: 'Light',
            mode: ThemeMode.light,
            currentTheme: currentTheme,
            textColor: textColor,
          ),
          _themeOption(
            context: context,
            ref: ref,
            icon: Icons.dark_mode,
            label: 'Dark',
            mode: ThemeMode.dark,
            currentTheme: currentTheme,
            textColor: textColor,
          ),
          SizedBox(height: AppConstants.spaceXS),
        ],
      ),
    );
  }

  // ─── Theme Option Widget ─────────────────────────
  Widget _themeOption({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required ThemeMode currentTheme,
    required Color textColor,
  }) {
    final isSelected = currentTheme == mode;
    return SimpleDialogOption(
      onPressed: () {
        ref.read(themeProvider.notifier).setTheme(mode);
        Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spaceXS),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.spaceXS),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: isSelected ? AppTheme.primary : textColor.withValues(alpha: 0.6)),
            ),
            SizedBox(width: AppConstants.spaceMD),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: textColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
              ),
            ),
            if (isSelected) Icon(Icons.check_rounded, color: AppTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Settings Tile ───────────────────────────────
  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppConstants.spaceMD),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              padding: EdgeInsets.all(AppConstants.spaceSM),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: AppConstants.spaceMD),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            // Trailing
            trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Stats
    final totalNotes = ref.watch(notesProvider).length;
    final totalTasks = ref.watch(tasksProvider).length;
    final completedTasks = ref.watch(tasksProvider).where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats Section ─────────────────────
            Text(
              'OVERVIEW',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
            ),
            SizedBox(height: AppConstants.spaceSM),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    context: context,
                    value: totalNotes.toString(),
                    label: 'Notes',
                    icon: Icons.note_outlined,
                    color: AppTheme.primary,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: AppConstants.spaceSM),
                Expanded(
                  child: _statCard(
                    context: context,
                    value: pendingTasks.toString(),
                    label: 'Pending',
                    icon: Icons.pending_outlined,
                    color: AppTheme.warning,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: AppConstants.spaceSM),
                Expanded(
                  child: _statCard(
                    context: context,
                    value: completedTasks.toString(),
                    label: 'Done',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.success,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Appearance Section ────────────────
            Text(
              'APPEARANCE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
            ),
            SizedBox(height: AppConstants.spaceSM),

            _settingsTile(
              context: context,
              icon: _themeIcon(currentTheme),
              iconColor: AppTheme.primary,
              title: 'Theme',
              subtitle: _themeLabel(currentTheme),
              onTap: () => _showThemePicker(context, ref, currentTheme),
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── About Section ─────────────────────
            Text(
              'ABOUT',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
            ),
            SizedBox(height: AppConstants.spaceSM),

            _settingsTile(
              context: context,
              icon: Icons.info_outline_rounded,
              iconColor: AppTheme.accent,
              title: AppConstants.appName,
              subtitle: AppConstants.appVersion,
              onTap: () {},
              trailing: Text(AppConstants.appVersion, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),

            SizedBox(height: AppConstants.spaceXXL),

            // ── Version Footer ────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(AppConstants.appVersion, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

            SizedBox(height: AppConstants.spaceLG),
          ],
        ),
      ),
    );
  }

  // ─── Stat Card ───────────────────────────────────
  Widget _statCard({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(height: AppConstants.spaceXS),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
