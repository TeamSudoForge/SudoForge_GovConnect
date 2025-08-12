import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class EmailVerificationResendSection extends StatelessWidget {
  final String resendTimer;
  final VoidCallback onResendCode;

  const EmailVerificationResendSection({
    required this.resendTimer,
    required this.onResendCode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Text(
            'Didn\'t receive the code?',
            style: TextStyleHelper.instance.body14
                .copyWith(color: appTheme.colorFF5252, height: 1.21),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: onResendCode,
            child: Text(
              'Resend Code',
              style: TextStyleHelper.instance.body14.copyWith(
                  color: appTheme.colorFF007B,
                  height: 1.21,
                  decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Resend available in $resendTimer',
            style: TextStyleHelper.instance.body12.copyWith(height: 1.25),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
