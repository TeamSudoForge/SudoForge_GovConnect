import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../core/routes/app_router.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Simulate loading time and check authentication
    Timer(Duration(seconds: 2), () {
      _navigateBasedOnAuth();
    });
  }

  void _navigateBasedOnAuth() {
    // Mark that splash has been shown for this session
    AppRouter.markSplashAsShown();

    final authService = Provider.of<AuthService>(context, listen: false);
    final authStatus = authService.state.status;

    switch (authStatus) {
      case AuthStatus.authenticated:
        context.go('/home');
        break;
      case AuthStatus.requires2FA:
        // You might want to pass email from stored state
        context.go('/two-factor-verification');
        break;
      case AuthStatus.unauthenticated:
      default:
        context.go('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Splash background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash logo
            Image.asset('assets/splash_logo.png', width: 120, height: 120),
            SizedBox(height: 13),
            // App name
            Text(
              "GovConnect",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D6EFD),
              ),
            ),
            // SizedBox(height: 8),
            // // Subtitle
            // Text(
            //   "Connecting you to government services",
            //   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            // ),
            // SizedBox(height: 40),
            // // Loading indicator
            // CircularProgressIndicator(
            //   valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D6EFD)),
            // ),
          ],
        ),
      ),
    );
  }
}
