import 'package:flutter/material.dart';
import 'app_colors.dart';

class app_textstyles {
  //appbar title
  static TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primary_text,
  );

  //dashboard, card title text
  static TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primary_text,
  );

  //card primary text
  static TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary_text,
  );

  //subtitle
  static TextStyle subTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.subtitle,
  );

  //normal body text

  static TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.body_text,
  );

  //serial ,time
  static TextStyle highlight = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary_text,
  );

  //input text
  static TextStyle inputText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.body_text,
  );

  // Hint
  static TextStyle hint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.hint_text,
  );

  //Button Text
  static TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.inputColor,
  );

  //Small Info (Footer, Version, Note)
  static final TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.hint_text,
  );

}
