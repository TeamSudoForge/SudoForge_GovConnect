import 'package:flutter/material.dart';
import 'package:gov_connect/src/presentation/screens/login_screen.dart';
import '../../presentation/screens/email_verification_screen.dart';
import '../../presentation/screens/app_navigation_screen.dart';
import '../../presentation/screens/notifications_screen.dart';

class AppRoutes {
  static const String govConnectSignInScreen = '/signInSignUpPage';
  static const String emailVerificationScreen = '/emailVerification';
  static const String appNavigationScreen = '/appNavigation';
  static const String notificationsScreen = '/notifications';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    govConnectSignInScreen: (context) => const LoginScreen(),
    emailVerificationScreen: (context) => const EmailVerificationScreen(),
    appNavigationScreen: (context) => const AppNavigationScreen(),
    notificationsScreen: (context) => const NotificationsScreen(),
    initialRoute: (context) => const AppNavigationScreen(),
  };
}
