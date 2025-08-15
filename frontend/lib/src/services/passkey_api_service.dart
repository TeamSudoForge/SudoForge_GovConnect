import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gov_connect/src/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

class PasskeyApiService {
  final String baseUrl = 'http://10.0.2.2:3000';
  final PasskeyAuthenticator _passkeyAuthenticator;
  final AuthService _authService;

  PasskeyApiService(this._authService)
      : _passkeyAuthenticator = PasskeyAuthenticator();

  Future<void> addPasskey() async {
  try {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    // 1. Get registration options from backend
    final regOptionsResponse = await http.get(
      Uri.parse('$baseUrl/auth/passkey/register/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (regOptionsResponse.statusCode != 200 &&
        regOptionsResponse.statusCode != 201) {
      throw Exception(
        'Failed to get registration options: ${regOptionsResponse.body}',
      );
    }

    final optionsJson = jsonDecode(regOptionsResponse.body);

    // 2. Map backend JSON to RegisterRequestType
    final regRequest = RegisterRequestType(
      relyingParty: RelyingPartyType(
        id: optionsJson['rp']['id'],
        name: optionsJson['rp']['name'],
      ),
      user: UserType(
        id: optionsJson['user']['id'],
        name: optionsJson['user']['name'],
        displayName: optionsJson['user']['displayName'],
      ),
      challenge: optionsJson['challenge'],
      pubKeyCredParams: (optionsJson['pubKeyCredParams'] as List<dynamic>)
          .map((param) => PubKeyCredParamType(
                type: param['type'],
                alg: param['alg'],
              ))
          .toList(),
      timeout: optionsJson['timeout'],
      attestation: optionsJson['attestation'],
      excludeCredentials: optionsJson['excludeCredentials'] != null
          ? (optionsJson['excludeCredentials'] as List<dynamic>)
              .map((cred) => CredentialType(
                    id: cred['id'],
                    type: cred['type'],
                    transports: cred['transports'],
                  ))
              .toList()
          : [],
          authSelectionType: optionsJson['authSelectionType'],
    );

    // 3. Call the passkeys API
    final passkeyResponse = await _passkeyAuthenticator.register(regRequest);

    // 4. Send registration response to backend
    final finishRegResponse = await http.post(
      Uri.parse('$baseUrl/auth/passkey/register/finish'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: passkeyResponse,
    );

    if (finishRegResponse.statusCode != 201) {
      throw Exception(
        'Failed to finish passkey registration: ${finishRegResponse.body}',
      );
    }

    debugPrint('Passkey added successfully!');
  } catch (e) {
    debugPrint('Error adding passkey: $e');
    rethrow;
  }
}


Future<String> loginWithPasskey(String username) async {
  try {
    // 1. Get authentication options from backend
    final authOptionsResponse = await http.post(
      Uri.parse('$baseUrl/auth/passkey/authenticate/start'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    if (authOptionsResponse.statusCode != 201) {
      throw Exception(
        'Failed to get authentication options: ${authOptionsResponse.body}',
      );
    }

    final optionsJson = jsonDecode(authOptionsResponse.body);

    // 2. Convert backend JSON to AuthenticateRequestType
    final authRequest = AuthenticateRequestType(
      relyingPartyId: optionsJson['relyingPartyId'],
      challenge: optionsJson['challenge'],
      timeout: optionsJson['timeout'],
      userVerification: optionsJson['userVerification'],
      allowCredentials: (optionsJson['allowCredentials'] as List<dynamic>?)
          ?.map((cred) => CredentialType(
                id: cred['id'],
                type: cred['type'],
                transports: cred['transports'],
              ))
          .toList(),
      mediation: MediationType.values.firstWhere(
        (m) => m.name == optionsJson['mediation'],
        orElse: () => MediationType.Optional,
      ),
      preferImmediatelyAvailableCredentials:
          optionsJson['preferImmediatelyAvailableCredentials'] ?? false,
    );

    // 3. Authenticate
    final passkeyResponse =
        await _passkeyAuthenticator.authenticate(authRequest);

    // 4. Finish authentication
    final finishAuthResponse = await http.post(
      Uri.parse('$baseUrl/auth/passkey/authenticate/finish'),
      headers: {'Content-Type': 'application/json'},
      body: passkeyResponse,
    );

    if (finishAuthResponse.statusCode != 200 &&
        finishAuthResponse.statusCode != 201) {
      throw Exception(
        'Failed to finish passkey authentication: ${finishAuthResponse.body}',
      );
    }

    final responseBody = jsonDecode(finishAuthResponse.body);
    final token = responseBody['token'];

    if (token == null) {
      throw Exception('Authentication successful, but no token received.');
    }

    await _authService.setToken(token);
    return token;
  } catch (e) {
    debugPrint('Error logging in with passkey: $e');
    rethrow;
  }
}

}


