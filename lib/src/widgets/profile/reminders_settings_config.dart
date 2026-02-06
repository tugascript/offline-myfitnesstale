import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../services/dtos/reminders_config_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../layout/expanding_section.dart';

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
    return ExpandingSection(
      icon: Icons.notifications,
      title: "Reminders",
      titleFountSize: sizes.titleFountSize,
      subtitle:
          "Workouts ${_subtitleState(remindersConfig.workoutsOn)} • Weight Records ${_subtitleState(remindersConfig.weightRecordsOn)}",
      subtitleFontSize: sizes.subtitleFontSize,
      padding: sizes.padding / 2,
      children: [
        _ReminderToggle(
          value: remindersConfig.workoutsOn,
          label: "Workouts",
          labelWidth: labelWidth,
          fontSize: sizes.subtitleFontSize,
          padding: sizes.padding / 2,
          isDarkTheme: isDarkTheme,
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
          value: remindersConfig.weightRecordsOn,
          label: "Weight Records",
          labelWidth: labelWidth,
          fontSize: sizes.subtitleFontSize,
          padding: sizes.padding / 2,
          isDarkTheme: isDarkTheme,
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

  String _subtitleState(bool isOn) {
    return isOn ? "On" : "Off";
  }
}

class _ReminderToggle extends StatelessWidget {
  final bool value;
  final String label;
  final double labelWidth;
  final double fontSize;
  final double padding;
  final bool isDarkTheme;
  final ValueChanged<bool> onChanged;

  const _ReminderToggle({
    required this.value,
    required this.label,
    required this.labelWidth,
    required this.fontSize,
    required this.padding,
    required this.isDarkTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
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
                color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
