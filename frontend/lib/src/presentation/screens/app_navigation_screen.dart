import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/text_style_helper.dart';

class AppNavigationScreen extends StatelessWidget {
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
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                title: Text(
                  "Sign In",
                  style: styles.body14Regular,
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.govConnectSignInScreen);
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                title: Text(
                  "Email Verification",
                  style: styles.body14Regular,
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.emailVerificationScreen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
