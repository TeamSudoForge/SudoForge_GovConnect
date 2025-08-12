import 'package:flutter/material.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/presentation/screens/notifications_screen.dart';
import 'src/core/theme/theme_config.dart';

void main() {
  runApp(const GovConnectApp());
}

class GovConnectApp extends StatelessWidget {
  const GovConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example font scale, can be made dynamic via settings/provider
    const double fontScale = 1.0;
    return MaterialApp(
      title: 'GovConnect',
      theme: AppTheme.lightTheme(fontScale),
      darkTheme: AppTheme.darkTheme(fontScale),
      home: const HomePage(),
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
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Go to Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              child: const Text('Go to Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
