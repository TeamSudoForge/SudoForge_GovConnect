import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    print('[SplashScreen] Starting 2 second timer');
    Timer(Duration(seconds: 2), () {
      print('[SplashScreen] Timer complete, navigating...');
      _navigateBasedOnAuth();
    });
  }

  void _navigateBasedOnAuth() async {
    // Mark that splash has been shown for this session
    AppRouter.markSplashAsShown();

    if (mounted) {
      // Always go to welcome screens first - let the router handle auth-based navigation
      context.go('/welcome');
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
                color: Color.fromARGB(255, 7, 43, 97),
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
