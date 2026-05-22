import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_drink_app/app/theme/hydra_theme_colors.dart';

abstract final class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4F74FF);
  static const Color primaryLight = Color(0xFF62A5FF);

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackground: const Color(0xFFF2F1F7),
    cardColor: Colors.white,
    navBarBackground: Colors.white,
    navSelected: const Color(0xFF2E4CB2),
    navUnselected: const Color(0xFF6D7B8F),
    navIndicator: const Color(0x144F74FF),
    bodyColor: const Color(0xFF152238),
    dividerColor: const Color(0xFFE3EBFF),
    systemOverlay: SystemUiOverlayStyle.dark,
  );

  /// AMOLED-style dark theme: black backgrounds, neutral grays, blue accent only.
  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1A2744),
      onPrimaryContainer: Color(0xFFB8C9FF),
      secondary: primaryLight,
      onSecondary: Colors.black,
      surface: Color(0xFF121212),
      onSurface: Color(0xFFF2F2F2),
      onSurfaceVariant: Color(0xFFB3B3B3),
      outline: Color(0xFF2E2E2E),
      outlineVariant: Color(0xFF1A1A1A),
      error: Color(0xFFFF6B6B),
      onError: Colors.black,
    ),
    scaffoldBackground: Colors.black,
    cardColor: const Color(0xFF121212),
    navBarBackground: Colors.black,
    navSelected: Color(0xFF8EB0FF),
    navUnselected: Color(0xFF8A8A8A),
    navIndicator: Color(0x334F74FF),
    bodyColor: Color(0xFFF2F2F2),
    dividerColor: Color(0xFF2A2A2A),
    systemOverlay: SystemUiOverlayStyle.light,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color navBarBackground,
    required Color navSelected,
    required Color navUnselected,
    required Color navIndicator,
    required Color bodyColor,
    required Color dividerColor,
    required SystemUiOverlayStyle systemOverlay,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      extensions: [
        isDark ? HydraThemeColors.dark : HydraThemeColors.light,
      ],
      scaffoldBackgroundColor: scaffoldBackground,
      cardColor: cardColor,
      dividerColor: dividerColor,
      iconTheme: IconThemeData(color: isDark ? Colors.white : bodyColor),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: bodyColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: systemOverlay,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: bodyColor,
        displayColor: bodyColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBarBackground,
        surfaceTintColor: Colors.transparent,
        indicatorColor: navIndicator,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? navSelected : navUnselected,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 10,
            color: selected ? navSelected : navUnselected,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        contentTextStyle: TextStyle(color: isDark ? Colors.white : null),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? const Color(0xFF6E6E6E) : null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.45);
          }
          return isDark ? const Color(0xFF3A3A3A) : null;
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor),
        ),
      ),
    );
  }
}
