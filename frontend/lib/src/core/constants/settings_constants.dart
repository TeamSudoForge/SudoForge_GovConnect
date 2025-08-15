class SettingsConstants {
  // Storage keys
  static const String settingsKey = 'app_settings';

  // Default values
  static const int defaultSessionTimeout = 30; // minutes
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultBiometricEnabled = false;
  static const bool defaultAutoRefreshQueue = true;

  // Font size limits
  static const double minFontScale = 0.7;
  static const double maxFontScale = 1.5;

  // Session timeout limits
  static const int minSessionTimeout = 5; // minutes
  static const int maxSessionTimeout = 120; // minutes

  // Queue refresh intervals
  static const Duration queueRefreshInterval = Duration(seconds: 30);

  // Notification timing
  static const Duration defaultNotificationTiming = Duration(minutes: 5);

  // Biometric timeout
  static const Duration biometricTimeout = Duration(seconds: 30);
}
