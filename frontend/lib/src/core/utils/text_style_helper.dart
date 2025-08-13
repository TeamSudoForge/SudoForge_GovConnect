import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/theme/theme_config.dart';

/// Centralized text styles for the app
class AppTextStyles {
  AppTextStyles._();

  // Headline styles
  static const TextStyle headline24 =
      TextStyle(fontSize: 24, color: AppColors.colorFF1717);
  static const TextStyle headline24Regular = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.colorFF1717,
  );

  // Title styles
  static const TextStyle title20RegularRoboto = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );
  static const TextStyle title20 =
      TextStyle(fontSize: 20, color: AppColors.colorFF3838);
  static const TextStyle title18Medium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.colorFF1717,
  );
  static const TextStyle title16 =
      TextStyle(fontSize: 16, color: AppColors.colorFF4040);
  static const TextStyle title16Medium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.colorFF1717,
  );
  static const TextStyle title16Regular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.blackCustom,
  );

  // Body styles
  static const TextStyle body14 =
      TextStyle(fontSize: 14, color: AppColors.colorFF7373);
  static const TextStyle body14Regular =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle body14Medium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.colorFF1717,
  );
  static const TextStyle body12 =
      TextStyle(fontSize: 12, color: AppColors.colorFF6B72);
  static const TextStyle body12Regular = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.colorFF5252,
  );

  // Aliases for backward compatibility
  static const TextStyle title1 = headline24;
  static const TextStyle title1Regular = headline24Regular;
  static const TextStyle title2 = title20;
  static const TextStyle bodyMedium = body14;
  static const TextStyle bodySmall = body12;
}

/// Singleton helper to provide a complete TextTheme and easy style access
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

  // Direct access to AppTextStyles constants
  TextStyle get headline24 => AppTextStyles.headline24;
  TextStyle get headline24Regular => AppTextStyles.headline24Regular;
  TextStyle get title20RegularRoboto => AppTextStyles.title20RegularRoboto;
  TextStyle get title20 => AppTextStyles.title20;
  TextStyle get title18Medium => AppTextStyles.title18Medium;
  TextStyle get title16 => AppTextStyles.title16;
  TextStyle get title16Medium => AppTextStyles.title16Medium;
  TextStyle get title16Regular => AppTextStyles.title16Regular;
  TextStyle get body14 => AppTextStyles.body14;
  TextStyle get body14Regular => AppTextStyles.body14Regular;
  TextStyle get body14Medium => AppTextStyles.body14Medium;
  TextStyle get body12 => AppTextStyles.body12;
  TextStyle get body12Regular => AppTextStyles.body12Regular;
}
