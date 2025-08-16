import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/providers/auth_provider.dart';
import 'package:gov_connect/src/presentation/screens/email_verification_screen.dart';
import 'package:provider/provider.dart';
import 'package:gov_connect/src/core/app_export.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/presentation/screens/home_screen.dart';
import 'src/presentation/screens/two_factor_verification_screen.dart';
import 'package:gov_connect/src/presentation/screens/add_passkey_screen.dart';
import 'package:gov_connect/src/presentation/screens/passkey_login_screen.dart';
import 'src/core/theme/theme_config.dart';
import 'src/injection.dart';
import 'src/core/theme/theme_config.dart';
import 'src/injection.dart';
import 'src/core/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'src/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'src/core/providers/notification_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService().showLocalNotification(message);
}

Future<void> _backgroundHandler(RemoteMessage message) async {
  // Handle background message
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeServices();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const GovConnectApp());
}

class GovConnectApp extends StatelessWidget {
  const GovConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize notification provider after app starts
    // Future.microtask(
    //   () => Provider.of<NotificationProvider>(context, listen: false).init(),
    // );
    return MultiProvider(
      providers: providers,
      child: Consumer2<AuthService, SettingsService>(
        builder: (context, authService, settingsService, child) {
          final fontScale = settingsService.currentFontScale;
          final router = AppRouter.createRouter(authService);

          return MaterialApp.router(
            title: 'GovConnect',
            theme: AppTheme.lightTheme(fontScale),
            darkTheme: AppTheme.darkTheme(fontScale),
            themeMode: settingsService.settings.materialThemeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
