import 'package:flutter/material.dart';
import 'package:gov_connect/src/passkey_service.dart';

class PasskeyScreen extends StatefulWidget {
  const PasskeyScreen({super.key});

  @override
  State<PasskeyScreen> createState() => _PasskeyScreenState();
}

class _PasskeyScreenState extends State<PasskeyScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final PasskeyService _passkeyService = PasskeyService('http://10.0.2.2:3000'); // Use 10.0.2.2 for Android emulator

  String _message = '';

  void _register() async {
    try {
      await _passkeyService.register(_usernameController.text);
      setState(() {
        _message = 'Registration successful!';
      });
    } catch (e) {
      setState(() {
        _message = 'Registration failed: $e';
      });
    }
  }

  void _login() async {
    try {
      await _passkeyService.authenticate();
      setState(() {
        _message = 'Login successful!';
      });
    } catch (e) {
      setState(() {
        _message = 'Login failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passkey Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register with Passkey'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login with Passkey'),
            ),
            const SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
