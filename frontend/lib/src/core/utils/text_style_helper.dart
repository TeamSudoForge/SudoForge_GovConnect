import 'package:flutter/material.dart';
import '../theme/theme_config.dart';

class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  TextTheme textTheme([double fontScale = 1.0]) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32 * fontScale,
        fontWeight: FontWeight.bold,
        color: AppColors.colorFF1717,
      ),
      titleLarge: TextStyle(
        fontSize: 20 * fontScale,
        fontWeight: FontWeight.w600,
        color: AppColors.colorFF3838,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * fontScale,
        color: AppColors.colorFF7373,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * fontScale,
        color: AppColors.colorFF7373,
      ),
      labelLarge: TextStyle(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w500,
        color: AppColors.colorFF1717,
      ),
    );
  }

  // Individual styles for direct usage
  TextStyle get headline24 => TextStyle(fontSize: 24, color: AppColors.colorFF1717);
  TextStyle get headline24Regular => TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.colorFF1717);
  TextStyle get title20RegularRoboto => TextStyle(fontSize: 20, fontWeight: FontWeight.w400, fontFamily: 'Roboto');
  TextStyle get title20 => TextStyle(fontSize: 20, color: AppColors.colorFF3838);
  TextStyle get title18Medium => TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.colorFF1717);
  TextStyle get title16 => TextStyle(fontSize: 16, color: AppColors.colorFF4040);
  TextStyle get title16Medium => TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.colorFF1717);
  TextStyle get title16Regular => TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.blackCustom);
  TextStyle get body14 => TextStyle(fontSize: 14, color: AppColors.colorFF7373);
  TextStyle get body14Regular => TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  TextStyle get body14Medium => TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.colorFF1717);
  TextStyle get body12 => TextStyle(fontSize: 12, color: AppColors.colorFF6B72);
  TextStyle get body12Regular => TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.colorFF5252);
}
