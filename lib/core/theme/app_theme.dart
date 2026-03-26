import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.secondary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        brightness: Brightness.light,
        surface: AppColors.cardBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.rubik(
          color: AppColors.textPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: GoogleFonts.rubikTextTheme(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.secondary,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.rubik(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme),
    );
  }
}
