import 'package:flutter/material.dart';
import '../app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline24 => TextStyle(
    fontSize: 24,
    color: appTheme.colorFF1717,
  );

  TextStyle get headline24Regular => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: appTheme.colorFF1717,
  );

  TextStyle get headline20Regular => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: appTheme.colorFF1717,
  );

  TextStyle get headline18Regular => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: appTheme.colorFF1717,
  );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title20 => TextStyle(
    fontSize: 20,
    color: appTheme.colorFF3838,
  );

  TextStyle get title18Medium => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: appTheme.colorFF1717,
  );

  TextStyle get title16 => TextStyle(
    fontSize: 16,
    color: appTheme.colorFF4040,
  );

  TextStyle get title16Medium => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: appTheme.colorFF1717,
  );

  TextStyle get title16Regular => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: appTheme.blackCustom,
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14 => TextStyle(
    fontSize: 14,
    color: appTheme.colorFF7373,
  );

  TextStyle get body14Regular => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  TextStyle get body14Medium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: appTheme.colorFF1717,
  );

  TextStyle get body12 => TextStyle(
    fontSize: 12,
    color: appTheme.colorFF6B72,
  );

  TextStyle get body12Regular => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: appTheme.colorFF5252,
  );

  TextStyle get body16Regular => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: appTheme.colorFF1717,
  );

  TextStyle get body16Medium => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: appTheme.colorFF1717,
  );

  TextTheme textTheme([double scale = 1.0]) => TextTheme(
    displayLarge: headline24.copyWith(fontSize: 24 * scale),
    displayMedium: headline24Regular.copyWith(fontSize: 24 * scale),
    titleLarge: title20.copyWith(fontSize: 20 * scale),
    titleMedium: title18Medium.copyWith(fontSize: 18 * scale),
    titleSmall: title16Medium.copyWith(fontSize: 16 * scale),
    bodyLarge: body14Medium.copyWith(fontSize: 14 * scale),
    bodyMedium: body14Regular.copyWith(fontSize: 14 * scale),
    bodySmall: body12Regular.copyWith(fontSize: 12 * scale),
    labelLarge: title16Regular.copyWith(fontSize: 16 * scale),
    labelMedium: body14.copyWith(fontSize: 14 * scale),
    labelSmall: body12.copyWith(fontSize: 12 * scale),
  );
}
