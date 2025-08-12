import 'package:flutter/material.dart';
import '../../presentation/screens/gov_connect_sign_in_screen.dart';
import '../../presentation/screens/email_verification_screen.dart';
import '../../presentation/screens/app_navigation_screen.dart';
import '../../presentation/screens/notifications_screen.dart';

class AppRoutes {
  static const String govConnectSignInScreen = '/gov_connect_sign_in_screen';
  static const String emailVerificationScreen = '/email_verification_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String notificationsScreen = '/notifications';

  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    govConnectSignInScreen: (context) => const GovConnectSignInScreen(),
    emailVerificationScreen: (context) => const EmailVerificationScreen(),
    appNavigationScreen: (context) => const AppNavigationScreen(),
    initialRoute: (context) => const AppNavigationScreen(),
    notificationsScreen: (context) => const NotificationsScreen(),
  };
}
