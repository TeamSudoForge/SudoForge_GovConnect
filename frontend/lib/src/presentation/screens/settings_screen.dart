import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../widgets/bottom_navigation_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(Icons.arrow_back, color: theme.primaryColor, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings', style: theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: theme.primaryColor, size: 20),
            ),
          ),
        ],
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Language Section
                _buildLanguageSection(settingsService, theme),

                // Display Section
                _buildDisplaySection(settingsService, theme),

                // Notifications Section
                _buildNotificationsSection(settingsService, theme),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentItem: BottomNavItem.settings,
      ),
    );
  }

  Widget _buildLanguageSection(
    SettingsService settingsService,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Language',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          _buildLanguageOption(
            settingsService,
            AppLanguage.english,
            'English',
            Icons.language,
            theme,
          ),
          _buildLanguageOption(
            settingsService,
            AppLanguage.sinhala,
            'සිංහල',
            Icons.language,
            theme,
          ),
          _buildLanguageOption(
            settingsService,
            AppLanguage.tamil,
            'தமிழ்',
            Icons.language,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    SettingsService settingsService,
    AppLanguage language,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Radio<AppLanguage>(
            value: language,
            groupValue: settingsService.language,
            onChanged: (value) {
              if (value != null) {
                settingsService.updateLanguage(value);
              }
            },
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySection(
    SettingsService settingsService,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Display',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Font Size Section
          _buildFontSizeSection(settingsService, theme),
          Divider(height: 1, indent: 60, color: theme.dividerTheme.color),
          // Theme Section
          _buildThemeSection(settingsService, theme),
        ],
      ),
    );
  }

  Widget _buildFontSizeSection(
    SettingsService settingsService,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.text_fields,
                size: 24,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 16),
              Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(60, 0, 20, 16),
          child: Column(
            children: FontSizeOption.values.map((option) {
              return _buildFontSizeOption(settingsService, option, theme);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeOption(
    SettingsService settingsService,
    FontSizeOption option,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Radio<FontSizeOption>(
            value: option,
            groupValue: settingsService.fontSize,
            onChanged: (value) {
              if (value != null) {
                settingsService.updateFontSize(value);
              }
            },
            activeColor: theme.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            option.displayName,
            style: TextStyle(
              fontSize: 16 * option.scale,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(SettingsService settingsService, ThemeData theme) {
    return Column(
      children: [
        _buildThemeOption(
          settingsService,
          AppThemeMode.system,
          'System Theme',
          Icons.settings_system_daydream,
          theme,
        ),
        _buildThemeOption(
          settingsService,
          AppThemeMode.light,
          'Light Mode',
          Icons.light_mode,
          theme,
        ),
        _buildThemeOption(
          settingsService,
          AppThemeMode.dark,
          'Dark Mode',
          Icons.dark_mode,
          theme,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    SettingsService settingsService,
    AppThemeMode themeMode,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Radio<AppThemeMode>(
            value: themeMode,
            groupValue: settingsService.themeMode,
            onChanged: (value) {
              if (value != null) {
                settingsService.updateThemeMode(value);
              }
            },
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(
    SettingsService settingsService,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Receive push notifications',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settingsService.notificationsEnabled,
                  onChanged: (value) {
                    settingsService.updateNotificationsEnabled(value);
                  },
                  activeColor: theme.primaryColor,
                  activeTrackColor: theme.primaryColor.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
