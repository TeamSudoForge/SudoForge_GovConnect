class ApiConfig {
  // Base URL for the API - update this to match your backend URL
  static const String baseUrl = 'http://10.0.2.2:3000'; // Removed /api
  // static const String baseUrl = 'http://192.168.1.138:3000'; // Removed /api

  // Authentication endpoints
  static const String authEndpoint = '/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String refreshTokenEndpoint = '$authEndpoint/refresh';
  static const String verifyEmailEndpoint = '$authEndpoint/verify-email';
  static const String resendVerificationEndpoint =
      '$authEndpoint/resend-verification-code';
  static const String twoFactorEndpoint = '$authEndpoint/verify-2fa';
  static const String profileEndpoint = '$authEndpoint/profile';

  // Passkey endpoints
  static const String passkeyRegisterBeginEndpoint =
      '$authEndpoint/passkey/register/begin';
  static const String passkeyRegisterCompleteEndpoint =
      '$authEndpoint/passkey/register/complete';
  static const String passkeyAuthBeginEndpoint =
      '$authEndpoint/passkey/authenticate/begin';
  static const String passkeyAuthCompleteEndpoint =
      '$authEndpoint/passkey/authenticate/complete';
  static const String passkeysEndpoint = '$authEndpoint/passkeys';

  // Forms endpoints
  static const String formsEndpoint = '/forms';
  static const String fieldTypesEndpoint = '$formsEndpoint/field-types';
  static const String fieldsEndpoint = '$formsEndpoint/fields';

  // Analytics endpoints
  static const String analyticsEndpoint = '/analytics';
  static const String overviewAnalyticsEndpoint = '$analyticsEndpoint/overview';

  // Request timeout in seconds
  static const int requestTimeoutSeconds = 30;

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get authorization header with token
  static Map<String, String> getAuthHeaders(String token) {
    return {...defaultHeaders, 'Authorization': 'Bearer $token'};
  }
}
