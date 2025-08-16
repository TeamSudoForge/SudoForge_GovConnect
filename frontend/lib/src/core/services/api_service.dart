import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'dart:io';

class ApiService {
  static String get baseUrl {
    // When running on Android emulator, localhost needs to be changed to 10.0.2.2
    if (Platform.isAndroid) {
      // if using Android emulator
      return 'http://10.0.2.2:3000';
      // if using real Android device
      // return "http://192.168.142.69:3000";
    }
    // For iOS simulator or physical devices, you might need to use your machine's IP address
    return 'http://localhost:3000';
  }

  late final Dio _dio;

  // Getter for dio instance (needed by ChatService)
  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors for logging and token management
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[API] $object'),
      ),
    );
  }

  // Add auth token to requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove auth token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Auth endpoints
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> verify2FA(Verify2FARequest request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-2fa',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> verifyEmail(VerifyEmailRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-email',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> resendEmailVerificationCode(
    ResendVerificationCodeRequest request,
  ) async {
    try {
      await _dio.post('/auth/resend-verification-code', data: request.toJson());
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post('/auth/refresh', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> enable2FA() async {
    try {
      await _dio.post('/auth/enable-2fa');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> disable2FA() async {
    try {
      await _dio.post('/auth/disable-2fa');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Passkey endpoints
  Future<Map<String, dynamic>> beginPasskeyRegistration(
    String displayName,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/passkey/register/begin',
        data: {'displayName': displayName},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> completePasskeyRegistration(
    Map<String, dynamic> credential,
  ) async {
    try {
      await _dio.post('/auth/passkey/register/complete', data: credential);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> beginPasskeyAuthentication() async {
    try {
      final response = await _dio.post('/auth/passkey/authenticate/begin');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> completePasskeyAuthentication(
    Map<String, dynamic> credential,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/passkey/authenticate/complete',
        data: credential,
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUserPasskeys() async {
    try {
      final response = await _dio.get('/auth/passkeys');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deletePasskey(String passkeyId) async {
    try {
      await _dio.delete('/auth/passkeys/$passkeyId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Register FCM token for push notifications
  Future<void> registerFcmToken(String token) async {
    try {
      await _dio.post('/notifications/register-token', data: {'token': token});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Fetch notifications
  Future<List<NotificationDto>> fetchNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return (response.data as List)
          .map((n) => NotificationDto.fromJson(n))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String id) async {
    try {
      await _dio.post('/notifications/mark-read/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Server error: ${e.response!.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else {
      return 'Network error. Please check your connection.';
    }
  }
}

// Notification DTO
class NotificationDto {
  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  NotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      read: json['read'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
