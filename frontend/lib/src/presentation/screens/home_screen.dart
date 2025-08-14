import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'qrflow/qr_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Scaffold(
      backgroundColor: AppColors.whiteCustom,
      appBar: AppBar(
        backgroundColor: AppColors.colorFF007B,
        elevation: 0,
        title: Text(
          'GovConnect',
          style: styles.title18Medium.copyWith(color: AppColors.whiteCustom),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed('settings');
            },
            icon: Icon(Remix.settings_3_line, color: AppColors.whiteCustom),
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: Icon(Remix.logout_circle_line, color: AppColors.whiteCustom),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(user, styles),
                const SizedBox(height: 32),
                _buildQuickActions(context, styles),
                const SizedBox(height: 32),
                _buildUserInfo(user, styles),
                const SizedBox(height: 24),
                // Button to navigate to app navigation screen
                CustomButton(
                  text: 'appointment details',
                  onPressed: () {
                    context.pushNamed('appointment-details');
                  },
                  backgroundColor: AppColors.colorFF007B,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(UserProfile? user, TextStyleHelper styles) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.colorFF007B, AppColors.colorFF0062],
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
              color: AppColors.whiteCustom.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
            style: styles.headline24Regular.copyWith(
              color: AppColors.whiteCustom,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Access all your government services in one place.',
            style: styles.body14Regular.copyWith(
              color: AppColors.whiteCustom.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, TextStyleHelper styles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: styles.title20.copyWith(color: AppColors.colorFF0062),
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'Login',
          icon: Remix.login_box_line,
          backgroundColor: AppColors.colorFF007B,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          styles: styles,
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'Scan QR Code',
          icon: Remix.qr_scan_line,
          backgroundColor: AppColors.colorFF0062,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QrScanScreen()),
            );
          },
          styles: styles,
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
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.colorFFD4D4),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorFF0845.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.whiteCustom, size: 24),
            const SizedBox(height: 8),
            Text(
              text,
              style: styles.body14Medium.copyWith(color: AppColors.whiteCustom),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserProfile? user, TextStyleHelper styles) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorFFF3F4,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Remix.user_line, color: AppColors.colorFF007B, size: 20),
              const SizedBox(width: 8),
              Text(
                'Account Information',
                style: styles.title16Medium.copyWith(
                  color: AppColors.colorFF0062,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Email', user?.email ?? '', styles),
          const SizedBox(height: 8),
          _buildInfoRow('Username', user?.username ?? '', styles),
          const SizedBox(height: 8),
          _buildInfoRow('Role', user?.role ?? '', styles),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextStyleHelper styles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: styles.body14Regular.copyWith(color: AppColors.colorFF5252),
        ),
        Text(
          value,
          style: styles.body14Medium.copyWith(color: AppColors.colorFF0062),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final styles = TextStyleHelper.instance;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.whiteCustom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Logout',
          style: styles.title18Medium.copyWith(color: AppColors.colorFF0062),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: styles.body14Regular.copyWith(color: AppColors.colorFF5252),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: styles.body14Regular.copyWith(
                color: AppColors.colorFF7373,
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
