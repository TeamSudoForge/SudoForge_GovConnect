import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';
import '../../core/services/appointment_service.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/models/appointment_models.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'login_screen.dart';
import 'qrflow/qr_scan_screen.dart';
import 'chatbot_screen.dart';

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
      body: Consumer3<AuthService, SettingsService, AppointmentService>(
        builder:
            (context, authService, settingsService, appointmentService, child) {
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
                    _buildUpcomingAppointments(
                      context,
                      appointmentService,
                      styles,
                      theme,
                    ),
                    const SizedBox(height: 32),
                    _buildUserInfo(user, styles, theme),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: AppColors.colorFF007B,
        child: Icon(
          Remix.customer_service_2_line,
          color: AppColors.whiteCustom,
        ),
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
    return Consumer<AppointmentService>(
      builder: (context, appointmentService, child) {
        final upcomingCount = appointmentService.upcomingAppointments.length;

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
                'Welcome, ${user?.firstName ?? 'Kavindu'}',
                style: styles.headline24Regular.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s your current status',
                style: styles.body14Regular.copyWith(
                  fontSize: 16,
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              // Status Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        icon: Remix.calendar_line,
                        title: 'Appointments',
                        count: upcomingCount.toString(),
                        subtitle: 'Upcoming this week',
                        iconColor: const Color(0xFFFF9500),
                        styles: styles,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatusCard(
                        icon: Remix.service_line,
                        title: 'Services',
                        count: '6',
                        subtitle: 'In progress',
                        iconColor: const Color(0xFF34C759),
                        styles: styles,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String count,
    required String subtitle,
    required Color iconColor,
    required TextStyleHelper styles,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: styles.body14Medium.copyWith(
                color: const Color(0xFF1D1D1F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          count,
          style: styles.headline24Regular.copyWith(
            color: const Color(0xFF1D1D1F),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: styles.body12Regular.copyWith(color: const Color(0xFF8E8E93)),
        ),
      ],
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
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'Dynamic Form Demo',
          icon: Remix.file_2_line,
          backgroundColor: const Color(0xFF2196F3),
          onPressed: () {
            context.pushNamed('form-selection');
          },
          styles: styles,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'Dynamic Forms 2',
          icon: Remix.file_2_line,
          backgroundColor: const Color(0xFF2196F3),
          onPressed: () {
            context.pushNamed('form-selection');
          },
          styles: styles,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'GovConnect Assistant',
          icon: Remix.customer_service_2_line,
          backgroundColor: AppColors.colorFF007B,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
          styles: styles,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          text: 'Reset Welcome Screens (Debug)',
          icon: Remix.refresh_line,
          backgroundColor: Colors.orange,
          onPressed: () async {
            await OnboardingService.instance.resetOnboarding();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome screens reset. Restart app to see them.'),
              ),
            );
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

  Widget _buildUpcomingAppointments(
    BuildContext context,
    AppointmentService appointmentService,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    final nextTwoAppointments = appointmentService.nextTwoAppointments;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Appointments',
                style: styles.title18Medium.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.pushNamed('appointments');
                },
                child: Text(
                  'View all',
                  style: styles.body14Medium.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (appointmentService.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (appointmentService.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Remix.error_warning_line,
                      color: theme.colorScheme.error,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appointmentService.error!,
                      style: styles.body14Regular.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => appointmentService.refreshAppointments(),
                      child: Text(
                        'Retry',
                        style: styles.body14Medium.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (nextTwoAppointments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Remix.calendar_line,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No upcoming appointments',
                      style: styles.body14Regular.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...nextTwoAppointments.map((appointment) {
              return _buildAppointmentCard(context, appointment, styles, theme);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentListItem appointment,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    // Get icon and color based on appointment type
    final iconCode = AppointmentService.getAppointmentIcon(appointment.title);
    final colorCode = AppointmentService.getAppointmentColor(appointment.title);
    final appointmentColor = Color(colorCode);
    final appointmentIcon = IconData(iconCode, fontFamily: 'RemixIcon');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color!.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: appointmentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(appointmentIcon, color: appointmentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title,
                  style: styles.title16Medium.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Remix.time_line,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${appointment.date.replaceAll('\n', ' ')} • ${appointment.time}',
                        style: styles.body14Regular.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.department,
                  style: styles.body12Regular.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              // Navigate to appointment details
              context.pushNamed(
                'appointment-details',
                pathParameters: {'appointmentId': appointment.id},
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Details',
                style: styles.body14Medium.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
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
