import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gov_connect/src/core/app_export.dart';
import 'package:gov_connect/src/presentation/screens/email_verification_screen.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/presentation/screens/home_screen.dart';
import 'src/presentation/screens/two_factor_verification_screen.dart';
import 'src/presentation/screens/app_navigation_screen.dart';
import 'src/core/theme/theme_config.dart';
import 'src/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await initializeServices();
  
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
          return MaterialApp(
            title: 'GovConnect',
            theme: AppTheme.lightTheme(fontScale),
            darkTheme: AppTheme.darkTheme(fontScale),
            initialRoute: _getInitialRoute(authService.state.status),
            routes: _getRoutes(),
            onGenerateRoute: (settings) {
              if (settings.name == TwoFactorVerificationScreen.routeName) {
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => TwoFactorVerificationScreen(
                    email: args?['email'] ?? '',
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }

  String _getInitialRoute(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        return '/home';
      case AuthStatus.requires2FA:
        return TwoFactorVerificationScreen.routeName;
      default:
        return LoginScreen.routeName;
    }
  }

  Map<String, WidgetBuilder> _getRoutes() {
    return {
      '/': (context) => const HomePage(),
      '/login': (context) => const LoginScreen(),
      '/home': (context) => const HomeScreen(),
      '/email-verification': (context) => const EmailVerificationScreen(),
    };
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GovConnect Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Go to Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppNavigationScreen()),
                );
              },
              child: const Text('Go to App Navigation'),
            ),
          ],
        ),
      ),
    );
  }
}
