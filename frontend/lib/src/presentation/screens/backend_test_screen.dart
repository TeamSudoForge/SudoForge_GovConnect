import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  String _testResult = 'Tap "Test Backend" to check connectivity';
  bool _isLoading = false;

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing backend connection...';
    });

    try {
      // Test 1: Basic connectivity
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _testResult = '''✅ Backend is accessible!
Status: ${response.statusCode}
Response: ${response.body}

Now testing passkey endpoint...''';
      });

      // Test 2: Passkey endpoint
      final passkeyResponse = await http.post(
        Uri.parse('http://10.0.2.2:3000/passkey/authenticate/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': 'test@example.com'}),
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _testResult += '''

✅ Passkey endpoint test:
Status: ${passkeyResponse.statusCode}
Response: ${passkeyResponse.body}''';
      });

    } catch (e) {
      setState(() {
        _testResult = '''❌ Backend connection failed!
Error: $e

Possible solutions:
1. Make sure your backend server is running on port 3000
2. Check if the backend has the /passkey/authenticate/start endpoint
3. Try using 'http://localhost:3000' instead of 'http://10.0.2.2:3000'
4. If testing on a real device, use your computer's IP address''';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connectivity Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testBackendConnection,
              child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Test Backend Connection'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
                    style: const TextStyle(fontFamily: 'monospace'),
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
