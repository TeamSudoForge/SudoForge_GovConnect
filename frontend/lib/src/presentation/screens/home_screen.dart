import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/theme/text_style_helper.dart';
import '../../core/theme/theme_config.dart';
import '../widgets/custom_button.dart';

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
          style: styles.headline18Regular.copyWith(
            color: AppColors.whiteCustom,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: Icon(
              Remix.logout_circle_line,
              color: AppColors.whiteCustom,
            ),
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
                _buildQuickActions(styles),
                const SizedBox(height: 32),
                _buildUserInfo(user, styles),
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
            style: styles.body16Regular.copyWith(
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

  Widget _buildQuickActions(TextStyleHelper styles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: styles.headline20Regular.copyWith(
            color: AppColors.colorFF0062,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Remix.file_text_line,
                title: 'Documents',
                subtitle: 'View & Download',
                styles: styles,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Remix.bill_line,
                title: 'Bills',
                subtitle: 'Pay Online',
                styles: styles,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Remix.service_line,
                title: 'Services',
                subtitle: 'Apply Now',
                styles: styles,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Remix.customer_service_2_line,
                title: 'Support',
                subtitle: 'Get Help',
                styles: styles,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextStyleHelper styles,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteCustom,
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
        children: [
          Icon(
            icon,
            color: AppColors.colorFF007B,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: styles.body14Medium.copyWith(
              color: AppColors.colorFF0062,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: styles.body12Regular.copyWith(
              color: AppColors.colorFF7373,
            ),
          ),
        ],
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
              Icon(
                Remix.user_line,
                color: AppColors.colorFF007B,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Account Information',
                style: styles.body16Medium.copyWith(
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
          style: styles.body14Regular.copyWith(
            color: AppColors.colorFF5252,
          ),
        ),
        Text(
          value,
          style: styles.body14Medium.copyWith(
            color: AppColors.colorFF0062,
          ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Logout',
          style: styles.headline18Regular.copyWith(
            color: AppColors.colorFF0062,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: styles.body14Regular.copyWith(
            color: AppColors.colorFF5252,
          ),
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
