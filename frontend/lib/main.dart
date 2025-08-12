import 'package:flutter/material.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/core/theme/theme_config.dart';
import 'src/presentation/widgets/common_app_bar.dart';
import 'src/core/routes/app_routes.dart';

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
      routes: {...AppRoutes.routes..remove(AppRoutes.initialRoute)},
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'GovConnect Home',
        showBackButton: false,
        showNotifications: true,
        showProfile: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.govConnectSignInScreen);
              },
              child: const Text('Go to Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.notificationsScreen);
              },
              child: const Text('Go to Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
