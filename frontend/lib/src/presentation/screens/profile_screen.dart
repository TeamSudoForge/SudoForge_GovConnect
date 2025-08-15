import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../widgets/custom_button.dart';
import '../widgets/common_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/home/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: 'Profile',
        showBackButton: true,
        showNotifications: true,
        showProfile: false,
        onBack: () => context.pop(),
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(user, styles, theme),
                const SizedBox(height: 24),
                _buildProfileSections(context, user, styles, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    UserProfile? user,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Picture with Camera Icon
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/icons_imported/baby.png',
                    ), // Placeholder image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User Name
          Text(
            '${user?.firstName ?? 'Kavindu'} ${user?.lastName ?? 'Perera'}',
            style: styles.title20.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            user?.email ?? 'kavindu.perera@gmail.com',
            style: styles.body14Regular.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          // Birthday
          Text(
            'Birthday: March 15, 1985',
            style: styles.body14Regular.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSections(
    BuildContext context,
    UserProfile? user,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Current Location Section
          _buildInfoSection(
            icon: Icons.location_on_outlined,
            title: 'Current Location',
            subtitle: 'Kottawa, Colombo District',
            action: 'Change',
            onActionTap: () {
              // TODO: Implement location change functionality
              _showNotImplementedDialog(context, 'Location change');
            },
            styles: styles,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Mobile Number Section
          _buildInfoSection(
            icon: Icons.phone_outlined,
            title: 'Mobile Number',
            subtitle: '+94 726056012',
            action: 'Change',
            onActionTap: () {
              // TODO: Implement mobile number change functionality
              _showNotImplementedDialog(context, 'Mobile number change');
            },
            styles: styles,
            theme: theme,
          ),
          const SizedBox(height: 32),

          // Documents Section
          _buildDocumentsSection(context, styles, theme),
          const SizedBox(height: 32),

          // Digital Signature Section
          _buildDigitalSignatureSection(context, styles, theme),
          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(context, styles, theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onActionTap,
    required TextStyleHelper styles,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: styles.body14Regular.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: styles.body14Medium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onActionTap,
            child: Text(
              action,
              style: styles.body14Medium.copyWith(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(
    BuildContext context,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Documents',
              style: styles.title18Medium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement add document functionality
                _showNotImplementedDialog(context, 'Add document');
              },
              icon: Icon(Icons.add, color: theme.primaryColor, size: 20),
              label: Text(
                'Add',
                style: styles.body14Medium.copyWith(color: theme.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDocumentItem(
          icon: Icons.badge_outlined,
          title: "Driver's License",
          subtitle: 'Uploaded on Jan 15, 2025',
          styles: styles,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildDocumentItem(
          icon: Icons.book_outlined,
          title: 'Passport',
          subtitle: 'Uploaded on Dec 28, 2024',
          styles: styles,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildDocumentItem(
          icon: Icons.description_outlined,
          title: 'Birth Certificate',
          subtitle: 'Uploaded on Nov 10, 2024',
          styles: styles,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildDocumentItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextStyleHelper styles,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: styles.body14Medium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: styles.body12Regular.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement edit document functionality
            },
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement delete document functionality
            },
            icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalSignatureSection(
    BuildContext context,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Digital Signature',
          style: styles.title18Medium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.draw, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signature',
                      style: styles.body14Medium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last updated: Jan 20, 2025',
                      style: styles.body12Regular.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement update signature functionality
                  _showNotImplementedDialog(context, 'Update signature');
                },
                child: Text(
                  'Update',
                  style: styles.body14Medium.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    TextStyleHelper styles,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // Sign Out Button
        CustomButton(
          text: 'Sign Out',
          onPressed: () {
            _showSignOutDialog(context);
          },
          backgroundColor: theme.primaryColor,
          height: 48,
        ),
        const SizedBox(height: 16),
        // Delete Account Button
        Container(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              _showDeleteAccountDialog(context);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete Account',
              style: styles.body14Medium.copyWith(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  void _showNotImplementedDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature functionality will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Sign Out',
          style: styles.title18Medium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
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
            text: 'Sign Out',
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthService>().logout();
            },
            backgroundColor: theme.primaryColor,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Account',
          style: styles.title18Medium.copyWith(color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
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
          Container(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement delete account functionality
                _showNotImplementedDialog(context, 'Delete account');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: styles.body14Medium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
