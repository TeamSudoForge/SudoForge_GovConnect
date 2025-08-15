import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gov_connect/src/core/app_export.dart';
import 'package:gov_connect/src/presentation/screens/email_verification_screen.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/presentation/screens/qrflow/qr_scan_screen.dart';
import 'src/presentation/screens/home_screen.dart';
import 'src/presentation/screens/two_factor_verification_screen.dart';
import 'src/presentation/screens/app_navigation_screen.dart';
import 'src/core/theme/theme_config.dart';
import 'src/injection.dart';
import 'src/core/routes/app_router.dart';
import '/src/core/services/firebase_setup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initializeServices();
  await setupFirebaseAndNotifications();
  runApp(const GovConnectApp());
}

class GovConnectApp extends StatelessWidget {
  const GovConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double fontScale = 1.0;
    return MultiProvider(
      providers: providers,
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          final router = AppRouter.createRouter(authService);

          return MaterialApp.router(
            title: 'GovConnect',
            theme: AppTheme.lightTheme(fontScale),
            darkTheme: AppTheme.darkTheme(fontScale),
            routerConfig: router,
            // navigatorKey: navigatorKey, // Not supported by MaterialApp.router, use GoRouter's navigatorKey if needed
          );
        },
      ),
    );
  }
}
