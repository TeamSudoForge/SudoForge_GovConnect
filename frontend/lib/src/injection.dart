// Dependency injection setup
import 'package:provider/provider.dart';
import 'core/app_export.dart';
import 'core/services/chat_service.dart';
import 'core/services/appointment_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/onboarding_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late final ApiService _apiService;
  late final StorageService _storageService;
  late final AuthService _authService;
  late final ChatService _chatService;
  late final SettingsService _settingsService;
  late final NotificationService _notificationService;
  late final AppointmentService _appointmentService;
  late final DepartmentsService _departmentsService;

  void init() {
    _apiService = ApiService();
    _storageService = StorageService();
    _settingsService = SettingsService();
    _authService = AuthService(
      apiService: _apiService,
      storageService: _storageService,
    );
    _notificationService = NotificationService();
    _chatService = ChatService(_apiService, _authService);
    _appointmentService = AppointmentService();
    _departmentsService = DepartmentsService();
  }

  // Getters
  ApiService get apiService => _apiService;
  StorageService get storageService => _storageService;
  AuthService get authService => _authService;
  ChatService get chatService => _chatService;
  SettingsService get settingsService => _settingsService;
  NotificationService get notificationService => _notificationService;
  AppointmentService get appointmentService => _appointmentService;
  DepartmentsService get departmentsService => _departmentsService;
}

// Provider setup for the app
final providers = [
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  // The NotificationProvider needs to be properly initialized with the singleton ServiceLocator
  ChangeNotifierProvider<NotificationProvider>(
    create: (_) => NotificationProvider(),
  ),
  ChangeNotifierProvider<AuthService>.value(
    value: ServiceLocator().authService,
  ),
  ChangeNotifierProvider<NotificationService>.value(
    value: ServiceLocator().notificationService,
  ),
  ChangeNotifierProvider<SettingsService>.value(
    value: ServiceLocator().settingsService,
  ),
  ChangeNotifierProvider<AppointmentService>.value(
    value: ServiceLocator().appointmentService,
  ),
  ChangeNotifierProvider<DepartmentsService>.value(
    value: ServiceLocator().departmentsService,
  ),
];

// Initialize services
Future<void> initializeServices() async {
  ServiceLocator().init();
  await ServiceLocator().settingsService.initialize();
  await ServiceLocator().authService.initialize();
  await ServiceLocator().departmentsService.initialize();
  await OnboardingService.instance.initialize();

  // Inject AuthService into NotificationService
  ServiceLocator().notificationService.setAuthService(
    ServiceLocator().authService,
  );
}
