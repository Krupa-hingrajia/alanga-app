import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors from Official Alanga Logo Ribbons
  static const Color darkGreen = Color(0xFF0C2417); // Deepest luxury background from logo
  static const Color forestGreen = Color(0xFF143B26); // Mid forest green
  static const Color forestCard = Color(0xFF1B4D33); // Card forest green
  static const Color primaryGreen = Color(0xFF10B981); // Vibrant leaf green badge
  static const Color brandRed = Color(0xFFFF2A3A); // Crimson-ruby ribbon swoosh
  static const Color brandOrange = Color(0xFFFF8800); // Solar orange ribbon swoosh
  static const Color brandYellow = Color(0xFFFFB703); // Golden-amber ribbon swoosh
  static const Color brandLime = Color(0xFF8CE024); // Fresh lime ribbon swoosh
  static const Color creamBadge = Color(0xFFF9F7EE); // Soft cream badge from logo

  // Logo Ribbons Detailed
  static const Color ribbonRuby = Color(0xFFFF2A3A);
  static const Color ribbonCoral = Color(0xFFFF5E36);
  static const Color ribbonAmber = Color(0xFFFF9E00);
  static const Color ribbonGold = Color(0xFFFFC000);
  static const Color ribbonLime = Color(0xFF8CE024);
  static const Color ribbonEmerald = Color(0xFF10B981);

  // Light Mode Colors
  static const Color bgLight = Color(0xFFF7FAF8); // Clean, airy modern off-white
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F261A);
  static const Color textSecondaryLight = Color(0xFF456353);
  static const Color borderLight = Color(0xFFD6E2DB);

  // Dark Mode Colors
  static const Color bgDark = Color(0xFF08170F);
  static const Color surfaceDark = Color(0xFF11291D);
  static const Color textPrimaryDark = Color(0xFFE4ECE8);
  static const Color textSecondaryDark = Color(0xFF8B9E94);
  static const Color borderDark = Color(0xFF1E4330);

  // Modern Fresh & Bright Gradients
  static const LinearGradient logoRibbonGradient = LinearGradient(
    colors: [ribbonRuby, ribbonAmber, ribbonLime],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Clean Modern Light Header Gradient (Subtle fresh pearl mint)
  static const LinearGradient modernLightHeaderGradient = LinearGradient(
    colors: [
      Colors.white,
      Color(0xFFF6FAF7),
      Color(0xFFEFF7F2),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient brandHeaderGradient = LinearGradient(
    colors: [
      Colors.white,
      Color(0xFFF7FAF8),
      Color(0xFFEFF7F2),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient brandEmeraldGradient = LinearGradient(
    colors: [
      Color(0xFF059669),
      Color(0xFF10B981),
      Color(0xFF34D399),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGoldGradient = LinearGradient(
    colors: [
      Color(0xFFFF8800),
      Color(0xFFFFB703),
      Color(0xFFFFD166),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandRubyGradient = LinearGradient(
    colors: [
      Color(0xFFFF2A3A),
      Color(0xFFFF5E36),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [
      Color(0xFF0E2E1D),
      Color(0xFF194A30),
      Color(0xFF236542),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
