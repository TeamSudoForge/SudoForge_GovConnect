import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';
import '../widgets/custom_button.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';
import 'two_factor_verification_screen.dart';

// --- Add FirstNameField, LastNameField, ConfirmPasswordField widgets inline for now ---
class FirstNameField extends StatelessWidget {
  final TextEditingController controller;
  final TextStyleHelper styles;
  static const String routeName = '/signInSignUpPage';
  const FirstNameField({Key? key, required this.controller, required this.styles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('First Name', style: styles.body14Regular.copyWith(color: AppColors.colorFF4040, height: 1.21)),
        const SizedBox(height: 8),
        Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.colorFFD4D4),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.whiteCustom,
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your first name',
              hintStyle: styles.body14Regular.copyWith(color: AppColors.colorFFADAE),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            style: styles.body14Regular.copyWith(color: AppColors.colorFFADAE),
          ),
        ),
      ],
    );
  }
}

class LastNameField extends StatelessWidget {
  final TextEditingController controller;
  final TextStyleHelper styles;
  const LastNameField({Key? key, required this.controller, required this.styles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last Name', style: styles.body14Regular.copyWith(color: AppColors.colorFF4040, height: 1.21)),
        const SizedBox(height: 8),
        Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.colorFFD4D4),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.whiteCustom,
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your last name',
              hintStyle: styles.body14Regular.copyWith(color: AppColors.colorFFADAE),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            style: styles.body14Regular.copyWith(color: AppColors.colorFFADAE),
          ),
        ),
      ],
    );
  }
}

class ConfirmPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final TextStyleHelper styles;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;

  const ConfirmPasswordField({
    Key? key,
    required this.controller,
    required this.styles,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Password', style: styles.body14Regular.copyWith(color: AppColors.colorFF4040, height: 1.21)),
        const SizedBox(height: 8),
        Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.colorFFD4D4),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.whiteCustom,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Re-enter your password',
              hintStyle: styles.body14Regular.copyWith(color: AppColors.colorFFADAE),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.colorFFADAE,
                ),
              ),
              border: InputBorder.none,
            ),
            style: styles.body14Regular.copyWith(color: AppColors.colorFFADAE),
          ),
        ),
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool rememberMe = false;
  bool isSignInSelected = true;
  bool signUpStepOne = true; // true: name/email, false: password step

  // Add error handling flag
  String? _lastError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void _toggleSignInSignUp(bool signIn) {
    setState(() {
      isSignInSelected = signIn;
      signUpStepOne = true;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      isConfirmPasswordVisible = !isConfirmPasswordVisible;
    });
  }

  void _toggleRememberMe() {
    setState(() {
      rememberMe = !rememberMe;
    });
  }

  void _login() {
    // Basic validation
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    context.read<AuthService>().login(
      email: emailController.text.trim(),
      password: passwordController.text,
      rememberMe: rememberMe,
    );
  }

  void _signup() {
    if (signUpStepOne) {
      // Validate step one fields
      if (firstNameController.text.trim().isEmpty || 
          lastNameController.text.trim().isEmpty || 
          emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      // Email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address')),
        );
        return;
      }

      // Proceed to next step
      _nextSignUpStep();
    } else {
      // Validate step two fields
      if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      // Password strength validation
      if (passwordController.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 8 characters long')),
        );
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      // Perform registration
      context.read<AuthService>().register(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        username: emailController.text.split('@')[0], // Use email prefix as username
      );
    }
  }

  void _nextSignUpStep() {
    setState(() {
      signUpStepOne = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Scaffold(
      backgroundColor: AppColors.whiteCustom,
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, child) {
            // Handle navigation based on auth state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (authService.state.status == AuthStatus.authenticated) {
                Navigator.of(context).pushReplacementNamed('/home');
              } else if (authService.state.status == AuthStatus.requires2FA) {
                Navigator.of(context).pushNamed(
                  TwoFactorVerificationScreen.routeName,
                  arguments: {'email': authService.state.email},
                );
              } else if (authService.state.status == AuthStatus.error) {
                final currentError = authService.state.error;
                if (currentError != null && currentError != _lastError) {
                  _lastError = currentError;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(currentError)),
                  );
                }
              }
            });

            return SingleChildScrollView(
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
                        ? _buildLoginForm(styles, authService.isLoading)
                        : _buildSignupForm(styles, authService.isLoading),
                    _buildSecurityInformation(styles), // Always show this
                  ],
                ),
              ),
            );
          },
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
            child: Container(
              decoration: BoxDecoration(
                color: !isSignInSelected
                    ? AppColors.colorFF007B
                    : AppColors.transparentCustom,
                borderRadius: BorderRadius.circular(6),
                boxShadow: !isSignInSelected
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
                onPressed: () => _toggleSignInSignUp(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: styles.body14Regular.copyWith(
                    color: !isSignInSelected
                        ? AppColors.whiteCustom
                        : AppColors.colorFF5252,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(TextStyleHelper styles, bool isLoading) {
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
            isLoading: isLoading,
          ),
          const SizedBox(height: 24),
          _buildSeparator(styles),
          const SizedBox(height: 16),
          _buildPasskeyButton(styles),
        ],
      ),
    );
  }

  Widget _buildSeparator(TextStyleHelper styles) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.colorFFD4D4,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or Continue with',
            style: styles.body14Regular.copyWith(color: AppColors.colorFF7373),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.colorFFD4D4,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPasskeyButton(TextStyleHelper styles) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Handle Passkey sign in
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.colorFFD4D4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Remix.id_card_line, color: AppColors.colorFF007B, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sign in with Passkey',
              style: styles.title16Regular.copyWith(color: AppColors.colorFF007B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(TextStyleHelper styles, bool isLoading) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: signUpStepOne
          ? Column(
              children: [
                FirstNameField(controller: firstNameController, styles: styles),
                const SizedBox(height: 16),
                LastNameField(controller: lastNameController, styles: styles),
                const SizedBox(height: 16),
                EmailField(controller: emailController, styles: styles),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Next',
                  onPressed: () => _signup(),
                  isFullWidth: true,
                  height: 44,
                ),
              ],
            )
          : Column(
              children: [
                PasswordField(
                  controller: passwordController,
                  styles: styles,
                  isPasswordVisible: isPasswordVisible,
                  onToggleVisibility: _togglePasswordVisibility,
                ),
                const SizedBox(height: 16),
                ConfirmPasswordField(
                  controller: confirmPasswordController,
                  styles: styles,
                  isPasswordVisible: isConfirmPasswordVisible,
                  onToggleVisibility: _toggleConfirmPasswordVisibility,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Sign Up',
                  onPressed: _signup,
                  isFullWidth: true,
                  height: 44,
                  isLoading: isLoading,
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
          Icon(Remix.shield_user_fill, color: AppColors.colorFF007B, size: 16),
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
