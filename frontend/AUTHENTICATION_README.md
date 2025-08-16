# GovConnect Frontend Authentication

This document describes the authentication implementation for the GovConnect Flutter frontend application.

## Architecture

The authentication system follows a clean architecture pattern with the following components:

### Models (`lib/src/core/models/auth_models.dart`)

- `LoginRequest` - Login request payload
- `RegisterRequest` - Registration request payload
- `AuthResponse` - Authentication response from API
- `UserProfile` - User profile data
- `Verify2FARequest` - Two-factor authentication verification
- `VerifyEmailRequest` - Email verification request
- `ResendVerificationCodeRequest` - Resend verification code request
- `RefreshTokenRequest` - Token refresh request
- `AuthState` - Application authentication state
- `AuthStatus` - Authentication status enumeration

### Services

#### API Service (`lib/src/core/services/api_service.dart`)

- Handles all HTTP requests to the backend
- Manages authentication tokens
- Provides endpoints for:
  - Login/Register
  - Email verification
  - Two-factor authentication
  - Token refresh
  - User profile management
  - Passkey authentication

#### Storage Service (`lib/src/core/services/storage_service.dart`)

- Manages secure token storage using `flutter_secure_storage`
- Handles user preferences with `shared_preferences`
- Provides methods for:
  - Token management (access/refresh tokens)
  - User profile persistence
  - App preferences (remember me, first launch, etc.)

#### Authentication Service (`lib/src/core/services/auth_service.dart`)

- Main authentication logic using `ChangeNotifier` for state management
- Handles authentication flow including:
  - Login with email/password
  - User registration
  - Email verification
  - Two-factor authentication
  - Automatic token refresh
  - Session management
  - Logout

### UI Components

#### Login Screen (`lib/src/presentation/screens/login_screen.dart`)

- Combined login and registration interface
- Form validation
- Integration with AuthService
- Handles navigation based on authentication state

#### Two-Factor Verification Screen (`lib/src/presentation/screens/two_factor_verification_screen.dart`)

- 6-digit code input interface
- Code verification with backend
- Resend functionality

#### Email Verification Screen (`lib/src/presentation/screens/email_verification_screen.dart`)
- Dual-purpose verification interface for both email verification and 2FA
- 6-digit code input with auto-focus progression
- Resend functionality with 45-second delay
- Context-aware UI (different titles and descriptions based on verification type)

#### Home Screen (`lib/src/presentation/screens/home_screen.dart`)

- Dashboard for authenticated users
- User profile display
- Quick actions for government services
- Logout functionality

## Dependencies

```yaml
dependencies:
  # HTTP client
  dio: ^5.7.0

  # Storage
  shared_preferences: ^2.3.2
  flutter_secure_storage: ^9.2.2

  # State management
  provider: ^6.1.2

  # JWT utilities
  jwt_decoder: ^2.0.1
```

## Usage

### Initialize the app

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices();
  runApp(const GovConnectApp());
}
```

### Use authentication in widgets

```dart
Consumer<AuthService>(
  builder: (context, authService, child) {
    if (authService.isAuthenticated) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  },
)
```

### Perform login

```dart
context.read<AuthService>().login(
  email: email,
  password: password,
  rememberMe: rememberMe,
);
```

## Authentication Flow

1. **Initial Load**: App checks for stored tokens and validates them
2. **Registration**: User registers → Email verification required → User verifies email → Authenticated
3. **Login**: User enters credentials → API validates → Check email verification → Check 2FA → Tokens stored → User authenticated
4. **Email Verification**: If email not verified, user must verify before proceeding
5. **2FA**: If enabled and email verified, user must verify code before completing login
6. **Auto-refresh**: Expired access tokens are automatically refreshed using refresh token
7. **Logout**: All tokens and user data are cleared

## Security Features

- Secure token storage using platform keychain/keystore
- Automatic token refresh
- JWT token validation
- Email verification for new accounts
- Two-factor authentication support
- 45-second delay between verification code resends
- Session timeout handling
- Secure HTTP requests with proper headers

## API Endpoints

The frontend communicates with the following backend endpoints:

- `POST /auth/login` - User login
- `POST /auth/register` - User registration  
- `POST /auth/verify-email` - Verify email address with code
- `POST /auth/resend-verification-code` - Resend email verification code
- `POST /auth/verify-2fa` - Verify 2FA code
- `POST /auth/refresh` - Refresh access token
- `GET /auth/profile` - Get user profile
- `POST /auth/enable-2fa` - Enable 2FA
- `POST /auth/disable-2fa` - Disable 2FA

## Configuration

Update the API base URL in `lib/src/core/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:3000'; // Change to your backend URL
```

## Error Handling

- Network errors are handled gracefully with user-friendly messages
- Form validation prevents invalid submissions
- Loading states provide visual feedback
- Error messages are displayed via SnackBars
- Authentication errors trigger appropriate redirects
