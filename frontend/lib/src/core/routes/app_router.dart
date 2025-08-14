import 'package:go_router/go_router.dart';
import '../../core/app_export.dart';
import '../../core/models/appointment_models.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/email_verification_screen.dart';
import '../../presentation/screens/two_factor_verification_screen.dart';
import '../../presentation/screens/app_navigation_screen.dart';
import '../../presentation/screens/appointment_details.dart';
import '../../presentation/screens/appointment_update_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/settings_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: authService,
      redirect: (context, state) {
        final authStatus = authService.state.status;
        final isLoggedIn = authStatus == AuthStatus.authenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        final isOnAuth =
            isLoggingIn ||
            state.matchedLocation == '/email-verification' ||
            state.matchedLocation == '/two-factor-verification';

        // Redirect to login if not authenticated and not on auth screens
        if (!isLoggedIn && !isOnAuth) {
          return '/login';
        }

        // Redirect to home if authenticated and on auth screens
        if (isLoggedIn && isOnAuth) {
          return '/home';
        }

        // Handle 2FA requirement
        if (authStatus == AuthStatus.requires2FA &&
            state.matchedLocation != '/two-factor-verification') {
          return '/two-factor-verification';
        }

        return null; // No redirect needed
      },
      routes: [
        // Authentication Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/email-verification',
          name: 'email-verification',
          builder: (context, state) => const EmailVerificationScreen(),
        ),
        GoRoute(
          path: '/two-factor-verification',
          name: 'two-factor-verification',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return TwoFactorVerificationScreen(email: email);
          },
        ),

        // Main App Routes
        GoRoute(path: '/', name: 'root', redirect: (context, state) => '/home'),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            // Nested routes under home
            GoRoute(
              path: 'notifications',
              name: 'notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
            GoRoute(
              path: 'settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'app-navigation',
              name: 'app-navigation',
              builder: (context, state) => const AppNavigationScreen(),
            ),
          ],
        ),

        GoRoute(
          path: '/appointment-details',
          name: 'appointment-details',
          builder: (context, state) => const AppointmentDetailsScreen(),
        ),
        GoRoute(
          path: '/appointment-update',
          name: 'appointment-update',
          builder: (context, state) {
            // Use the sample appointment for now - in practice, you'd pass the actual appointment data
            return AppointmentUpdateScreen(appointment: sampleAppointment);
          },
        ),
      ],
    );
  }
}

// Route names for type-safe navigation
class AppRoutes {
  static const String login = '/login';
  static const String emailVerification = '/email-verification';
  static const String twoFactorVerification = '/two-factor-verification';
  static const String home = '/home';
  static const String notifications = '/home/notifications';
  static const String settings = '/home/settings';
  static const String appNavigation = '/home/app-navigation';
  // static const String idCardRenewal = '/id-card-renewal'; // TODO: Uncomment when screen is created
  static const String appointmentDetails = '/appointment-details';
  static const String appointmentUpdate = '/appointment-update';
}

// Extension for type-safe navigation
extension GoRouterExtension on GoRouter {
  void pushLogin() => pushNamed('login');

  void pushHome() => pushNamed('home');

  void pushNotifications() => pushNamed('notifications');

  void pushSettings() => pushNamed('settings');

  void pushAppointmentDetails() => pushNamed('appointment-details');

  void pushTwoFactorVerification(String email) =>
      pushNamed('two-factor-verification', queryParameters: {'email': email});

  void pushAppointmentUpdate(String appointmentId) => pushNamed(
    'appointment-update',
    pathParameters: {'appointmentId': appointmentId},
  );
}
