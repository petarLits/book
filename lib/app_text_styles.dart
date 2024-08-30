import 'package:book/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static const Color defaultColor = AppColors.primaryTextColor;
  static const double defaultOpacity = 1;

  static TextStyle title({
    Color color = defaultColor,
    double opacity = defaultOpacity,
  }) {
    return TextStyle(
      color: color.withOpacity(opacity),
      fontSize: 32,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle smallerBlackTitle({
    Color color = AppColors.secondaryTextColor,
    double opacity = defaultOpacity,
  }) {
    return TextStyle(
      color: color.withOpacity(opacity),
      fontSize: 28,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle subtitle({
    Color color = AppColors.secondaryTextColor,
    double opacity = defaultOpacity,
  }) {
    return TextStyle(color: color.withOpacity(opacity), fontSize: 20);
  }

  static TextStyle text1({
    Color color = defaultColor,
    double opacity = defaultOpacity,
  }) {
    return TextStyle(color: color.withOpacity(opacity), fontSize: 16);
  }
}
