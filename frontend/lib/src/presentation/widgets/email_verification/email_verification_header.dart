import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../custom_image_view.dart';

class EmailVerificationHeader extends StatelessWidget {
  const EmailVerificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Verify Email',
            style: TextStyleHelper.instance.title20.copyWith(height: 1.2),
          ),
        ],
      ),
    );
  }
}
