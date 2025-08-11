import 'package:flutter/material.dart';
import '../../core/theme/theme_config.dart';
import '../../core/utils/text_style_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool isSignInSelected = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _toggleSignInSignUp(bool signIn) {
    setState(() {
      isSignInSelected = signIn;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _toggleRememberMe() {
    setState(() {
      rememberMe = !rememberMe;
    });
  }

  void _login() {
    // TODO: Call domain usecase for login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging in...')),
    );
  }

  void _signup() {
    // TODO: Call domain usecase for signup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signing up...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Scaffold(
      backgroundColor: AppColors.whiteCustom,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                const SizedBox(height: 56),
                // Government Icon (removed image)
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.colorFF0062,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: SizedBox.shrink(), // No image
                  ),
                ),
                _buildWelcomeHeader(styles),
                _buildSignInSignUpToggle(styles),
                isSignInSelected
                    ? _buildLoginForm(styles)
                    : _buildSignupForm(styles),
                _buildSecurityInformation(styles),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(TextStyleHelper styles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Text(
            'Welcome to GovConnect',
            textAlign: TextAlign.center,
            style: styles.headline24Regular.copyWith(height: 1.25),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Your secure gateway to government services. Access all your municipal services, pay bills, and connect with local officials in one convenient platform.',
              textAlign: TextAlign.center,
              style: styles.body14Regular.copyWith(
                color: AppColors.colorFF3838,
                height: 1.64,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInSignUpToggle(TextStyleHelper styles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.whiteCustom,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorFF0845.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isSignInSelected
                    ? AppColors.colorFF007B
                    : AppColors.transparentCustom,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSignInSelected
                    ? [
                        BoxShadow(
                          color: AppColors.blackCustom.withAlpha(255),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: TextButton(
                onPressed: () => _toggleSignInSignUp(true),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: styles.body14Regular.copyWith(
                    color: isSignInSelected
                        ? AppColors.whiteCustom
                        : AppColors.colorFF5252,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => _toggleSignInSignUp(false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Sign Up',
                style: styles.body14Regular
                    .copyWith(color: AppColors.colorFF5252),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(TextStyleHelper styles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          EmailField(controller: emailController, styles: styles),
          const SizedBox(height: 16),
          PasswordField(
            controller: passwordController,
            styles: styles,
            isPasswordVisible: isPasswordVisible,
            onToggleVisibility: _togglePasswordVisibility,
          ),
          const SizedBox(height: 16),
          _buildRememberMeForgotPassword(styles),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Sign In',
            onPressed: _login,
            isFullWidth: true,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(TextStyleHelper styles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          EmailField(controller: emailController, styles: styles),
          const SizedBox(height: 16),
          PasswordField(
            controller: passwordController,
            styles: styles,
            isPasswordVisible: isPasswordVisible,
            onToggleVisibility: _togglePasswordVisibility,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Sign Up',
            onPressed: _signup,
            isFullWidth: true,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMeForgotPassword(TextStyleHelper styles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _toggleRememberMe,
              child: Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.colorFFD4D4),
                  borderRadius: BorderRadius.circular(2),
                  color: rememberMe ? AppColors.colorFF007B : AppColors.whiteCustom,
                ),
                child: rememberMe
                    ? Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.whiteCustom,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: styles.body14Regular
                  .copyWith(color: AppColors.colorFF5252, height: 1.21),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // TODO: Handle forgot password
          },
          child: Text(
            'Forgot password?',
            style: styles.body14Regular
                .copyWith(color: AppColors.colorFF007B, height: 1.21),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityInformation(TextStyleHelper styles) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorFFF3F4,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Icon (removed image)
          const SizedBox(
            height: 16,
            width: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Access',
                  style: styles.body14Medium.copyWith(height: 1.21),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your data is protected with bank-level encryption and multi-factor authentication for maximum security.',
                  textAlign: TextAlign.justify,
                  style: styles.body12Regular.copyWith(height: 1.17),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

