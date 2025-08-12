import 'package:flutter/material.dart';
import '../../core/theme/text_style_helper.dart';
import '../../core/utils/image_constant.dart';

class EmailVerificationScreen extends StatelessWidget {

  static const String routeName = '/emailVerification';

  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(ImageConstant.imgArrowleft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Verification',
                style: styles.headline24,
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your email for verification link',
                style: styles.body14Regular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
