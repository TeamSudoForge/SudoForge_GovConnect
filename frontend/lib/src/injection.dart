// Dependency injection setup
import 'package:provider/provider.dart';
import 'core/app_export.dart';
import 'core/providers/auth_provider.dart';
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

  void init() {
    _apiService = ApiService();
    _storageService = StorageService();
    _settingsService = SettingsService();
    _authService = AuthService(
      apiService: _apiService,
      storageService: _storageService,
    );
  }

  // Getters
  ApiService get apiService => _apiService;
  StorageService get storageService => _storageService;
  AuthService get authService => _authService;
  SettingsService get settingsService => _settingsService;
}

// Provider setup for the app
final providers = [
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider<AuthService>.value(
    value: ServiceLocator().authService,
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
}
