import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../custom_image_view.dart';

class EmailVerificationIcon extends StatelessWidget {
  const EmailVerificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              imagePath: ImageConstant.imgI,
              height: 42,
              width: 42,
            ),
          ),
        ),
      ),
    );
  }
}
