// Dependency injection setup
import 'package:provider/provider.dart';
import 'core/app_export.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late final ApiService _apiService;
  late final StorageService _storageService;
  late final AuthService _authService;
  late final SettingsService _settingsService;
  late final NotificationService _notificationService;

  void init() {
    _apiService = ApiService();
    _storageService = StorageService();
    _settingsService = SettingsService();
    _authService = AuthService(
      apiService: _apiService,
      storageService: _storageService,
    );
    _notificationService = NotificationService();
  }

  // Getters
  ApiService get apiService => _apiService;
  StorageService get storageService => _storageService;
  AuthService get authService => _authService;
  SettingsService get settingsService => _settingsService;
  NotificationService get notificationService => _notificationService;
}

// Provider setup for the app
final providers = [
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => NotificationProvider()),
  ChangeNotifierProvider<AuthService>.value(
    value: ServiceLocator().authService,
  ),
  ChangeNotifierProvider<NotificationService>.value(
    value: ServiceLocator().notificationService,
  ),
  ChangeNotifierProvider<SettingsService>.value(
    value: ServiceLocator().settingsService,
  ),
];

// Initialize services
Future<void> initializeServices() async {
  ServiceLocator().init();
  await ServiceLocator().settingsService.initialize();
  await ServiceLocator().authService.initialize();

  // Inject AuthService into NotificationService
  ServiceLocator().notificationService.setAuthService(
    ServiceLocator().authService,
  );
}
