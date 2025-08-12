import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/app_export.dart';
import 'package:gov_connect/src/presentation/screens/email_verification_screen.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/presentation/screens/app_navigation_screen.dart';
import 'src/core/theme/theme_config.dart';

void main() {
  runApp(const GovConnectApp());
}

class GovConnectApp extends StatelessWidget {
  const GovConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double fontScale = 1.0;
    return MaterialApp(
      title: 'GovConnect',
      theme: AppTheme.lightTheme(fontScale),
      darkTheme: AppTheme.darkTheme(fontScale),
      initialRoute: '/',
      routes: AppRoutes.routes
    );
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
