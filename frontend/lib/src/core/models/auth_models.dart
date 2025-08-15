// Authentication models for API requests and responses

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
    };
  }
}

class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final UserProfile? user;
  final bool? requires2FA;
  final bool? requiresEmailVerification;
  final String? email;
  final String? message;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.requires2FA,
    this.requiresEmailVerification,
    this.email,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      requires2FA: json['requires2FA'] as bool?,
      requiresEmailVerification: json['requiresEmailVerification'] as bool?,
      email: json['email'] as String?,
      message: json['message'] as String?,
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String role;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    };
  }
}

class Verify2FARequest {
  final String email;
  final String verificationCode;

  Verify2FARequest({
    required this.email,
    required this.verificationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'verificationCode': verificationCode,
    };
  }
}

class VerifyEmailRequest {
  final String email;
  final String verificationCode;

  VerifyEmailRequest({
    required this.email,
    required this.verificationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'verificationCode': verificationCode,
    };
  }
}

class ResendVerificationCodeRequest {
  final String email;

  ResendVerificationCodeRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  requires2FA,
  requiresEmailVerification,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? error;
  final String? email;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.email,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? error,
    String? email,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
