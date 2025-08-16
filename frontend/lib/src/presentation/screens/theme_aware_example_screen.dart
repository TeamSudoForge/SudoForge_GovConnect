import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../widgets/theme_aware_container.dart';

/// Example screen showing how to make any screen theme-aware
class ThemeAwareExampleScreen extends StatelessWidget {
  const ThemeAwareExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Theme Example'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Example using ThemeAwareContainer
                ThemeAwareContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThemeAwareText(
                        'Current Theme Settings',
                        style: TextStyle(
                          fontSize: 18 * settingsService.currentFontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemeAwareText(
                        'Theme Mode: ${settingsService.themeMode.name}',
                        style: TextStyle(
                          fontSize: 16 * settingsService.currentFontScale,
                        ),
                        isSecondary: true,
                      ),
                      ThemeAwareText(
                        'Font Scale: ${settingsService.currentFontScale}x',
                        style: TextStyle(
                          fontSize: 16 * settingsService.currentFontScale,
                        ),
                        isSecondary: true,
                      ),
                      ThemeAwareText(
                        'Language: ${settingsService.language.displayName}',
                        style: TextStyle(
                          fontSize: 16 * settingsService.currentFontScale,
                        ),
                        isSecondary: true,
                      ),
                    ],
                  ),
                ),

                // Example showing theme-aware colors
                ThemeAwareContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ThemeAwareIcon(Icons.palette),
                          const SizedBox(width: 8),
                          ThemeAwareText(
                            'Theme Colors',
                            style: TextStyle(
                              fontSize: 18 * settingsService.currentFontScale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildColorSample(context, 'Primary', theme.primaryColor),
                      _buildColorSample(
                        context,
                        'Surface',
                        theme.colorScheme.surface,
                      ),
                      _buildColorSample(
                        context,
                        'Background',
                        theme.scaffoldBackgroundColor,
                      ),
                    ],
                  ),
                ),

                // Example buttons with theme-aware styling
                ThemeAwareContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThemeAwareText(
                        'Theme-Aware Buttons',
                        style: TextStyle(
                          fontSize: 18 * settingsService.currentFontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          child: Text(
                            'Primary Button',
                            style: TextStyle(
                              fontSize: 16 * settingsService.currentFontScale,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.primaryColor),
                            foregroundColor: theme.primaryColor,
                          ),
                          child: Text(
                            'Outlined Button',
                            style: TextStyle(
                              fontSize: 16 * settingsService.currentFontScale,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSample(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.dividerTheme.color!),
            ),
          ),
          const SizedBox(width: 12),
          ThemeAwareText(
            label,
            style: const TextStyle(fontSize: 14),
            isSecondary: true,
          ),
        ],
      ),
    );
  }
}
