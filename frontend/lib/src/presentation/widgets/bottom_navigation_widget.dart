import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum BottomNavItem {
  home(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
    route: '/home',
  ),
  services(
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view,
    label: 'Services',
    route: '/services', // TODO: Update with actual route
  ),
  appointments(
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
    label: 'Appointments',
    route: '/appointments',
  ),
  settings(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: 'Settings',
    route: '/home/settings',
  );

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

class BottomNavigationWidget extends StatelessWidget {
  final BottomNavItem currentItem;
  final Function(BottomNavItem)? onItemTapped;

  const BottomNavigationWidget({
    Key? key,
    required this.currentItem,
    this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerTheme.color!, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: BottomNavItem.values.map((item) {
            final isSelected = item == currentItem;
            return _buildNavItem(
              icon: isSelected ? item.activeIcon : item.icon,
              label: item.label,
              isSelected: isSelected,
              onTap: () => _handleItemTap(context, item),
              theme: theme,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 3),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isSelected
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleItemTap(BuildContext context, BottomNavItem item) {
    // Use custom callback if provided
    if (onItemTapped != null) {
      onItemTapped!(item);
      return;
    }

    // Default navigation using GoRouter
    final router = GoRouter.of(context);

    switch (item) {
      case BottomNavItem.home:
        router.go('/home');
        break;
      case BottomNavItem.services:
        _showNotImplementedMessage(context, 'Services');
        break;
      case BottomNavItem.appointments:
        router.go('/appointments');
        break;
      case BottomNavItem.settings:
        router.go('/home/settings');
        break;
    }
  }

  void _showNotImplementedMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
