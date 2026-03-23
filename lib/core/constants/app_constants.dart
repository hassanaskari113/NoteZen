class AppConstants {
  AppConstants._();

  // Database
  static const String dbName = 'notezen_database.db';
  static const int dbVersion = 1;
  static const String hiveBoxName = 'notezen_hivebox';

  // Table Names
  static const String notes = 'Notes';
  static const String tasks = 'Tasks';
  static const String folders = 'Folders';

  // Hive Keys
  static const String themeKey = 'themeMode';

  // App Info
  static const String appName = 'NoteZen';
  static const String appVersion = 'v1.0.0';

  // Spacing Scale
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 12;
  static const double spaceLG = 16;
  static const double spaceXL = 24;
  static const double spaceXXL = 32;

  // Border Radius
  static const double radiusCard = 16;
  static const double radiusButton = 12;
  static const double radiusChip = 20;
  static const double radiusDialog = 20;
  static const double radiusInput = 12;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);
}
