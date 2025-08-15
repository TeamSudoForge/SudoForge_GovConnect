import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

enum AppLanguage {
  english('en', 'English'),
  sinhala('si', 'සිංහල'),
  tamil('ta', 'தமிழ்');

  const AppLanguage(this.code, this.displayName);

  final String code;
  final String displayName;
}

enum FontSizeOption {
  small(0.85, 'Small'),
  medium(1.0, 'Medium'),
  large(1.15, 'Large'),
  extraLarge(1.3, 'Extra Large');

  const FontSizeOption(this.scale, this.displayName);

  final double scale;
  final String displayName;
}

class AppSettings {
  final AppThemeMode themeMode;
  final AppLanguage language;
  final FontSizeOption fontSize;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool autoRefreshQueue;
  final int sessionTimeoutMinutes;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.english,
    this.fontSize = FontSizeOption.medium,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.autoRefreshQueue = true,
    this.sessionTimeoutMinutes = 30,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    FontSizeOption? fontSize,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? autoRefreshQueue,
    int? sessionTimeoutMinutes,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoRefreshQueue: autoRefreshQueue ?? this.autoRefreshQueue,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'language': language.code,
      'fontSize': fontSize.name,
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
      'autoRefreshQueue': autoRefreshQueue,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      language: AppLanguage.values.firstWhere(
        (e) => e.code == json['language'],
        orElse: () => AppLanguage.english,
      ),
      fontSize: FontSizeOption.values.firstWhere(
        (e) => e.name == json['fontSize'],
        orElse: () => FontSizeOption.medium,
      ),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      biometricEnabled: json['biometricEnabled'] ?? false,
      autoRefreshQueue: json['autoRefreshQueue'] ?? true,
      sessionTimeoutMinutes: json['sessionTimeoutMinutes'] ?? 30,
    );
  }

  ThemeMode get materialThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.language == language &&
        other.fontSize == fontSize &&
        other.notificationsEnabled == notificationsEnabled &&
        other.biometricEnabled == biometricEnabled &&
        other.autoRefreshQueue == autoRefreshQueue &&
        other.sessionTimeoutMinutes == sessionTimeoutMinutes;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      language,
      fontSize,
      notificationsEnabled,
      biometricEnabled,
      autoRefreshQueue,
      sessionTimeoutMinutes,
    );
  }
}
