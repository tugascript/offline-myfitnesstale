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

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/dates.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../view_models/macro_tracking_cubit.dart';
import '../../view_models/states/macro_tracking_state.dart';
import 'macro_tracker_date_navigator.dart';

class MacroTrackerWeekWidget extends StatelessWidget {
  static final _dayFormat = DateFormat('EEEE, MMM d');

  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  const MacroTrackerWeekWidget({
    required this.theme,
    super.key,
    required this.sizes,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      buildWhen: (previous, current) =>
          !listEquals(previous.rangeLogs, current.rangeLogs) ||
          previous.activeGoal != current.activeGoal,
      builder: (context, state) {
        final logs = state.rangeLogs;
        final today = DateUtils.dateOnly(DateTime.now());
        final minDate = MacroTrackerDateNavigator.defaultFirstDate(today);
        final startOfWeek = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day - (selectedDate.weekday - 1),
        );

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: sizes.halfSpacing),
          itemCount: 7,
          separatorBuilder: (_, _) => SizedBox(height: sizes.halfSpacing),
          itemBuilder: (context, index) {
            final dayDate = DateTime(
              startOfWeek.year,
              startOfWeek.month,
              startOfWeek.day + index,
            );
            final isOutOfRange =
                dayDate.isAfter(today) || dayDate.isBefore(minDate);
            final numDate = DateUtilities.getNumericDate(dayDate);
            final dayLog = logs.where((l) => l.date == numDate);
            final log = dayLog.isNotEmpty ? dayLog.first : null;
            final targetCal = state.activeGoal
                ?.effectiveGoalForDate(dayDate)
                .targetCalories;

            final isSelectedDay =
                !isOutOfRange && DateUtils.isSameDay(dayDate, selectedDate);

            return Card(
              color: isSelectedDay
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : null,
              margin: EdgeInsets.zero,
              child: Opacity(
                opacity: isOutOfRange ? 0.5 : 1,
                child: ListTile(
                  enabled: !isOutOfRange,
                  title: Text(
                    _dayFormat.format(dayDate),
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      fontWeight: FontWeight.bold,
                      color: isOutOfRange ? theme.disabledColor : null,
                    ),
                  ),
                  subtitle: Text(
                    log != null
                        ? '${log.totalCalories}${targetCal != null ? ' / $targetCal' : ''} kcal • P: ${log.totalProtein}g C: ${log.totalCarbs}g F: ${log.totalFat}g'
                        : 'No foods logged${targetCal != null ? ' • Target: $targetCal kcal' : ''}',
                    style: TextStyle(
                      fontSize: sizes.fontSize * 0.85,
                      color: isOutOfRange
                          ? theme.disabledColor
                          : Colors.grey[600],
                    ),
                  ),
                  trailing: isOutOfRange
                      ? null
                      : Icon(Icons.chevron_right, size: sizes.buttonIconSize),
                  onTap: isOutOfRange
                      ? null
                      : () {
                          onSelectDate(dayDate);
                        },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
