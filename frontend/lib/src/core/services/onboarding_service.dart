import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasSeenWelcomeKey = 'has_seen_welcome_screens';
  
  static OnboardingService? _instance;
  late SharedPreferences _prefs;
  
  OnboardingService._();
  
  static OnboardingService get instance {
    _instance ??= OnboardingService._();
    return _instance!;
  }
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  bool get hasSeenWelcomeScreens {
    final hasSeen = _prefs.getBool(_hasSeenWelcomeKey) ?? false;
    print('[Onboarding] Has seen welcome screens: $hasSeen');
    return hasSeen;
  }
  
  Future<void> markWelcomeScreensAsSeen() async {
    await _prefs.setBool(_hasSeenWelcomeKey, true);
  }
  
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_hasSeenWelcomeKey, false);
    print('[Onboarding] Welcome screens reset - will show on next launch');
  }
}