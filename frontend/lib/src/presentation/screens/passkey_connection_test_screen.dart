import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasskeyConnectionTestScreen extends StatefulWidget {
  const PasskeyConnectionTestScreen({Key? key}) : super(key: key);

  @override
  State<PasskeyConnectionTestScreen> createState() => _PasskeyConnectionTestScreenState();
}

class _PasskeyConnectionTestScreenState extends State<PasskeyConnectionTestScreen> {
  String _result = 'Tap the button to test connection';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing connection...';
    });

    try {
      // Test the passkey authentication begin endpoint
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/passkey/authenticate/begin'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = '''✅ Connection successful!
Status Code: ${response.statusCode}
Response: ${jsonEncode(data)}

The backend passkey endpoint is working correctly.
The challenge is: ${data['challenge']}
RP ID: ${data['rpId']}''';
        });
      } else {
        setState(() {
          _result = '''❌ Connection failed
Status Code: ${response.statusCode}
Response: ${response.body}''';
        });
      }
    } catch (e) {
      setState(() {
        _result = '''❌ Connection error: $e

Make sure:
1. Backend is running on port 3000
2. You're testing on Android emulator (uses 10.0.2.2)
3. For real devices, use your computer's IP address''';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passkey Connection Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This test checks if the Flutter frontend can connect to the NestJS backend passkey endpoints.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading 
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Testing...'),
                    ],
                  )
                : const Text('Test Passkey Connection'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
