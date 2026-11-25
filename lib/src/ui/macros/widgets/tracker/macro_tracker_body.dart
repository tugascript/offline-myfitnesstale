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

import '../../../core/sizes/data_display_sizes.dart';
import '../../utils/tacker_scope.dart';
import '../../utils/tracker_body_states.dart';
import '../../view_models/states/macro_tracking_state.dart';
import 'macro_tracker_content.dart';
import 'macro_tracker_placeholder.dart';

class MacroTrackerBody extends StatelessWidget {
  final MacroTrackingState state;
  final TrackerBodyStates bodyStates;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final TrackerScope scope;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<TrackerScope> onScopeChanged;
  final VoidCallback onLoadRange;
  final void Function(DateTime date, {required bool isCustom, bool resetToDay})
  onDateSelected;
  final VoidCallback onGoToToday;
  final VoidCallback onRetry;
  final VoidCallback onCreateGoal;

  MacroTrackerBody({
    super.key,
    required this.state,
    required this.sizes,
    required this.theme,
    required this.scope,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onScopeChanged,
    required this.onLoadRange,
    required this.onDateSelected,
    required this.onGoToToday,
    required this.onRetry,
    required this.onCreateGoal,
  }) : bodyStates = TrackerBodyStates.fromState(state);

  @override
  Widget build(BuildContext context) => switch (bodyStates) {
    TrackerBodyStates.activeGoal ||
    TrackerBodyStates.waitingForGoal => MacroTrackerContent(
      sizes: sizes,
      theme: theme,
      scope: scope,
      selectedDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      isLoading: bodyStates == TrackerBodyStates.waitingForGoal,
      onScopeChanged: onScopeChanged,
      onLoadRange: onLoadRange,
      onPrevious: () {
        final prev = scope.previousDate(selectedDate, firstDate);
        onDateSelected(prev, isCustom: !DateUtils.isSameDay(prev, lastDate));
      },
      onNext: () {
        final next = scope.nextDate(selectedDate, firstDate, lastDate);
        onDateSelected(next, isCustom: !DateUtils.isSameDay(next, lastDate));
      },
      onDatePicked: (picked) {
        final date = DateUtils.dateOnly(picked);
        if (date.isAfter(lastDate) || date.isBefore(firstDate)) return;
        onDateSelected(date, isCustom: !DateUtils.isSameDay(date, lastDate));
      },
      onGoToToday: onGoToToday,
      onSelectDay: (date) => onDateSelected(
        date,
        isCustom: !DateUtils.isSameDay(date, lastDate),
        resetToDay: true,
      ),
    ),
    TrackerBodyStates.initialGoalError => Padding(
      padding: EdgeInsets.all(sizes.viewPadding),
      child: MacroTrackerPlaceholder(
        sizes: sizes,
        theme: theme,
        errorDescription: (state.activeGoalError ?? state.error)!.description,
        onRetry: onRetry,
      ),
    ),
    TrackerBodyStates.noGoal => Padding(
      padding: EdgeInsets.all(sizes.viewPadding),
      child: MacroTrackerPlaceholder(
        sizes: sizes,
        theme: theme,
        isLoading: state.isLoadingActiveGoal,
        onCreateGoal: onCreateGoal,
      ),
    ),
  };
}
