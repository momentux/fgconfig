import 'package:flutter/material.dart';

class AppTheme {
  static const Color dark = Color(0XFF1E1E1E);
  static const Color meduim = Color(0x50FFFFFF);
  static const Color accent = Color(0xFFFFA500);
  static const Color disableBackgroundColor = Colors.black12;
  static const Color disableForegroundColor = Colors.white12;
  static ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.dark,
        disabledBackgroundColor: AppTheme.disableBackgroundColor,
        disabledForegroundColor: AppTheme.disableForegroundColor);
  }
}
