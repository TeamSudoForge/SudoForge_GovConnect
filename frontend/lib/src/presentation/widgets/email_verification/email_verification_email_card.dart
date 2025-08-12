import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class EmailVerificationEmailCard extends StatelessWidget {
  final String emailAddress;
  const EmailVerificationEmailCard({required this.emailAddress, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: TextStyleHelper.instance.body14.copyWith(height: 1.21),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            emailAddress,
            style: TextStyleHelper.instance.title16Medium.copyWith(height: 1.19),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
