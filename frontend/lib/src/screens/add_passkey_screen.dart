import 'package:flutter/material.dart';
import 'package:gov_connect/src/auth_service.dart';
import 'package:gov_connect/src/services/passkey_api_service.dart';
import 'package:provider/provider.dart';

class AddPasskeyScreen extends StatefulWidget {
  const AddPasskeyScreen({super.key});

  @override
  State<AddPasskeyScreen> createState() => _AddPasskeyScreenState();
}

class _AddPasskeyScreenState extends State<AddPasskeyScreen> {
  String _message = '';
  bool _isLoading = false;

  void _addPasskey() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final passkeyService = PasskeyApiService(authService);
      await passkeyService.addPasskey();
      setState(() {
        _message = 'Passkey added successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to add passkey: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Passkey'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Add a passkey to your account for a more secure and convenient login experience.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _addPasskey,
                child: const Text('Add Passkey'),
              ),
            const SizedBox(height: 20),
            Text(_message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
