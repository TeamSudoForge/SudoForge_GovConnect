import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_models.dart';
import '../constants/settings_constants.dart';

class SettingsService extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  // Getters for individual settings
  AppThemeMode get themeMode => _settings.themeMode;
  AppLanguage get language => _settings.language;
  FontSizeOption get fontSize => _settings.fontSize;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get biometricEnabled => _settings.biometricEnabled;
  bool get autoRefreshQueue => _settings.autoRefreshQueue;
  int get sessionTimeoutMinutes => _settings.sessionTimeoutMinutes;

  // Initialize settings from storage
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(SettingsConstants.settingsKey);

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(settingsMap);
      }

      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
      // Use default settings if loading fails
      _settings = const AppSettings();
      notifyListeners();
    }
  }

  // Save settings to storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toJson());
      await prefs.setString(SettingsConstants.settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Update theme mode
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    if (_settings.themeMode != themeMode) {
      _settings = _settings.copyWith(themeMode: themeMode);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update language
  Future<void> updateLanguage(AppLanguage language) async {
    if (_settings.language != language) {
      _settings = _settings.copyWith(language: language);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update font size
  Future<void> updateFontSize(FontSizeOption fontSize) async {
    if (_settings.fontSize != fontSize) {
      _settings = _settings.copyWith(fontSize: fontSize);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update notifications enabled
  Future<void> updateNotificationsEnabled(bool enabled) async {
    if (_settings.notificationsEnabled != enabled) {
      _settings = _settings.copyWith(notificationsEnabled: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update biometric enabled
  Future<void> updateBiometricEnabled(bool enabled) async {
    if (_settings.biometricEnabled != enabled) {
      _settings = _settings.copyWith(biometricEnabled: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update auto refresh queue
  Future<void> updateAutoRefreshQueue(bool enabled) async {
    if (_settings.autoRefreshQueue != enabled) {
      _settings = _settings.copyWith(autoRefreshQueue: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update session timeout
  Future<void> updateSessionTimeout(int minutes) async {
    // Validate timeout range
    final validatedMinutes = minutes.clamp(
      SettingsConstants.minSessionTimeout,
      SettingsConstants.maxSessionTimeout,
    );

    if (_settings.sessionTimeoutMinutes != validatedMinutes) {
      _settings = _settings.copyWith(sessionTimeoutMinutes: validatedMinutes);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _settings = const AppSettings();
    notifyListeners();
    await _saveSettings();
  }

  // Bulk update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    if (_settings != newSettings) {
      _settings = newSettings;
      notifyListeners();
      await _saveSettings();
    }
  }

  // Get current font scale
  double get currentFontScale => _settings.fontSize.scale;

  // Check if dark mode is active (considering system theme)
  bool isDarkMode(bool systemIsDark) {
    switch (_settings.themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return systemIsDark;
    }
  }

  // Export settings as JSON string
  String exportSettings() {
    return jsonEncode(_settings.toJson());
  }

  // Import settings from JSON string
  Future<bool> importSettings(String settingsJson) async {
    try {
      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      final newSettings = AppSettings.fromJson(settingsMap);
      await updateSettings(newSettings);
      return true;
    } catch (e) {
      print('Error importing settings: $e');
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
