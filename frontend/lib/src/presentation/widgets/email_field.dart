import 'package:flutter/material.dart';
import '../../core/theme/theme_config.dart';
import '../../core/utils/text_style_helper.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final TextStyleHelper styles;

  const EmailField({
    Key? key,
    required this.controller,
    required this.styles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: styles.body14Regular
              .copyWith(color: AppColors.colorFF4040, height: 1.21),
        ),
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
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: styles.body14Regular
                  .copyWith(color: AppColors.colorFFADAE),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            style: styles.body14Regular
                .copyWith(color: AppColors.colorFFADAE),
          ),
        ),
      ],
    );
  }
}

