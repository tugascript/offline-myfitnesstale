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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/profile/dtos/system_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/themes/colors.dart';
import '../../view_models/profile_cubit.dart';
import 'app_settings_selector.dart';

class AppSettingsConfig extends StatelessWidget {
  final SystemDto system;
  final bool isLoading;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;

  const AppSettingsConfig({
    super.key,
    required this.system,
    required this.isLoading,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final titleColor = ThemedColors.themedGrey.fromBrightness(theme.brightness);

    return Column(
      key: const ValueKey('profile-app-settings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.settings, size: sizes.iconSubtitleFontSize),
            Text(
              " App Settings",
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.halfSpacing),
        AppSettingsSelector<Units>(
          key: const ValueKey('profile-units-selector'),
          value: system.units,
          values: Units.values,
          sizes: sizes,
          titleColor: titleColor,
          onChanged: (Units? newValue) {
            if (!isLoading && newValue != null) {
              cubit.updateSystem(units: newValue);
            }
          },
          getIcon: _getUnitsIcon,
          getText: (Units unit) => unit.name.toUpperCase(),
          iconColor: theme.iconTheme.color,
          label: 'Units',
        ),
        SizedBox(height: sizes.halfSpacing),
        AppSettingsSelector<ThemeType>(
          key: const ValueKey('profile-theme-selector'),
          value: system.theme,
          values: ThemeType.values,
          label: "Theme",
          sizes: sizes,
          titleColor: titleColor,
          onChanged: (ThemeType? newValue) {
            if (!isLoading && newValue != null) {
              cubit.updateSystem(theme: newValue);
            }
          },
          getIcon: _getThemeIcon,
          getText: (ThemeType theme) => theme.name.toUpperCase(),
          iconColor: theme.iconTheme.color,
        ),
      ],
    );
  }

  IconData _getThemeIcon(ThemeType theme) => switch (theme) {
    ThemeType.light => Icons.light_mode,
    ThemeType.dark => Icons.dark_mode,
    ThemeType.system => Icons.brightness_auto,
  };

  IconData _getUnitsIcon(Units unit) => switch (unit) {
    Units.metric => Icons.straighten,
    Units.imperial => Icons.square_foot,
  };
}
