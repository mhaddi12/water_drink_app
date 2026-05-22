import 'package:flutter/material.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';
import 'package:water_drink_app/app/theme/hydra_theme_colors.dart';

InputDecoration focusInputDecoration(BuildContext context, String label, {String? hint}) {
  final colors = HydraThemeColors.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
    labelStyle: TextStyle(color: colors.muted),
    hintStyle: TextStyle(color: colors.muted),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: isDark ? AppTheme.primary : const Color(0xFF0A2C88),
        width: 1.5,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
