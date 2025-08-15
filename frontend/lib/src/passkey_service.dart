import 'dart:convert';
import 'package:http/http.dart' as http;

class PasskeyService {
  final String baseUrl;
  final Passkeys _passkeys;

  PasskeyService(this.baseUrl) : _passkeys = Passkeys();

  Future<void> register(String username) async {
    try {
      // 1. Start registration on the backend
      final startResponse = await http.post(
        Uri.parse('$baseUrl/passkey/register/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (startResponse.statusCode != 201) {
        throw Exception('Failed to start passkey registration');
      }

      final creationOptions = jsonDecode(startResponse.body);

      // 2. Use the passkeys package to create the credential on the device
      final credential = await _passkeys.create(
        relyingPartyId: creationOptions['rp']['id'],
        user: PasskeyUser(
          id: creationOptions['user']['id'],
          name: creationOptions['user']['name'],
          displayName: creationOptions['user']['displayName'],
        ),
        challenge: base64Url.decode(creationOptions['challenge']),
      );

      // 3. Finish registration on the backend
      final finishResponse = await http.post(
        Uri.parse('$baseUrl/passkey/register/finish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credential.toJson()),
      );

      if (finishResponse.statusCode != 201) {
        throw Exception('Failed to finish passkey registration');
      }
    } catch (e) {
      // Handle errors appropriately in your UI
      print('Passkey registration failed: $e');
      rethrow;
    }
  }

  Future<void> authenticate(String username) async {
    try {
      // 1. Start authentication on the backend
      final startResponse = await http.post(
        Uri.parse('$baseUrl/passkey/authenticate/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (startResponse.statusCode != 201) {
        throw Exception('Failed to start passkey authentication');
      }

      final requestOptions = jsonDecode(startResponse.body);

      // 2. Use the passkeys package to get the credential from the device
      final credential = await _passkeys.get(
        relyingPartyId: requestOptions['rpId'],
        challenge: base64Url.decode(requestOptions['challenge']),
      );

      // 3. Finish authentication on the backend
      final finishResponse = await http.post(
        Uri.parse('$baseUrl/passkey/authenticate/finish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credential.toJson()),
      );

      if (finishResponse.statusCode != 201 ||
          !jsonDecode(finishResponse.body)['verified']) {
        throw Exception('Failed to finish passkey authentication');
      }
      // Handle successful login
    } catch (e) {
      // Handle errors appropriately in your UI
      print('Passkey authentication failed: $e');
      rethrow;
    }
  }
}
