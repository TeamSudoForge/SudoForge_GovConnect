import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const SettingsTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Container(
      color: backgroundColor,
      child: ListTile(
        contentPadding:
            padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: leading,
        title: Text(
          title,
          style: styles.title16Medium.copyWith(color: AppColors.colorFF1717),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: styles.body14Regular.copyWith(
                  color: AppColors.colorFF7373,
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const SettingsSection({
    Key? key,
    required this.title,
    required this.children,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Container(
      margin: margin ?? const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              title.toUpperCase(),
              style: styles.body14Medium.copyWith(
                color: AppColors.colorFF007B,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: AppColors.colorFFD4D4,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class SettingsSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? leading;

  const SettingsSwitch({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.colorFF007B,
      ),
      onTap: () => onChanged(!value),
    );
  }
}

class SettingsDropdown<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Widget? leading;

  const SettingsDropdown({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
        style: TextStyleHelper.instance.body14Medium.copyWith(
          color: AppColors.colorFF1717,
        ),
      ),
    );
  }
}

class SettingsSlider extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? labelBuilder;
  final Widget? leading;

  const SettingsSlider({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.labelBuilder,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 16)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: styles.title16Medium.copyWith(
                        color: AppColors.colorFF1717,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: styles.body14Regular.copyWith(
                          color: AppColors.colorFF7373,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                labelBuilder?.call(value) ?? value.toStringAsFixed(1),
                style: styles.body14Medium.copyWith(
                  color: AppColors.colorFF007B,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.colorFF007B,
              inactiveTrackColor: AppColors.colorFFD4D4,
              thumbColor: AppColors.colorFF007B,
              overlayColor: AppColors.colorFF007B.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
