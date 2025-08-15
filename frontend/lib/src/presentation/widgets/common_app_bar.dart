import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gov_connect/src/core/routes/app_router.dart';
import 'package:provider/provider.dart';
import 'package:gov_connect/src/core/providers/notification_provider.dart';

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
      final current = GoRouterState.of(context).matchedLocation;
      if (current != AppRoutes.notifications) {
        context.pushNamed('notifications');
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
              onPressed:
                  onBack ?? () => context.canPop() ? context.pop() : null,
              tooltip: 'Back',
            )
          : null,
      title: Text(title),
      elevation: elevation,
      actions: [
        if (showNotifications)
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: onNotifications ?? defaultNotificationsNav,
                  tooltip: 'Notifications',
                ),
                if (provider.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        provider.unreadCount.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
