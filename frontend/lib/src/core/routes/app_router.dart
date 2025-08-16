import 'package:go_router/go_router.dart';
import '../../core/app_export.dart';
import '../../core/models/appointment_models.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/email_verification_screen.dart';
import '../../presentation/screens/two_factor_verification_screen.dart';
import '../../presentation/screens/app_navigation_screen.dart';
import '../../presentation/screens/appointments_screen.dart';
import '../../presentation/screens/appointment_details.dart';
import '../../presentation/screens/appointment_update_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/add_passkey_screen.dart';
import '../../presentation/screens/services_screen.dart';
import '../../presentation/screens/all_services_screen.dart';
import '../../presentation/screens/forms/id_recovery_process_screen.dart';
import '../../presentation/screens/forms/id_recovery_form_content_screen.dart';
import '../../presentation/screens/forms/id_recovery_success_screen.dart';
import '../../presentation/screens/forms/demo_form_screen.dart';
import '../../presentation/screens/forms/form_selection_screen.dart';

class AppRouter {
  // Session-based flag to track if splash has been shown
  // This ensures splash is only shown once per app session
  static bool _hasShownSplash = false;

  static void markSplashAsShown() {
    _hasShownSplash = true;
  }

  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: authService,
      redirect: (context, state) {
        final authStatus = authService.state.status;
        final isLoggedIn = authStatus == AuthStatus.authenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        final isOnSplash = state.matchedLocation == '/splash';
        final isOnAuth =
            isLoggingIn ||
            state.matchedLocation == '/email-verification' ||
            state.matchedLocation == '/two-factor-verification';

        // Show splash only on first app launch (during this session)
        // This ensures splash is only shown when app starts, not during login/logout flows
        if (isOnSplash && !_hasShownSplash) {
          return null; // Allow splash to show
        }

        // Skip splash if already shown and redirect based on auth status
        if (isOnSplash && _hasShownSplash) {
          if (isLoggedIn) {
            return '/home';
          } else if (authStatus == AuthStatus.requires2FA) {
            return '/two-factor-verification';
          } else {
            return '/login';
          }
        }

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
        // Splash Screen Route
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => SplashScreen(),
        ),

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
              path: 'add-passkey',
              name: 'add-passkey',
              builder: (context, state) => const AddPasskeyScreen(),
            ),
            GoRoute(
              path: 'form-selection',
              name: 'form-selection',
              builder: (context, state) => const FormSelectionScreen(),
            ),
            GoRoute(
              path: 'demo-form',
              name: 'demo-form',
              builder: (context, state) {
                final formId = state.uri.queryParameters['formId'];
                return DemoFormScreen(formId: formId);
              },
            ),
            GoRoute(
              path: 'id-recovery-process',
              name: 'id-recovery-process',
              builder: (context, state) => const IdRecoveryProcessScreen(),
              routes: [
                GoRoute(
                  path: 'form-content',
                  name: 'id-recovery-form-content',
                  builder: (context, state) => const IdRecoveryFormContentScreen(),
                ),
                GoRoute(
                  path: 'success',
                  name: 'id-recovery-success',
                  builder: (context, state) => const IdRecoverySuccessScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'app-navigation',
              name: 'app-navigation',
              builder: (context, state) => const AppNavigationScreen(),
            ),
          ],
        ),

        // Service Routes
        GoRoute(
          path: '/services',
          name: 'services',
          builder: (context, state) => const ServicesScreen(),
        ),
        GoRoute(
          path: '/all-services',
          name: 'all-services',
          builder: (context, state) => const AllServicesScreen(),
        ),

        // Appointment Routes
        GoRoute(
          path: '/appointments',
          name: 'appointments',
          builder: (context, state) => const AppointmentsScreen(),
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
  static const String splash = '/splash';
  static const String login = '/login';
  static const String emailVerification = '/email-verification';
  static const String twoFactorVerification = '/two-factor-verification';
  static const String home = '/home';
  static const String notifications = '/home/notifications';
  static const String settings = '/home/settings';
  static const String addPasskey = '/home/add-passkey';
  static const String demoForm = '/home/demo-form';
  static const String appNavigation = '/home/app-navigation';
  static const String services = '/services';
  static const String allServices = '/all-services';
  static const String appointments = '/appointments';
  // static const String idCardRenewal = '/id-card-renewal'; // TODO: Uncomment when screen is created
  static const String appointmentDetails = '/appointment-details';
  static const String appointmentUpdate = '/appointment-update';
}

// Extension for type-safe navigation
extension GoRouterExtension on GoRouter {
  void pushSplash() => pushNamed('splash');

  void pushLogin() => pushNamed('login');

  void pushHome() => pushNamed('home');

  void pushNotifications() => pushNamed('notifications');

  void pushSettings() => pushNamed('settings');

  void pushAddPasskey() => pushNamed('add-passkey');

  void pushFormSelection() => pushNamed('form-selection');

  void pushDemoForm([String? formId]) {
    if (formId != null) {
      pushNamed('demo-form', queryParameters: {'formId': formId});
    } else {
      pushNamed('demo-form');
    }
  }

  void pushAppointmentDetails() => pushNamed('appointment-details');



  void pushTwoFactorVerification(String email) =>
      pushNamed('two-factor-verification', queryParameters: {'email': email});

  void pushAppointmentUpdate(String appointmentId) => pushNamed(
    'appointment-update',
    pathParameters: {'appointmentId': appointmentId},
  );
}
