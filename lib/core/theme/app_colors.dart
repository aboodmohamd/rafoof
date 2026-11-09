import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color surface;
  final Color imageTile;
  final Color galleryBackground;
  final Color ink;
  final Color textSecondary;
  final Color textBody;
  final Color border;
  final Color borderStrong;
  final Color divider;
  final Color accent;
  final Color onAccent;
  final Color onInk;
  final Color star;
  final Color success;
  final Color successBackground;
  final Color inkChip;
  final Color online;

  const AppColors({
    required this.background,
    required this.surface,
    required this.imageTile,
    required this.galleryBackground,
    required this.ink,
    required this.textSecondary,
    required this.textBody,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.accent,
    required this.onAccent,
    required this.onInk,
    required this.star,
    required this.success,
    required this.successBackground,
    required this.inkChip,
    required this.online,
  });

  static const AppColors light = AppColors(
    background: Color(0xFFF3F4F6),
    surface: Color(0xFFFFFFFF),
    imageTile: Color(0xFFF3F4F6),
    galleryBackground: Color(0xFFECEEF1),
    ink: Color(0xFF14161B),
    textSecondary: Color(0xFF5A6070),
    textBody: Color(0xFF454B59),
    border: Color(0xFFE3E5EA),
    borderStrong: Color(0xFFC9CDD6),
    divider: Color(0xFFEEF0F3),
    accent: Color(0xFFFFD23F),
    onAccent: Color(0xFF14161B),
    onInk: Color(0xFFFFFFFF),
    star: Color(0xFFF5B301),
    success: Color(0xFF0A6B42),
    successBackground: Color(0xFFE4F3EB),
    inkChip: Color(0xFF24272F),
    online: Color(0xFF5FD39A),
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF0F1115),
    surface: Color(0xFF1A1D24),
    imageTile: Color(0xFF262A33),
    galleryBackground: Color(0xFF0F1115),
    ink: Color(0xFFF4F5F7),
    textSecondary: Color(0xFFA3A9B8),
    textBody: Color(0xFFC9CDD6),
    border: Color(0xFF2A2E38),
    borderStrong: Color(0xFF454B59),
    divider: Color(0xFF262A33),
    accent: Color(0xFFFFD23F),
    onAccent: Color(0xFF14161B),
    onInk: Color(0xFF14161B),
    star: Color(0xFFFFD23F),
    success: Color(0xFF5FD39A),
    successBackground: Color(0xFF14322A),
    inkChip: Color(0xFF262A33),
    online: Color(0xFF5FD39A),
  );
}
