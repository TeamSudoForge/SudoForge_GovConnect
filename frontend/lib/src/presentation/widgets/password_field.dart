import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';
import '../../core/utils/text_style_helper.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final TextStyleHelper styles;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;

  const PasswordField({
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
        Text(
          'Password',
          style: styles.body14Regular
              .copyWith(color: appTheme.colorFF4040, height: 1.21),
        ),
        const SizedBox(height: 8),
        Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(color: appTheme.colorFFD4D4),
            borderRadius: BorderRadius.circular(8),
            color: appTheme.whiteCustom,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: styles.body14Regular
                  .copyWith(color: appTheme.colorFFADAE),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: appTheme.colorFFADAE,
                ),
              ),
              border: InputBorder.none,
            ),
            style: styles.body14Regular
                .copyWith(color: appTheme.colorFFADAE),
          ),
        ),
      ],
    );
  }
}
