import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Colors.black87;
  static const Color secondary = Colors.blue;
  static const Color danger = Colors.red;
  
  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color surface = Color(0xFFF1F3F5);
  static const Color iconBackground = Color(0xFFE7F5FF);
  
  // Text Colors
  static const Color textPrimary = Colors.black87;
  static final Color textSecondary = Colors.grey[600]!;
  static final Color textTertiary = Colors.grey[500]!;
  static final Color textHint = Colors.grey[400]!;
  
  // Status Colors
  static const Color statusAlive = Color(0xFF55CC44);
  static const Color statusDead = Color(0xFFD63D2E);
  static const Color statusUnknown = Color(0xFF9E9E9E);
  
  // Border & Divider
  static final Color border = Colors.grey[200]!;
  static final Color divider = Colors.grey[300]!;

  // Utility
  static Color withOpacity(Color color, double opacity) {
    try {
      // ignore: deprecated_member_use
      return color.withValues(alpha: opacity);
    } catch (_) {
      return color.withOpacity(opacity);
    }
  }

  static Color shadowColor = Colors.black.withOpacity(0.08);
}
