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
    route: '/services',
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
    final mq = MediaQuery.of(context);

    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final orientation = mq.orientation;

    // ✅ Scale values relative to screen size
    final iconSize = (screenWidth * 0.06).clamp(20, 28).toDouble();
    final fontSize = (screenWidth * 0.035).clamp(11, 15).toDouble();
    final bottomNavHeight =
        (orientation == Orientation.landscape
                ? screenHeight * 0.12
                : screenHeight * 0.13)
            .clamp(70, 110)
            .toDouble();

    final useTabletLayout = screenWidth >= 700; // smoother threshold

    return Container(
      height: bottomNavHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: useTabletLayout
            ? _buildTabletLayout(
                context,
                theme,
                iconSize,
                fontSize,
                screenWidth,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: BottomNavItem.values.map((item) {
                  final isSelected = item == currentItem;
                  return _buildNavItem(
                    context: context,
                    icon: isSelected ? item.activeIcon : item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => _handleItemTap(context, item),
                    theme: theme,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    screenWidth: screenWidth,
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required double iconSize,
    required double fontSize,
    required double screenWidth,
  }) {
    final showLabel = screenWidth >= 320; // hide on tiny phones
    final space = showLabel ? 3.0 : 0.0;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: theme.primaryColor.withOpacity(0.1),
          highlightColor: theme.primaryColor.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                if (showLabel) ...[
                  SizedBox(height: space),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? theme.primaryColor
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    ThemeData theme,
    double iconSize,
    double fontSize,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: BottomNavItem.values.map((item) {
          final isSelected = item == currentItem;
          return Expanded(
            child: InkWell(
              onTap: () => _handleItemTap(context, item),
              borderRadius: BorderRadius.circular(12),
              splashColor: theme.primaryColor.withOpacity(0.1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: isSelected
                    ? BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.2),
                        ),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: iconSize + 2,
                      color: isSelected
                          ? theme.primaryColor
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: fontSize + 1,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleItemTap(BuildContext context, BottomNavItem item) {
    if (onItemTapped != null) {
      onItemTapped!(item);
      return;
    }

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature feature coming soon!')));
  }
}
