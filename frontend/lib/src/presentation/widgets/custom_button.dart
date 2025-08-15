import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.borderRadius,
    this.padding,
    this.hasShadow,
    this.isFullWidth,
    this.isLoading,
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool? hasShadow;
  final bool? isFullWidth;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ?? false ? double.infinity : width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: (isLoading ?? false) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? appTheme.colorFF007B,
          foregroundColor: textColor ?? appTheme.whiteCustom,
          elevation: hasShadow ?? false ? 2 : 0,
          shadowColor: appTheme.blackCustom.withAlpha(26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
        ),
        child: (isLoading ?? false)
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? appTheme.whiteCustom,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto',
                ),
              ),
      ),
    );
  }
}
