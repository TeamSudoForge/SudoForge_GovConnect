import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gov_connect/src/presentation/widgets/custom_button.dart';
import 'package:gov_connect/src/presentation/widgets/custom_image_view.dart';
import '../../core/services/auth_service.dart';
import '../../core/app_export.dart';

enum VerificationType { emailVerification, twoFactorAuth }

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final VerificationType verificationType;
  
  const EmailVerificationScreen({
    Key? key,
    required this.email,
    this.verificationType = VerificationType.emailVerification,
  }) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> codeControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> codeFocusNodes = List.generate(6, (index) => FocusNode());
  int _resendSeconds = 45;
  Timer? _timer;

  String get resendTimer => _resendSeconds < 10
      ? '00:0$_resendSeconds'
      : '00:$_resendSeconds';

  String get screenTitle {
    return widget.verificationType == VerificationType.emailVerification 
        ? 'Verify Email' 
        : 'Two-Factor Authentication';
  }

  String get headerTitle {
    return widget.verificationType == VerificationType.emailVerification 
        ? 'Check Your Email' 
        : 'Enter Security Code';
  }

  String get description {
    return widget.verificationType == VerificationType.emailVerification 
        ? 'We\'ve sent a verification code to your email address. Please enter the 6-digit code below to verify your account.'
        : 'We\'ve sent a 6-digit security code to your email address for two-factor authentication.';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeFocusNodes[0].requestFocus();
    });
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendSeconds = 45;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in codeControllers) {
      controller.dispose();
    }
    for (var focusNode in codeFocusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _handleCodeInput(String value, int index) {
    if (value.isNotEmpty && RegExp(r'^[0-9]$').hasMatch(value)) {
      if (index < 5) {
        codeFocusNodes[index + 1].requestFocus();
      }
    }
  }

  void _handleVerificationSubmit() {
    String code = codeControllers.map((controller) => controller.text).join('');
    if (code.length == 6) {
      final authService = context.read<AuthService>();
      
      if (widget.verificationType == VerificationType.emailVerification) {
        authService.verifyEmail(code);
      } else {
        authService.verify2FA(code);
      }
      
      print('Verification code submitted: $code');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter all 6 digits of the verification code.'),
          backgroundColor: appTheme.colorFFFF52,
        ),
      );
    }
  }

  void _handleResendCode() {
    if (_resendSeconds == 0) {
      final authService = context.read<AuthService>();
      
      if (widget.verificationType == VerificationType.emailVerification) {
        authService.resendEmailVerificationCode();
      } else {
        // For 2FA, we might need a separate resend method
        // This would need to be implemented in the backend/auth service
        print('Resend 2FA code requested');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification code has been resent to your email.'),
          backgroundColor: appTheme.colorFF4CAF,
        ),
      );
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteCustom,
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, child) {
            // Handle navigation based on auth state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (authService.isAuthenticated) {
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
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 428),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: appTheme.colorFFB8E3,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Center(
                                child: CustomImageView(
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            screenTitle,
                            style: TextStyleHelper.instance.title20
                                .copyWith(height: 1.2),
                          ),
                        ],
                      ),
                    ),
                Container(
                  margin: EdgeInsets.only(top: 32),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: appTheme.colorFFB8E3,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: CustomImageView(
                          height: 42,
                          width: 42,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 32, bottom: 24),
                        child: Text(
                          headerTitle,
                          style: TextStyleHelper.instance.headline24
                              .copyWith(height: 1.21),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 32),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          description,
                          style: TextStyleHelper.instance.title16
                              .copyWith(height: 1.13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: appTheme.colorFFEBF4,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Code sent to:',
                              style: TextStyleHelper.instance.body14
                                  .copyWith(height: 1.21),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.email,
                              style: TextStyleHelper.instance.title16Medium
                                  .copyWith(height: 1.19),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter verification code',
                              style: TextStyleHelper.instance.body14.copyWith(
                                  color: appTheme.colorFF4040, height: 1.21),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return Container(
                                  width: 48,
                                  height: 48,
                                  child: TextFormField(
                                    controller: codeControllers[index],
                                    focusNode: codeFocusNodes[index],
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    style:
                                    TextStyleHelper.instance.title18Medium,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: appTheme.whiteCustom,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: appTheme.colorFFD4D4,
                                            width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: appTheme.colorFFD4D4,
                                            width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: appTheme.colorFF007B,
                                            width: 2),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      _handleCodeInput(value, index);
                                    },
                                    onTap: () {
                                      codeControllers[index].selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                                offset: codeControllers[index]
                                                    .text
                                                    .length),
                                          );
                                    },
                                    onFieldSubmitted: (value) {
                                      if (index < 5) {
                                        codeFocusNodes[index + 1]
                                            .requestFocus();
                                      }
                                    },
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 24),
                            CustomButton(
                              text: widget.verificationType == VerificationType.emailVerification 
                                  ? 'Verify Email' 
                                  : 'Verify Code',
                              onPressed: authService.isLoading ? null : _handleVerificationSubmit,
                              isFullWidth: true,
                              height: 48,
                              backgroundColor: appTheme.colorFF007B,
                              textColor: appTheme.whiteCustom,
                              fontSize: 16,
                              borderRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 32),
                        child: Column(
                          children: [
                            Text(
                              'Didn\'t receive the code?',
                              style: TextStyleHelper.instance.body14.copyWith(
                                  color: appTheme.colorFF5252, height: 1.21),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: _handleResendCode,
                              child: Text(
                                'Resend Code',
                                style: TextStyleHelper.instance.body14.copyWith(
                                    color: _resendSeconds == 0
                                        ? appTheme.colorFF007B
                                        : Colors.grey,
                                    height: 1.21,
                                    decoration: TextDecoration.underline),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Resend available in $resendTimer',
                              style: TextStyleHelper.instance.body12
                                  .copyWith(height: 1.25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    );
  }
}
