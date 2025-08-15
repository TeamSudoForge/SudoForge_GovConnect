import 'package:flutter/material.dart';
import '../../core/theme/theme_config.dart';
import '../../core/utils/text_style_helper.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.padding,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.colorFF007B : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppColors.colorFF3838,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: AppColors.colorFFD4D4, width: 1),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTextStyles.title16Medium.copyWith(
                color: isPrimary ? Colors.white : AppColors.colorFF3838,
              ),
            ),
          ],
        ),
      ),
    );
  }
}