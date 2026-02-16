import 'package:flutter/material.dart';

/// Centralized Nabta app color palette.
/// Agri-Green, Earth Brown, and White per .cursorrules.
class AppColors {
  AppColors._();

  static const Color agriGreen = Color(0xFF2E7D32);
  static const Color earthBrown = Color(0xFF795548);
  static const Color deficientRed = Color(0xFFD32F2F);
  static const Color excessAmber = Color(0xFFF9A825);

  /// Satellite map gradient (earth tones, derived from palette).
  static const List<Color> mapGradientColors = [
    Color(0xFF4A7C59),
    Color(0xFF5D6D4E),
    Color(0xFF8B7355),
    Color(0xFF6B8E6B),
  ];
}
