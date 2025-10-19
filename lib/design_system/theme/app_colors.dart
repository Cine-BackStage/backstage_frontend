import 'package:flutter/material.dart';

/// Backstage Cinema Color Palette
/// Based on official style guide
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color cinematicBlack = Color(0xFF0D0D0D);
  static const Color spotlightWhite = Color(0xFFF5F5F5);

  // Accent Colors
  static const Color goldenReel = Color(0xFFFFD700);
  static const Color popcornYellow = Color(0xFFFFD64D);
  static const Color orangeSpotlight = Color(0xFFFF8C42);

  // Support Colors
  static const Color grayCurtain = Color(0xFF2E2E2E);
  static const Color ticketStubBeige = Color(0xFFF2E6D0);

  // Alert Colors
  static const Color alertRed = Color(0xFFFF4444);
  static const Color successGreen = Color(0xFF22C55E);

  // Semantic Colors
  static const Color primary = orangeSpotlight;
  static const Color secondary = goldenReel;
  static const Color background = cinematicBlack;
  static const Color surface = grayCurtain;
  static const Color onPrimary = spotlightWhite;
  static const Color onSecondary = cinematicBlack;
  static const Color onBackground = spotlightWhite;
  static const Color onSurface = spotlightWhite;
  static const Color error = alertRed;
  static const Color success = successGreen;

  // Text Colors
  static const Color textPrimary = spotlightWhite;
  static const Color textSecondary = grayCurtain;
  static const Color textHeading = goldenReel;
  static const Color textMuted = Color(0xFF888888);

  // Button Colors
  static const Color buttonPrimary = orangeSpotlight;
  static const Color buttonSecondary = goldenReel;
  static const Color buttonGhost = Colors.transparent;

  // State Colors
  static const Color stateScheduled = popcornYellow;
  static const Color stateInProgress = orangeSpotlight;
  static const Color stateCompleted = successGreen;

  // Alert Colors
  static const Color alertCritical = alertRed;
  static const Color alertWarning = orangeSpotlight;
  static const Color alertInfo = popcornYellow;
}
