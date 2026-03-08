import 'package:flutter/material.dart';

import '../../services/dtos/reminders_config_dto.dart';
import '../../services/dtos/system_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'app_settings_config.dart';
import 'reminders_settings_config.dart';

class SettingsConfig extends StatelessWidget {
  final int profileId;
  final DataDisplaySizesList sizes;
  final SystemDto system;
  final RemindersConfigDto remindersConfig;
  final bool isLoading;

  const SettingsConfig({
    super.key,
    required this.profileId,
    required this.sizes,
    required this.system,
    required this.remindersConfig,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontSize: sizes.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: sizes.padding),
            AppSettingsConfig(
              isLoading: isLoading,
              system: system,
              sizes: sizes,
              theme: theme,
              isDarkTheme: isDarkTheme,
            ),
            SizedBox(height: sizes.spacing),
            RemindersSettingsConfig(
              theme: theme,
              isDarkTheme: isDarkTheme,
              isLoading: isLoading,
              sizes: sizes,
              profileId: profileId,
              remindersConfig: remindersConfig,
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text("Data & Backup"),
              subtitle: const Text("Export/import your data"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data management coming soon!"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
