import 'package:flutter/material.dart';
import '../../presentation/screens/gov_connect_sign_in_screen.dart';
import '../../presentation/screens/email_verification_screen.dart';
import '../../presentation/screens/app_navigation_screen.dart';

class AppRoutes {
  static const String govConnectSignInScreen = '/govConnectSignIn';
  static const String emailVerificationScreen = '/emailVerification';
  static const String appNavigationScreen = '/appNavigation';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
        govConnectSignInScreen: (context) => const GovConnectSignInScreen(),
        emailVerificationScreen: (context) => const EmailVerificationScreen(),
        appNavigationScreen: (context) => const AppNavigationScreen(),
        initialRoute: (context) => const AppNavigationScreen(),
      };
}
