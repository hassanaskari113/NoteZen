import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notezen/core/constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Colors ────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C8FFF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color accent = Color(0xFF00BFA5);

  // ─── Light Theme Colors ──────────────────────────
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ─── Dark Theme Colors ───────────────────────────
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);

  // ─── Text Colors ─────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);

  // ─── Priority Colors ─────────────────────────────
  static const Color priorityHigh = Color(0xFFEF5350);
  static const Color priorityMedium = Color(0xFFFFA726);
  static const Color priorityLow = Color(0xFF66BB6A);

  // ─── Status Colors ───────────────────────────────
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);

  // ─── Note Card Colors ────────────────────────────
  static const List<int> noteColors = [
    0xFFFFFFFF,
    0xFFFFF9C4,
    0xFFE8F5E9,
    0xFFE3F2FD,
    0xFFFCE4EC,
    0xFFF3E5F5,
    0xFFE0F7FA,
    0xFFFFF3E0,
  ];

  // ─── Text Theme ──────────────────────────────────
  static TextTheme _buildTextTheme(Color primaryText) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: primaryText),
      headlineLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: primaryText),
      headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: primaryText),
      headlineSmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: primaryText),
      bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: primaryText),
      bodyMedium: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: primaryText),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: primaryText.withValues(alpha: 0.7),
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: primaryText.withValues(alpha: 0.5),
      ),
    );
  }

  // ─── Light Theme ─────────────────────────────────
  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: lightSurface,
      primary: primary,
      secondary: accent,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBg,
      textTheme: _buildTextTheme(textPrimary),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: lightBg,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusCard)),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(color: textHint, fontSize: 14),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: primary);
          }
          return GoogleFonts.poppins(fontSize: 12, color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary);
          }
          return IconThemeData(color: textSecondary);
        }),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusChip)),
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceSM),
      ),

      dividerTheme: DividerThemeData(color: Colors.grey.withValues(alpha: 0.15), thickness: 1),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusDialog)),
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: darkSurface,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
      ),
    );
  }

  // ─── Dark Theme ──────────────────────────────────
  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: darkSurface,
      primary: primaryLight,
      secondary: accent,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      textTheme: _buildTextTheme(Colors.white),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkBg,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusCard)),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide(color: primaryLight, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: primaryLight);
          }
          return GoogleFonts.poppins(fontSize: 12, color: Colors.white54);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryLight);
          }
          return IconThemeData(color: Colors.white54);
        }),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusChip)),
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceSM),
      ),

      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.1), thickness: 1),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusDialog)),
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
