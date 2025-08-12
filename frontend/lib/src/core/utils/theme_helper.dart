import 'package:flutter/material.dart';

String _appTheme = "lightCode";
LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

class ThemeHelper {
  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  /// Changes the app theme to [_newTheme].
  void changeTheme(String _newTheme) {
    _appTheme = _newTheme;
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  LightCodeColors themeColor() => _getThemeColors();

  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get black => Color(0xFF1E1E1E);
  Color get white => Color(0xFFFFFFFF);
  Color get gray400 => Color(0xFF9CA3AF);

  // Additional Colors
  Color get whiteCustom => Colors.white;
  Color get transparentCustom => Colors.transparent;
  Color get blackCustom => Colors.black;
  Color get greyCustom => Colors.grey;
  Color get colorFFFF52 => Color(0xFFFF5252);
  Color get colorFF4CAF => Color(0xFF4CAF50);
  Color get colorFFB8E3 => Color(0xFFB8E3FF);
  Color get colorFF3838 => Color(0xFF383838);
  Color get colorFF1717 => Color(0xFF171717);
  Color get colorFF4040 => Color(0xFF404040);
  Color get colorFFEBF4 => Color(0xFFEBF4FE);
  Color get colorFF7373 => Color(0xFF737373);
  Color get colorFFD4D4 => Color(0xFFD4D4D4);
  Color get colorFF007B => Color(0xFF007BCE);
  Color get colorFF5252 => Color(0xFF525252);
  Color get colorFF6B72 => Color(0xFF6B7280);
  Color get colorFF0062 => Color(0xFF0062A7);
  Color get colorFF0845 => Color(0xFF084572);
  Color get colorFFADAE => Color(0xFFADAEBC);
  Color get colorFFF3F4 => Color(0xFFF3F4F6);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}
