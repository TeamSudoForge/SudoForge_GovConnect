import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class EmailVerificationTitleDesc extends StatelessWidget {
  const EmailVerificationTitleDesc({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 32, bottom: 24),
          child: Text(
            'Check Your Email',
            style: TextStyleHelper.instance.headline24.copyWith(height: 1.21),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 32),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'We\'ve sent a verification code to your email address. Please enter the 6-digit code below to verify your account.',
            style: TextStyleHelper.instance.title16.copyWith(height: 1.13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
