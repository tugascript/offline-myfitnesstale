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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/utils/dates.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../view_models/macro_tracking_cubit.dart';
import '../view_models/states/macro_tracking_state.dart';

class MacroTrackerMonthWidget extends StatelessWidget {
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
      builder: (context, state) {
        final logs = state.rangeLogs;
        final daysInMonth = DateTime(
          selectedDate.year,
          selectedDate.month + 1,
          0,
        ).day;

        return ListView.separated(
          itemCount: daysInMonth,
          separatorBuilder: (_, _) => SizedBox(height: sizes.spacing / 2),
          itemBuilder: (context, index) {
            final dayDate = DateTime(
              selectedDate.year,
              selectedDate.month,
              index + 1,
            );
            final numDate = DateUtilities.getNumericDate(dayDate);
            final dayLog = logs.where((l) => l.date == numDate);
            final log = dayLog.isNotEmpty ? dayLog.first : null;
            final targetCal = state.activeGoal
                ?.effectiveGoalForDate(dayDate)
                .targetCalories;

            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(
                  DateFormat('EEE, MMM d').format(dayDate),
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
                subtitle: targetCal != null
                    ? Text(
                        'Target: $targetCal kcal',
                        style: TextStyle(
                          fontSize: sizes.smallFontSize,
                          color: Colors.grey[600],
                        ),
                      )
                    : null,
                trailing: Text(
                  log != null ? '${log.totalCalories} kcal' : '-',
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                    color: log != null ? theme.primaryColor : Colors.grey,
                  ),
                ),
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
