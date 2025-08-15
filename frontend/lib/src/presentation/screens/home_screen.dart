import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'login_screen.dart';
import 'qrflow/qr_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          'GovConnect',
          style: styles.title18Medium.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed('profile');
            },
            icon: Icon(
              Icons.account_circle,
              color: theme.colorScheme.onPrimary,
              size: 28,
            ),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: Icon(
              Remix.logout_circle_line,
              color: theme.colorScheme.onPrimary,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer2<AuthService, SettingsService>(
        builder: (context, authService, settingsService, child) {
          final user = authService.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(user, styles, theme),
                const SizedBox(height: 32),
                _buildQuickActions(context, styles, theme),
                const SizedBox(height: 32),
                _buildUserInfo(user, styles, theme),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentItem: BottomNavItem.home,
      ),
    );
  }

  Widget _buildWelcomeSection(
    UserProfile? user,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: styles.title16Regular.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
            style: styles.headline24Regular.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Access all your government services in one place.',
            style: styles.body14Regular.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: styles.title20.copyWith(color: theme.colorScheme.secondary),
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'Login',
          icon: Remix.login_box_line,
          backgroundColor: theme.primaryColor,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          styles: styles,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'Scan QR Code',
          icon: Remix.qr_scan_line,
          backgroundColor: theme.colorScheme.secondary,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QrScanScreen()),
            );
          },
          styles: styles,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'Add Passkey',
          icon: Remix.fingerprint_line,
          backgroundColor: AppColors.colorFF007B,
          onPressed: () {
            context.pushNamed('add-passkey');
          },
          styles: styles,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'ID Recovery Process',
          icon: Remix.id_card_line,
          backgroundColor: const Color(0xFF2196F3),
          onPressed: () {
            context.pushNamed('id-recovery-process');
          },
          styles: styles,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required TextStyleHelper styles,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerTheme.color!),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.onPrimary, size: 24),
            const SizedBox(height: 8),
            Text(
              text,
              style: styles.body14Medium.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(
    UserProfile? user,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Remix.user_line, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Account Information',
                style: styles.title16Medium.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Email', user?.email ?? '', styles, theme),
          const SizedBox(height: 8),
          _buildInfoRow('Username', user?.username ?? '', styles, theme),
          const SizedBox(height: 8),
          _buildInfoRow('Role', user?.role ?? '', styles, theme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: styles.body14Regular.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: styles.body14Medium.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Logout',
          style: styles.title18Medium.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: styles.body14Regular.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: styles.body14Regular.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          CustomButton(
            text: 'Logout',
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthService>().logout();
            },
            backgroundColor: AppColors.colorFF007B,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }
}
