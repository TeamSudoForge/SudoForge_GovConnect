import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/auth_models.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  UserProfile? get currentUser => _state.user;
  bool get isAuthenticated => _state.status == AuthStatus.authenticated;
  bool get isLoading => _state.isLoading;
  bool get requires2FA => _state.status == AuthStatus.requires2FA;

  AuthService({
    ApiService? apiService,
    StorageService? storageService,
  }) : 
    _apiService = apiService ?? ApiService(),
    _storageService = storageService ?? StorageService();

  // Initialize the auth service
  Future<void> initialize() async {
    _updateState(_state.copyWith(isLoading: true));
    
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      
      if (isLoggedIn) {
        final accessToken = await _storageService.getAccessToken();
        
        if (accessToken != null && !_isTokenExpired(accessToken)) {
          // Token is valid, set it in API service and get user profile
          _apiService.setAuthToken(accessToken);
          final user = await _storageService.getUserProfile();
          
          if (user != null) {
            _updateState(_state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              isLoading: false,
            ));
            return;
          }
        }
        
        // Try to refresh token
        final refreshToken = await _storageService.getRefreshToken();
        if (refreshToken != null) {
          await _refreshToken(refreshToken);
          return;
        }
      }
      
      // Not authenticated
      _updateState(_state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      ));
    } catch (e) {
      print('Auth initialization error: $e');
      _updateState(_state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      ));
    }
  }

  // Login with email and password
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      // Save remember me preference
      await _storageService.setRememberMe(rememberMe);

      if (response.requires2FA == true) {
        // 2FA is required
        _updateState(_state.copyWith(
          status: AuthStatus.requires2FA,
          email: response.email ?? email,
          isLoading: false,
        ));
      } else if (response.accessToken != null && response.refreshToken != null) {
        // Successful login
        await _handleSuccessfulAuth(response);
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  // Register new user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
      );
      
      final response = await _apiService.register(request);
      
      if (response.accessToken != null && response.refreshToken != null) {
        await _handleSuccessfulAuth(response);
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  // Verify 2FA code
  Future<void> verify2FA(String verificationCode) async {
    if (_state.email == null) {
      _updateState(_state.copyWith(
        status: AuthStatus.error,
        error: 'Email not found for 2FA verification',
        isLoading: false,
      ));
      return;
    }

    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final request = Verify2FARequest(
        email: _state.email!,
        verificationCode: verificationCode,
      );
      
      final response = await _apiService.verify2FA(request);
      
      if (response.accessToken != null && response.refreshToken != null) {
        await _handleSuccessfulAuth(response);
      } else {
        throw Exception('2FA verification failed');
      }
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  // Refresh access token
  Future<void> _refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiService.refreshToken(request);
      
      if (response.accessToken != null && response.refreshToken != null) {
        await _handleSuccessfulAuth(response);
      } else {
        await logout();
      }
    } catch (e) {
      print('Token refresh failed: $e');
      await logout();
    }
  }

  // Logout
  Future<void> logout() async {
    _updateState(_state.copyWith(isLoading: true));
    
    try {
      // Clear API token
      _apiService.clearAuthToken();
      
      // Clear stored data
      await _storageService.clearAll();
      
      _updateState(const AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      ));
    } catch (e) {
      print('Logout error: $e');
      _updateState(const AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      ));
    }
  }

  // Handle successful authentication
  Future<void> _handleSuccessfulAuth(AuthResponse response) async {
    try {
      // Save tokens
      await _storageService.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
      );

      // Set token in API service
      _apiService.setAuthToken(response.accessToken!);

      UserProfile? user = response.user;
      
      // If user profile not in response, fetch it
      if (user == null) {
        user = await _apiService.getProfile();
      }

      // Save user profile
      await _storageService.saveUserProfile(user);

      _updateState(_state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      print('Error handling successful auth: $e');
      _updateState(_state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to complete authentication',
        isLoading: false,
      ));
    }
  }

  // Check if JWT token is expired
  bool _isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true; // Consider token expired if we can't decode it
    }
  }

  // Update state and notify listeners
  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    if (_state.error != null) {
      _updateState(_state.copyWith(error: null));
    }
  }

  // Enable 2FA
  Future<void> enable2FA() async {
    try {
      await _apiService.enable2FA();
    } catch (e) {
      throw Exception('Failed to enable 2FA: $e');
    }
  }

  // Disable 2FA
  Future<void> disable2FA() async {
    try {
      await _apiService.disable2FA();
    } catch (e) {
      throw Exception('Failed to disable 2FA: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
