// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/profile/dtos/reminders_config_dto.dart';
import '../../../../data/repositories/profile/dtos/system_dto.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/themes/colors.dart';
import './app_settings_config.dart';
import './reminders_settings_config.dart';

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
    final titleColor = isDarkTheme
        ? ThemedColors.themedGrey.light
        : ThemedColors.themedGrey.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Settings",
          style: TextStyle(
            fontSize: sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        Card(
          child: Padding(
            padding: EdgeInsets.all(sizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                SizedBox(height: sizes.spacing),
                _DataBackupRow(
                  sizes: sizes,
                  titleColor: titleColor,
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
        ),
      ],
    );
  }
}

class _DataBackupRow extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Color titleColor;
  final VoidCallback onTap;

  const _DataBackupRow({
    required this.sizes,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizes.spacing),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data & Backup",
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sizes.quarterSpacing),
                  Text(
                    "Export/import your data",
                    style: TextStyle(
                      fontSize: sizes.smallFontSize,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: titleColor),
          ],
        ),
      ),
    );
  }
}
