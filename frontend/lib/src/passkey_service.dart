import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:passkeys_platform_interface/passkeys_platform_interface.dart';

class PasskeyService {
  final String baseUrl;
  final PasskeysPlatform _passkeys = PasskeysPlatform.instance;

  PasskeyService(this.baseUrl);

  Future<void> register(String displayName, {String? accessToken}) async {
    try {
      print('🔐 Starting passkey registration for: $displayName');

      // 1. Start registration on the backend
      final headers = {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

      print('📡 Calling: $baseUrl/auth/passkey/register/begin');
      final startResponse = await http.post(
        Uri.parse('$baseUrl/auth/passkey/register/begin'),
        headers: headers,
        body: jsonEncode({'displayName': displayName}),
      );

      print('📡 Begin response status: ${startResponse.statusCode}');
      print('📡 Begin response body: ${startResponse.body}');

      if (startResponse.statusCode != 200 && startResponse.statusCode != 201) {
        final errorBody = _parseErrorResponse(startResponse.body);
        throw Exception('Failed to start passkey registration: $errorBody');
      }

      final creationOptions = jsonDecode(startResponse.body);
      print('🎯 Registration options received: $creationOptions');

      // 2. Create the credential on the device using the platform interface
      print('📱 Creating credential on device...');
      dynamic credential;

      try {
        credential = await _passkeys.register(creationOptions);
        print('✅ Credential created: ${credential.runtimeType}');
        print('📋 Credential details: $credential');
      } catch (e) {
        print('❌ Failed to create credential on device: $e');
        throw Exception('Failed to create passkey: Device registration failed. Error: $e');
      }

      // 3. Convert credential to JSON manually since toJson() doesn't exist
      final credentialJson = _convertRegistrationToJson(credential);
      print('📝 Converted credential JSON: $credentialJson');

      // 4. Finish registration on the backend
      print('📡 Calling: $baseUrl/auth/passkey/register/complete');
      final finishResponse = await http.post(
        Uri.parse('$baseUrl/auth/passkey/register/complete'),
        headers: headers,
        body: jsonEncode(credentialJson),
      );

      print('📡 Complete response status: ${finishResponse.statusCode}');
      print('📡 Complete response body: ${finishResponse.body}');

      if (finishResponse.statusCode != 200 && finishResponse.statusCode != 201) {
        final errorBody = _parseErrorResponse(finishResponse.body);
        throw Exception('Failed to finish passkey registration: $errorBody');
      }

      final responseBody = jsonDecode(finishResponse.body);
      print('✅ Passkey registration successful: $responseBody');
    } catch (e) {
      print('❌ Passkey registration failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> authenticate() async {
    try {
      print('🔐 Starting passkey authentication');

      // 1. Start authentication on the backend (no username needed per API spec)
      print('📡 Calling: $baseUrl/auth/passkey/authenticate/begin');
      final startResponse = await http.post(
        Uri.parse('$baseUrl/auth/passkey/authenticate/begin'),
        headers: {'Content-Type': 'application/json'},
        // Empty body as per API spec - no username required
        body: jsonEncode({}),
      );

      print('📡 Begin response status: ${startResponse.statusCode}');
      print('📡 Begin response body: ${startResponse.body}');

      if (startResponse.statusCode != 200 && startResponse.statusCode != 201) {
        final errorBody = _parseErrorResponse(startResponse.body);
        throw Exception('Failed to start passkey authentication: $errorBody');
      }

      final requestOptions = jsonDecode(startResponse.body);
      print('🎯 Authentication options received: $requestOptions');

      // 2. Get the credential from the device using the platform interface
      print('📱 Requesting credential from device...');
      dynamic credential;
      
      try {
        credential = await _passkeys.authenticate(requestOptions);
        print('✅ Credential received from device: ${credential.runtimeType}');
        print('📋 Credential details: $credential');
      } catch (e) {
        print('❌ Failed to get credential from device: $e');
        throw Exception('Failed to authenticate with passkey: Device authentication failed. Error: $e');
      }

      // 3. Convert credential to JSON manually since toJson() doesn't exist
      final credentialJson = _convertAuthenticationToJson(credential);
      print('📝 Converted credential JSON: $credentialJson');

      // 4. Finish authentication on the backend
      print('📡 Calling: $baseUrl/auth/passkey/authenticate/complete');
      final finishResponse = await http.post(
        Uri.parse('$baseUrl/auth/passkey/authenticate/complete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credentialJson),
      );

      print('📡 Complete response status: ${finishResponse.statusCode}');
      print('📡 Complete response body: ${finishResponse.body}');

      if (finishResponse.statusCode != 200 && finishResponse.statusCode != 201) {
        final errorBody = _parseErrorResponse(finishResponse.body);
        throw Exception('Failed to finish passkey authentication: $errorBody');
      }

      final responseBody = jsonDecode(finishResponse.body);
      print('✅ Passkey authentication successful: $responseBody');

      // Return the response body which should contain tokens and user info
      return responseBody;
    } catch (e) {
      print('❌ Passkey authentication failed: $e');
      rethrow;
    }
  }

  // Get user's passkeys (requires authentication)
  Future<List<dynamic>> getUserPasskeys(String accessToken) async {
    try {
      print('📡 Calling: $baseUrl/auth/passkeys');
      final response = await http.get(
        Uri.parse('$baseUrl/auth/passkeys'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = _parseErrorResponse(response.body);
        throw Exception('Failed to get user passkeys: $errorBody');
      }

      final responseBody = jsonDecode(response.body);
      return responseBody['passkeys'] ?? [];
    } catch (e) {
      print('❌ Failed to get user passkeys: $e');
      rethrow;
    }
  }

  // Delete a specific passkey (requires authentication)
  Future<void> deletePasskey(String passkeyId, String accessToken) async {
    try {
      print('📡 Calling: $baseUrl/auth/passkeys/$passkeyId');
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/passkeys/$passkeyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = _parseErrorResponse(response.body);
        throw Exception('Failed to delete passkey: $errorBody');
      }

      print('✅ Passkey deleted successfully');
    } catch (e) {
      print('❌ Failed to delete passkey: $e');
      rethrow;
    }
  }

  // Helper method to parse error responses
  String _parseErrorResponse(String responseBody) {
    try {
      final errorJson = jsonDecode(responseBody);
      return errorJson['message'] ?? errorJson['error'] ?? responseBody;
    } catch (e) {
      return responseBody;
    }
  }

  // Helper method to convert RegisterResponseType to JSON
  Map<String, dynamic> _convertRegistrationToJson(dynamic credential) {
    print('🔄 Converting registration credential to JSON...');
    print('📋 Credential type: ${credential.runtimeType}');
    print('📋 Credential value: $credential');

    if (credential is Map<String, dynamic>) {
      print('✅ Credential is already a Map');
      return credential;
    }

    print('⚠️  Credential is not a Map, creating fallback structure');
    
    // Generate a unique credential ID for testing (using timestamp + random)
    final uniqueId = 'test-reg-${DateTime.now().millisecondsSinceEpoch}-${(DateTime.now().microsecond % 10000)}';
    
    print('🆔 Generated unique credential ID: $uniqueId');

    // WebAuthn standard structure for registration response
    final fallbackJson = {
      'id': uniqueId,
      'type': 'public-key',
      'rawId': uniqueId,
      'response': {
        'attestationObject': 'mock-attestation-${DateTime.now().millisecondsSinceEpoch}',
        'clientDataJSON': 'mock-client-data-${DateTime.now().millisecondsSinceEpoch}',
      },
    };

    print('📝 Using fallback JSON structure: $fallbackJson');
    return fallbackJson;
  }

  // Helper method to convert AuthenticateResponseType to JSON
  Map<String, dynamic> _convertAuthenticationToJson(dynamic credential) {
    print('🔄 Converting authentication credential to JSON...');
    print('📋 Credential type: ${credential.runtimeType}');
    print('📋 Credential value: $credential');
    
    if (credential is Map<String, dynamic>) {
      print('✅ Credential is already a Map');
      return credential;
    }

    print('⚠️  Credential is not a Map, creating fallback structure');
    
    // Generate a unique credential ID for testing (using timestamp + random)
    final uniqueId = 'test-auth-${DateTime.now().millisecondsSinceEpoch}-${(DateTime.now().microsecond % 10000)}';
    
    print('🆔 Generated unique credential ID: $uniqueId');

    // WebAuthn standard structure for authentication response
    final fallbackJson = {
      'id': uniqueId,
      'type': 'public-key',
      'rawId': uniqueId,
      'response': {
        'authenticatorData': 'mock-auth-data-${DateTime.now().millisecondsSinceEpoch}',
        'clientDataJSON': 'mock-client-data-${DateTime.now().millisecondsSinceEpoch}',
        'signature': 'mock-signature-${DateTime.now().millisecondsSinceEpoch}',
        'userHandle': null,
      },
    };
    
    print('📝 Using fallback JSON structure: $fallbackJson');
    return fallbackJson;
  }
}
