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
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/time_of_day_value.dart';
import '../../../../data/utils/weekday_time_of_day_value.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/themes/colors.dart';
import '../../../core/utils/formatters.dart';
import '../../view_models/profile_cubit.dart';
import 'reminder_toggle_row.dart';
import 'reminder_weekday_toggle_row.dart';

class RemindersSettingsConfig extends StatefulWidget {
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
  State<RemindersSettingsConfig> createState() =>
      _RemindersSettingsConfigState();
}

class _RemindersSettingsConfigState extends State<RemindersSettingsConfig> {
  bool _isUpdatingReminder = false;

  Future<void> _updateReminder(
    bool value,
    Future<void> Function(bool) update,
  ) async {
    if (widget.isLoading || _isUpdatingReminder) return;
    setState(() => _isUpdatingReminder = true);
    try {
      final cubit = context.read<ProfileCubit>();
      if (value) {
        final granted = await cubit.requestNotificationPermission();
        if (!mounted) return;
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                cubit.state.error?.description ?? 'Please enable notifications in settings before enabling reminders.',
              ),
            ),
          );
          return;
        }
      }
      await update(value);
    } finally {
      if (mounted) setState(() => _isUpdatingReminder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remindersConfig = widget.remindersConfig;
    final sizes = widget.sizes;
    final theme = widget.theme;
    final isLoading = widget.isLoading || _isUpdatingReminder;
    final cubit = context.read<ProfileCubit>();
    final titleColor = ThemedColors.themedGrey.fromBrightness(theme.brightness);

    return Column(
      key: const ValueKey('profile-reminders-settings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.notifications, size: sizes.iconSubtitleFontSize),
            Text(
              " Reminders",
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.halfSpacing),
        ReminderToggleRow(
          switchKey: const ValueKey('reminder-workouts'),
          timeKey: const ValueKey('reminder-workouts-time'),
          value: remindersConfig.workoutsOn,
          label: "Workouts",
          timeLabel: Formatters.formatTimeOfDay(
            remindersConfig.workoutsReminderTime,
          ),
          sizes: sizes,
          theme: theme,
          titleColor: titleColor,
          isLoading: isLoading,
          onChanged: (value) => _updateReminder(
            value,
            (enabled) => cubit.updateRemindersConfig(workoutsOn: enabled),
          ),
          onTimeTap: () => _pickClockTime(
            context: context,
            currentTime: remindersConfig.workoutsReminderTime,
            onSelected: (updated) {
              cubit.updateRemindersConfig(workoutsReminderTime: updated);
            },
          ),
        ),
        SizedBox(height: sizes.spacing),
        ReminderToggleRow(
          switchKey: const ValueKey('reminder-macro-tracking'),
          timeKey: const ValueKey('reminder-macro-tracking-time'),
          value: remindersConfig.macroTrackingOn,
          label: "Macro Tracking",
          timeLabel: Formatters.formatTimeOfDay(
            remindersConfig.macroTrackingReminderTime,
          ),
          sizes: sizes,
          theme: theme,
          titleColor: titleColor,
          isLoading: isLoading,
          onChanged: (value) => _updateReminder(
            value,
            (enabled) => cubit.updateRemindersConfig(macroTrackingOn: enabled),
          ),
          onTimeTap: () => _pickClockTime(
            context: context,
            currentTime: remindersConfig.macroTrackingReminderTime,
            onSelected: (updated) {
              cubit.updateRemindersConfig(macroTrackingReminderTime: updated);
            },
          ),
        ),
        SizedBox(height: sizes.spacing),
        ReminderWeekdayToggleRow(
          switchKey: const ValueKey('reminder-weight-records'),
          dayKey: const ValueKey('reminder-weight-records-day'),
          timeKey: const ValueKey('reminder-weight-records-time'),
          value: remindersConfig.weightRecordsOn,
          label: "Weight Records",
          dayOfWeek: remindersConfig.weightRecordsReminderTime.dayOfWeek,
          timeLabel: Formatters.formatTimeOfDay(
            remindersConfig.weightRecordsReminderTime.timeOfDay,
          ),
          sizes: sizes,
          theme: theme,
          titleColor: titleColor,
          isLoading: isLoading,
          onChanged: (value) => _updateReminder(
            value,
            (enabled) => cubit.updateRemindersConfig(weightRecordsOn: enabled),
          ),
          onDayChanged: (DayOfWeek newDay) {
            cubit.updateRemindersConfig(
              weightRecordsReminderTime: remindersConfig
                  .weightRecordsReminderTime
                  .copyWith(dayOfWeek: newDay),
            );
          },
          onTimeTap: () => _pickWeekdayClockTime(
            context: context,
            current: remindersConfig.weightRecordsReminderTime,
            onSelected: (updated) {
              cubit.updateRemindersConfig(weightRecordsReminderTime: updated);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickClockTime({
    required BuildContext context,
    required TimeOfDayValue currentTime,
    required ValueChanged<TimeOfDayValue> onSelected,
  }) async {
    if (widget.isLoading || _isUpdatingReminder) {
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
    );
    if (picked != null && context.mounted) {
      onSelected(TimeOfDayValue(hour: picked.hour, minute: picked.minute));
    }
  }

  Future<void> _pickWeekdayClockTime({
    required BuildContext context,
    required WeekdayTimeOfDayValue current,
    required ValueChanged<WeekdayTimeOfDayValue> onSelected,
  }) async {
    if (widget.isLoading || _isUpdatingReminder) {
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked != null && context.mounted) {
      onSelected(
        current.copyWith(
          timeOfDay: TimeOfDayValue(hour: picked.hour, minute: picked.minute),
        ),
      );
    }
  }
}
