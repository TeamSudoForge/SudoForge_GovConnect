import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/app_export.dart';

// Example JSON list of routes
const List<Map<String, String>> navigationRoutes = [
  {"name": "Sign In", "route": AppRoutes.govConnectSignInScreen},
  {"name": "Email Verification", "route": AppRoutes.emailVerificationScreen},
  {"name": "Home", "route": AppRoutes.initialRoute},
  // Add more routes here as needed
];

class AppNavigationScreen extends StatelessWidget {
  static const String routeName = '/appNavigation';

  const AppNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Routes',
          style: styles.title20,
        ),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          itemCount: navigationRoutes.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
          itemBuilder: (context, index) {
            final routeItem = navigationRoutes[index];
            return ListTile(
              title: Text(
                routeItem['name'] ?? '',
                style: styles.body14Regular,
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 20),
              onTap: () {
                final routePath = routeItem['route'];
                if (routePath != null && routePath.isNotEmpty) {
                  Navigator.pushNamed(context, routePath);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
