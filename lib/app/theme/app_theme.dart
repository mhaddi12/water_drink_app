import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4F74FF),
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF2F1F7),
      cardColor: Colors.white,
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFF152238),
        displayColor: const Color(0xFF152238),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        height: 68,
        indicatorColor: const Color(0x144F74FF),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 10,
            color: selected ? const Color(0xFF2E4CB2) : const Color(0xFF6D7B8F),
          );
        }),
      ),
    );
  }
}
