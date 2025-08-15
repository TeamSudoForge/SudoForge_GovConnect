import 'package:flutter/material.dart';
import 'package:gov_connect/src/auth_service.dart';
import 'package:gov_connect/src/services/passkey_api_service.dart';
import 'package:provider/provider.dart';

class PasskeyLoginScreen extends StatefulWidget {
  const PasskeyLoginScreen({super.key});

  @override
  State<PasskeyLoginScreen> createState() => _PasskeyLoginScreenState();
}

class _PasskeyLoginScreenState extends State<PasskeyLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  void _login() async {
    if (_usernameController.text.isEmpty) {
      setState(() => _message = 'Please enter a username');
      return;
    }
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final passkeyService = PasskeyApiService(authService);
      final token = await passkeyService.loginWithPasskey(_usernameController.text);
      if (token.isNotEmpty) {
        setState(() {
          _message = 'Login successful!';
        });
        // TODO: Navigate to home screen
      } else {
        setState(() {
          _message = 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Login failed: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Passkey'),
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
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login with Passkey'),
              ),
            const SizedBox(height: 20),
            Text(_message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
