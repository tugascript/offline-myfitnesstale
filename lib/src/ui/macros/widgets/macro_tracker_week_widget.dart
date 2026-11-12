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
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/utils/dates.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../view_models/macro_tracking_cubit.dart';
import '../view_models/states/macro_tracking_state.dart';

class MacroTrackerWeekWidget extends StatelessWidget {
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
      builder: (context, state) {
        final logs = state.rangeLogs;
        final startOfWeek = selectedDate.subtract(
          Duration(days: selectedDate.weekday - 1),
        );

        return ListView.separated(
          itemCount: 7,
          separatorBuilder: (_, _) => SizedBox(height: sizes.spacing / 2),
          itemBuilder: (context, index) {
            final dayDate = startOfWeek.add(Duration(days: index));
            final numDate = DateUtilities.getNumericDate(dayDate);
            final dayLog = logs.where((l) => l.date == numDate);
            final log = dayLog.isNotEmpty ? dayLog.first : null;
            final targetCal = state.activeGoal
                ?.effectiveGoalForDate(dayDate)
                .targetCalories;

            final isSelectedDay =
                dayDate.year == selectedDate.year &&
                dayDate.month == selectedDate.month &&
                dayDate.day == selectedDate.day;

            return Card(
              color: isSelectedDay
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : null,
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(
                  DateFormat('EEEE, MMM d').format(dayDate),
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  log != null
                      ? '${log.totalCalories}${targetCal != null ? ' / $targetCal' : ''} kcal • P: ${log.totalProtein}g C: ${log.totalCarbs}g F: ${log.totalFat}g'
                      : 'No foods logged${targetCal != null ? ' • Target: $targetCal kcal' : ''}',
                  style: TextStyle(
                    fontSize: sizes.fontSize * 0.85,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Icon(Icons.chevron_right, size: sizes.buttonIconSize),
                onTap: () {
                  onSelectDate(dayDate);
                },
              ),
            );
          },
        );
      },
    );
  }
}
