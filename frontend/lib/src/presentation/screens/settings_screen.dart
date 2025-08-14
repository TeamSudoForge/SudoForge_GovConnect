import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.colorFF007B,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(Icons.arrow_back, color: Color(0xFF007BCE), size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
              child: Icon(Icons.person, color: AppColors.colorFF007B, size: 20),
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
                _buildLanguageSection(settingsService),

                // Display Section
                _buildDisplaySection(settingsService),

                // Notifications Section
                _buildNotificationsSection(settingsService),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildLanguageSection(SettingsService settingsService) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Language',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          _buildLanguageOption(
            settingsService,
            AppLanguage.english,
            'English',
            Icons.language,
          ),
          _buildLanguageOption(
            settingsService,
            AppLanguage.sinhala,
            'සිංහල',
            Icons.language,
          ),
          _buildLanguageOption(
            settingsService,
            AppLanguage.tamil,
            'தமிழ்',
            Icons.language,
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
  ) {
    return InkWell(
      onTap: () => settingsService.updateLanguage(language),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF666666)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A1A),
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
              activeColor: AppColors.colorFF007B,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySection(SettingsService settingsService) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Display',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Font Size Section
          _buildFontSizeSection(settingsService),
          const Divider(height: 1, indent: 60),
          // Theme Section
          _buildThemeSection(settingsService),
        ],
      ),
    );
  }

  Widget _buildFontSizeSection(SettingsService settingsService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.text_fields, size: 24, color: Color(0xFF666666)),
              const SizedBox(width: 16),
              const Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(60, 0, 20, 16),
          child: Column(
            children: FontSizeOption.values.map((option) {
              return _buildFontSizeOption(settingsService, option);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeOption(
    SettingsService settingsService,
    FontSizeOption option,
  ) {
    return InkWell(
      onTap: () => settingsService.updateFontSize(option),
      child: Container(
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
              activeColor: AppColors.colorFF007B,
            ),
            const SizedBox(width: 12),
            Text(
              option.displayName,
              style: TextStyle(
                fontSize: 16 * option.scale,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(SettingsService settingsService) {
    return Column(
      children: [
        _buildThemeOption(
          settingsService,
          AppThemeMode.system,
          'System Theme',
          Icons.settings_system_daydream,
        ),
        _buildThemeOption(
          settingsService,
          AppThemeMode.light,
          'Light Mode',
          Icons.light_mode,
        ),
        _buildThemeOption(
          settingsService,
          AppThemeMode.dark,
          'Dark Mode',
          Icons.dark_mode,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    SettingsService settingsService,
    AppThemeMode themeMode,
    String label,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => settingsService.updateThemeMode(themeMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF666666)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A1A),
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
              activeColor: AppColors.colorFF007B,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(SettingsService settingsService) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: Color(0xFF666666),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Receive push notifications',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
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
                  activeColor: AppColors.colorFF007B,
                  activeTrackColor: AppColors.colorFF007B.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false, () {
            Navigator.of(context).pop();
          }),
          _buildNavItem(Icons.grid_view_outlined, 'Services', false, () {}),
          _buildNavItem(
            Icons.calendar_today_outlined,
            'Appointments',
            false,
            () {},
          ),
          _buildNavItem(Icons.settings, 'Settings', true, () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.colorFF007B
                  : const Color(0xFF666666),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? AppColors.colorFF007B
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
