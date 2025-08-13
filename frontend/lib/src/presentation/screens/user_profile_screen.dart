import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  static const String routeName = '/userProfile';

  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: const Center(
        child: Text('This is the user profile screen.'),
      ),
    );
  }
}
