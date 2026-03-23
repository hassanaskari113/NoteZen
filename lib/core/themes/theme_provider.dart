import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notezen/core/constants/app_constants.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box(AppConstants.hiveBoxName);
    final savedTheme = box.get(AppConstants.themeKey, defaultValue: 'system');
    return _themeFromString(savedTheme);
  }

  void setTheme(ThemeMode mode) {
    final box = Hive.box(AppConstants.hiveBoxName);
    box.put(AppConstants.themeKey, _themeToString(mode));
    state = mode;
  }

  // Convenience getters
  bool get isDark => state == ThemeMode.dark;
  bool get isLight => state == ThemeMode.light;
  bool get isSystem => state == ThemeMode.system;

  ThemeMode _themeFromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() => ThemeNotifier());
