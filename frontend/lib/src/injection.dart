// Dependency injection setup
import 'package:provider/provider.dart';
import 'core/app_export.dart';
import 'core/providers/auth_provider.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late final ApiService _apiService;
  late final StorageService _storageService;
  late final AuthService _authService;

  void init() {
    _apiService = ApiService();
    _storageService = StorageService();
    _authService = AuthService(
      apiService: _apiService,
      storageService: _storageService,
    );
  }

  // Getters
  ApiService get apiService => _apiService;
  StorageService get storageService => _storageService;
  AuthService get authService => _authService;
}

// Provider setup for the app
final providers = [
  ChangeNotifierProvider(create: (_) => ServiceLocator()._authService),
  ChangeNotifierProvider(create: (_) => AuthProvider()),
];

// Initialize services
Future<void> initializeServices() async {
  ServiceLocator().init();
  await ServiceLocator().authService.initialize();
}
