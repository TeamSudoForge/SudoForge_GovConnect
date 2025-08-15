import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/app_export.dart';

// Centralized color definitions
class AppColors {
  static const Color black = Color(0xFF1E1E1E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray400 = Color(0xFF9CA3AF);

  static const Color whiteCustom = Colors.white;
  static const Color transparentCustom = Colors.transparent;
  static const Color blackCustom = Colors.black;
  static const Color greyCustom = Colors.grey;
  static const Color colorFFFF52 = Color(0xFFFF5252);
  static const Color colorFF4CAF = Color(0xFF4CAF50);
  static const Color colorFFB8E3 = Color(0xFFB8E3FF);
  static const Color colorFF3838 = Color(0xFF383838);
  static const Color colorFF1717 = Color(0xFF171717);
  static const Color colorFF4040 = Color(0xFF404040);
  static const Color colorFFEBF4 = Color(0xFFEBF4FE);
  static const Color colorFF7373 = Color(0xFF737373);
  static const Color colorFFD4D4 = Color(0xFFD4D4D4);
  static const Color colorFF007B = Color(0xFF007BCE);
  static const Color colorFF5252 = Color(0xFF525252);
  static const Color colorFF6B72 = Color(0xFF6B7280);
  static const Color colorFF0062 = Color(0xFF0062A7);
  static const Color colorFF0845 = Color(0xFF084572);
  static const Color colorFFADAE = Color(0xFFADAEBC);
  static const Color colorFFF3F4 = Color(0xFFF3F4F6);
  static const Color colorFF5722 = Color(0xFFFF5722);

  static Color get grey200 => Colors.grey.shade200;
  static Color get grey100 => Colors.grey.shade100;
}

// Centralized theme configuration
class AppTheme {
  static ThemeData lightTheme(double fontScale) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.colorFF007B,
      scaffoldBackgroundColor: AppColors.whiteCustom,
      colorScheme: ColorScheme.light(
        primary: AppColors.colorFF007B,
        secondary: AppColors.colorFF0062,
        background: AppColors.whiteCustom,
        surface: AppColors.whiteCustom,
      ),
      textTheme: TextStyleHelper.instance.textTheme(fontScale),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.colorFF007B,
        foregroundColor: AppColors.whiteCustom,
        iconTheme: IconThemeData(color: AppColors.whiteCustom),
        titleTextStyle: TextStyle(
          color: AppColors.whiteCustom,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      // ...other theme properties as needed
    );
  }

  static ThemeData darkTheme(double fontScale) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.colorFF007B,
      scaffoldBackgroundColor: AppColors.blackCustom,
      colorScheme: ColorScheme.dark(
        primary: AppColors.colorFF007B,
        secondary: AppColors.colorFF0062,
        background: AppColors.blackCustom,
        surface: AppColors.blackCustom,
      ),
      textTheme: TextStyleHelper.instance.textTheme(fontScale),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.colorFF007B,
        foregroundColor: AppColors.whiteCustom,
        iconTheme: IconThemeData(color: AppColors.whiteCustom),
        titleTextStyle: TextStyle(
          color: AppColors.whiteCustom,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      // ...other theme properties as needed
    );
  }
}

// Convenience class for accessing theme colors
class ThemeConfig {
  static Color get primaryColor => AppColors.colorFF007B;
  static Color get backgroundColor => AppColors.whiteCustom;
  static Color get textPrimaryColor => AppColors.colorFF1717;
  static Color get textBlack3 => AppColors.colorFF5252;
  static Color get textSecondaryColor => AppColors.colorFF7373;
}
