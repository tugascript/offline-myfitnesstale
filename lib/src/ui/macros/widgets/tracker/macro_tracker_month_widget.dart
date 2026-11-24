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

class MacroTrackerMonthWidget extends StatelessWidget {
  static final _dayFormat = DateFormat('EEE, MMM d');

  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  const MacroTrackerMonthWidget({
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
        final daysInMonth = DateTime(
          selectedDate.year,
          selectedDate.month + 1,
          0,
        ).day;

        return ListView.separated(
          itemCount: daysInMonth,
          shrinkWrap: true,
          separatorBuilder: (_, _) => SizedBox(height: sizes.quarterSpacing),
          itemBuilder: (context, index) {
            final dayDate = DateTime(
              selectedDate.year,
              selectedDate.month,
              index + 1,
            );
            final isOutOfRange =
                dayDate.isAfter(today) || dayDate.isBefore(minDate);
            final isSelectedDay =
                !isOutOfRange && DateUtils.isSameDay(dayDate, selectedDate);
            final numDate = DateUtilities.getNumericDate(dayDate);
            final dayLog = logs.where((l) => l.date == numDate);
            final log = dayLog.isNotEmpty ? dayLog.first : null;
            final targetCal = state.activeGoal
                ?.effectiveGoalForDate(dayDate)
                .targetCalories;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                index == 0 ? sizes.halfSpacing : sizes.quarterSpacing,
                0,
                index == (daysInMonth - 1)
                    ? sizes.halfSpacing
                    : sizes.quarterSpacing,
              ),
              child: Card(
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
                        color: isOutOfRange ? theme.disabledColor : null,
                      ),
                    ),
                    subtitle: targetCal != null
                        ? Text(
                            'Target: $targetCal kcal',
                            style: TextStyle(
                              fontSize: sizes.smallFontSize,
                              color: isOutOfRange
                                  ? theme.disabledColor
                                  : Colors.grey[600],
                            ),
                          )
                        : null,
                    trailing: Text(
                      log != null ? '${log.totalCalories} kcal' : '-',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.bold,
                        color: isOutOfRange
                            ? theme.disabledColor
                            : log != null
                            ? theme.primaryColor
                            : Colors.grey,
                      ),
                    ),
                    onTap: isOutOfRange
                        ? null
                        : () {
                            onSelectDate(dayDate);
                          },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
