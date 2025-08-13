import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../core/theme/text_style_helper.dart';
import '../../core/theme/theme_config.dart';
import '../../core/providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class TwoFactorVerificationScreen extends StatefulWidget {
  static const String routeName = '/two-factor-verification';
  
  const TwoFactorVerificationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<TwoFactorVerificationScreen> createState() => _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState extends State<TwoFactorVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all digits are entered
    if (index == 5 && value.isNotEmpty) {
      _verifyCode();
    }
  }

  void _verifyCode() {
    final code = _controllers.map((controller) => controller.text).join();
    if (code.length == 6) {
      context.read<AuthService>().verify2FA(code);
    }
  }

  void _resendCode() {
    // TODO: Implement resend functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code sent!')),
    );
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
              } else if (authService.state.status == AuthStatus.error) {
                if (authService.state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authService.state.error!)),
                  );
                  authService.clearError();
                }
              }
            });

            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(styles),
                    const SizedBox(height: 40),
                    _buildCodeInput(styles),
                    const SizedBox(height: 24),
                    _buildVerifyButton(styles, authService.isLoading),
                    const SizedBox(height: 16),
                    _buildResendSection(styles),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(TextStyleHelper styles) {
    return Column(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: AppColors.colorFF007B.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Icon(
            Icons.security,
            color: AppColors.colorFF007B,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Two-Factor Authentication',
          textAlign: TextAlign.center,
          style: styles.headline24Regular.copyWith(height: 1.25),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'We\'ve sent a 6-digit verification code to\n${context.read<AuthService>().state.email}',
            textAlign: TextAlign.center,
            style: styles.body14Regular.copyWith(
              color: AppColors.colorFF3838,
              height: 1.64,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput(TextStyleHelper styles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          height: 56,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: styles.headline20Regular.copyWith(
              color: AppColors.colorFF0062,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.colorFFD4D4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.colorFF007B, width: 2),
              ),
              fillColor: AppColors.whiteCustom,
              filled: true,
            ),
            onChanged: (value) => _onDigitEntered(index, value),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton(TextStyleHelper styles, bool isLoading) {
    return CustomButton(
      text: isLoading ? 'Verifying...' : 'Verify Code',
      onPressed: isLoading ? null : _verifyCode,
      isFullWidth: true,
      height: 44,
      isLoading: isLoading,
    );
  }

  Widget _buildResendSection(TextStyleHelper styles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the code? ',
          style: styles.body14Regular.copyWith(color: AppColors.colorFF5252),
        ),
        GestureDetector(
          onTap: _resendCode,
          child: Text(
            'Resend',
            style: styles.body14Regular.copyWith(
              color: AppColors.colorFF007B,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
