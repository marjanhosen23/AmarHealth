import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_textstyles.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(

      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: app_textstyles.appBarTitle,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.card_primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),


      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary_disabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: app_textstyles.button,
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.inputNormal_border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.inputfocas_border, width: 2),
        ),
        hintStyle: app_textstyles.hint,
      ),
    );
  }
}
