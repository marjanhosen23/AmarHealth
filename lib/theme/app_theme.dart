import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,

      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundColor,

      /// ColorScheme (IMPORTANT)
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.card_primary,
      ),

      /// AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      /// Card
      cardTheme: CardThemeData(
        color: AppColors.card_primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      /// Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      /// Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }


}