// Dependency injection setup
import 'package:provider/provider.dart';
import 'core/app_export.dart';
import 'core/services/chat_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late final ApiService _apiService;
  late final StorageService _storageService;
  late final AuthService _authService;
  late final ChatService _chatService;

  void init() {
    _apiService = ApiService();
    _storageService = StorageService();
    _authService = AuthService(
      apiService: _apiService,
      storageService: _storageService,
    );
    _chatService = ChatService(_apiService, _authService);
  }

  // Getters
  ApiService get apiService => _apiService;
  StorageService get storageService => _storageService;
  AuthService get authService => _authService;
  ChatService get chatService => _chatService;
}

// Provider setup for the app
List<ChangeNotifierProvider> get providers => [
  ChangeNotifierProvider<AuthService>.value(
    value: ServiceLocator().authService,
  ),
];

// Initialize services
Future<void> initializeServices() async {
  ServiceLocator().init();
  await ServiceLocator().authService.initialize();
}

