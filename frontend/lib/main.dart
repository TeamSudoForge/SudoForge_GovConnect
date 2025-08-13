import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/providers/auth_provider.dart';
import 'package:gov_connect/src/presentation/screens/email_verification_screen.dart';
import 'package:provider/provider.dart';
import 'package:gov_connect/src/core/app_export.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/presentation/screens/home_screen.dart';
import 'src/presentation/screens/two_factor_verification_screen.dart';
import 'src/core/theme/theme_config.dart';
import 'src/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices();
  runApp(const GovConnectApp());
}

class GovConnectApp extends StatelessWidget {
  const GovConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ServiceLocator>(
          create: (_) => ServiceLocator(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => ServiceLocator().authService,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'GovConnect',
            theme: AppTheme.lightTheme(1.0),
            darkTheme: AppTheme.darkTheme(1.0),
            home: Consumer<AuthService>(
              builder: (context, auth, _) {
                // Store email in AuthProvider when authentication status changes
                if (auth.state.email != null) {
                  context.read<AuthProvider>().setEmail(auth.state.email);
                }

                switch (auth.state.status) {
                  case AuthStatus.authenticated:
                    return const HomeScreen();
                  case AuthStatus.requires2FA:
                    return const TwoFactorVerificationScreen();
                  case AuthStatus.requiresEmailVerification:
                    return const EmailVerificationScreen();
                  default:
                    return const LoginScreen();
                }
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/email-verification': (context) => const EmailVerificationScreen(),
              '/two-factor': (context) => const TwoFactorVerificationScreen(),
            },
          );
        },
      ),
    );
  }
}
