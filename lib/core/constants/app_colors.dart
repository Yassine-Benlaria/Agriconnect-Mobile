import 'package:flutter/material.dart';

class AppColors {
  // Primary greens
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color primaryGreenDark = Color(0xFF1B4332);
  static const Color primaryGreenLight = Color(0xFF52B788);
  static const Color accentGreen = Color(0xFF74C69D);

  // Overlay / Glass
  static const Color overlayDark = Color(0xCC0D1F15); // 80% opacity dark green
  static const Color glassWhite = Color(0x1AFFFFFF);  // 10% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white border
  static const Color glassCard = Color(0x26FFFFFF);   // 15% white

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textMuted = Color(0x80FFFFFF);    // 50% white
  static const Color textDark = Color(0xFF1B4332);

  // Status colors
  static const Color statusPending = Color(0xFFF4A261);
  static const Color statusRejected = Color(0xFFE63946);
  static const Color statusInProgress = Color(0xFF457B9D);
  static const Color statusCompleted = Color(0xFF52B788);

  // Surface (for cards on light backgrounds)
  static const Color surface = Color(0xFF1E3A2F);
  static const Color surfaceLight = Color(0xFF2D5A45);

  // Error
  static const Color error = Color(0xFFE63946);
}
