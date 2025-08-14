import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gov_connect/src/core/app_export.dart';
import 'src/core/theme/theme_config.dart';
import 'src/injection.dart';
import 'src/core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initializeServices();

  runApp(const GovConnectApp());
}

class GovConnectApp extends StatelessWidget {
  const GovConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer2<AuthService, SettingsService>(
        builder: (context, authService, settingsService, child) {
          final fontScale = settingsService.currentFontScale;
          final router = AppRouter.createRouter(authService);

          return MaterialApp.router(
            title: 'GovConnect',
            theme: AppTheme.lightTheme(fontScale),
            darkTheme: AppTheme.darkTheme(fontScale),
            themeMode: settingsService.settings.materialThemeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
