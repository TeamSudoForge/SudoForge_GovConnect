import 'package:flutter/material.dart';
import '../../core/theme/text_style_helper.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';
import '../widgets/custom_button.dart';

class GovConnectSignInScreen extends StatefulWidget {
  const GovConnectSignInScreen({Key? key}) : super(key: key);

  @override
  State<GovConnectSignInScreen> createState() => _GovConnectSignInScreenState();
}

class _GovConnectSignInScreenState extends State<GovConnectSignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final styles = TextStyleHelper.instance;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              EmailField(
                controller: emailController,
                styles: styles,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: passwordController,
                styles: styles,
                isPasswordVisible: isPasswordVisible,
                onToggleVisibility: _togglePasswordVisibility,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Sign In',
                onPressed: () {
                  // TODO: Implement sign in logic
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
