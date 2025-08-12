import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/routes/app_routes.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
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
    this.actions,
    this.elevation = 0,
    this.showBackButton = true,
    this.showNotifications = true,
    this.showProfile = true,
    this.onBack,
    this.onNotifications,
    this.onProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void defaultNotificationsNav() {
      final current = ModalRoute.of(context)?.settings.name;
      if (current != AppRoutes.notificationsScreen) {
        Navigator.of(context).pushNamed(AppRoutes.notificationsScreen);
      }
    }

    void defaultProfileNav() {
      // TODO add after adding the profile page
    }

    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            )
          : null,
      title: Text(title),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
