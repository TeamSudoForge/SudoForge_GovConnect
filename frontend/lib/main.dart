import 'package:flutter/material.dart';

void main() {
  runApp(const GovConnectApp());
}

class GovConnectApp extends StatelessWidget {
  const GovConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GovConnect',
      home: Scaffold(
        body: Center(child: Text('GovConnect App Initialized')),
      ),
    );
  }
}
