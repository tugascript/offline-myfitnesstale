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

import '../../../../data/repositories/profile/dtos/reminders_config_dto.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/themes/colors.dart';
import '../../view_models/profile_cubit.dart';

class RemindersSettingsConfig extends StatelessWidget {
  final RemindersConfigDto remindersConfig;
  final bool isLoading;
  final int profileId;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;

  const RemindersSettingsConfig({
    super.key,
    required this.remindersConfig,
    required this.isLoading,
    required this.profileId,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final labelWidth = sizes.subtitleFontSize * 7;
    final titleColor = isDarkTheme
        ? ThemedColors.themedGrey.light
        : ThemedColors.themedGrey.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reminders",
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        _ReminderToggle(
          switchKey: const ValueKey('reminder-workouts'),
          value: remindersConfig.workoutsOn,
          label: "Workouts",
          labelWidth: labelWidth,
          fontSize: sizes.subtitleFontSize,
          padding: sizes.padding,
          titleColor: titleColor,
          onChanged: (value) {
            if (!isLoading) {
              cubit.updateRemindersConfig(
                workoutsOn: value,
                weightRecordsOn: remindersConfig.weightRecordsOn,
              );
            }
          },
        ),
        _ReminderToggle(
          switchKey: const ValueKey('reminder-weight-records'),
          value: remindersConfig.weightRecordsOn,
          label: "Weight Records",
          labelWidth: labelWidth,
          fontSize: sizes.subtitleFontSize,
          padding: sizes.padding,
          titleColor: titleColor,
          onChanged: (value) {
            if (!isLoading) {
              cubit.updateRemindersConfig(
                workoutsOn: remindersConfig.workoutsOn,
                weightRecordsOn: value,
              );
            }
          },
        ),
      ],
    );
  }
}

class _ReminderToggle extends StatelessWidget {
  final bool value;
  final String label;
  final double labelWidth;
  final double fontSize;
  final double padding;
  final Color titleColor;
  final ValueChanged<bool> onChanged;
  final Key switchKey;

  const _ReminderToggle({
    required this.switchKey,
    required this.value,
    required this.label,
    required this.labelWidth,
    required this.fontSize,
    required this.padding,
    required this.titleColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),
          Switch(key: switchKey, value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
