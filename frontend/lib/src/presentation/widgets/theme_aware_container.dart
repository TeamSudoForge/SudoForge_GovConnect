import 'package:flutter/material.dart';

/// A container widget that automatically adapts to the current theme
class ThemeAwareContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const ThemeAwareContainer({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: border,
      ),
      child: child,
    );
  }
}

/// A text widget that automatically adapts to the current theme
class ThemeAwareText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isSecondary;

  const ThemeAwareText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = isSecondary
        ? theme.colorScheme.onSurface.withOpacity(0.6)
        : theme.colorScheme.onSurface;

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        color: style?.color ?? defaultColor,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// An icon widget that automatically adapts to the current theme
class ThemeAwareIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final bool isSecondary;

  const ThemeAwareIcon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = isSecondary
        ? theme.colorScheme.onSurface.withOpacity(0.6)
        : theme.colorScheme.onSurface;

    return Icon(icon, size: size, color: color ?? defaultColor);
  }
}
