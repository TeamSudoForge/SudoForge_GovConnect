import 'package:flutter/material.dart';
import '../../core/theme/text_style_helper.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double elevation;
  final bool showBackButton;
  final bool showNotifications;
  final bool showProfile;
  final VoidCallback? onBack;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;

  const CommonAppBar({
    Key? key,
    required this.title,
    this.titleStyle,
    this.actions,
    this.backgroundColor,
    this.iconColor,
    this.elevation = 0,
    this.showBackButton = true,
    this.showNotifications = true,
    this.showProfile = true,
    this.onBack,
    this.onNotifications,
    this.onProfile,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    void defaultNotificationsNav() {
      final current = ModalRoute.of(context)?.settings.name;
      if (current != '/notifications_screen') {
        Navigator.of(context).pushNamed('/notifications_screen');
      }
    }

    void defaultProfileNav() {
      // TODO add after adding the profile page
    }

    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            )
          : null,
      title: Text(
        title,
        style: (titleStyle ?? styles.title20).copyWith(color: Colors.white),
      ),
      backgroundColor: backgroundColor ?? Colors.blueAccent,
      elevation: elevation,
      actions: [
        if (showNotifications)
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: onNotifications ?? defaultNotificationsNav,
            tooltip: 'Notifications',
          ),
        if (showProfile)
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: onProfile ?? defaultProfileNav,
            tooltip: 'Profile',
          ),
        if (actions != null) ...actions!,
      ],
      iconTheme: IconThemeData(color: iconColor ?? Colors.black),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
