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

import '../../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../view_models/macro_tracking_cubit.dart';
import '../../view_models/states/macro_tracking_state.dart';
import './macro_goal_chip.dart';
import './macro_goal_form_modal.dart';

class MacroGoalsContentWidget extends StatelessWidget {
  final MacroTrackingState state;
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const MacroGoalsContentWidget({
    super.key,
    required this.state,
    required this.theme,
    required this.sizes,
  });

  static const Map<DayOfWeek, String> _dayLabels = {
    DayOfWeek.monday: 'Mon',
    DayOfWeek.tuesday: 'Tue',
    DayOfWeek.wednesday: 'Wed',
    DayOfWeek.thursday: 'Thu',
    DayOfWeek.friday: 'Fri',
    DayOfWeek.saturday: 'Sat',
    DayOfWeek.sunday: 'Sun',
  };

  String _formatDays(List<DayOfWeek> days) {
    final sorted = List<DayOfWeek>.from(days)
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.map((d) => _dayLabels[d] ?? '').join(', ');
  }

  Widget _buildCyclingSchedule(MacroGoalDto goal) {
    if (goal.goalType != MacroGoalType.calorieCycling || goal.days.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: sizes.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule (${goal.totalTargetCalories} kcal / week)',
            style: TextStyle(
              fontSize: sizes.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sizes.spacing / 2),
          for (final dayGroup in goal.days)
            Padding(
              padding: EdgeInsets.only(bottom: sizes.spacing / 2),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(sizes.padding * 0.75),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDays(dayGroup.days),
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: sizes.spacing / 4),
                    Text(
                      '${dayGroup.targetCalories} kcal • P: ${dayGroup.targetProtein}g C: ${dayGroup.targetCarbs}g F: ${dayGroup.targetFat}g'
                      '${dayGroup.targetWaterIntakeMl != null ? ' • Water: ${dayGroup.targetWaterIntakeMl}ml' : ''}',
                      style: TextStyle(fontSize: sizes.smallFontSize),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeGoal = state.activeGoal;
    final history = state.goalHistory
        .where((g) => g.id != activeGoal?.id)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Macro Goal Card
          if (activeGoal == null)
            Card(
              margin: EdgeInsets.zero,
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  key: const ValueKey('macro-goal-set-button'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          MacroGoalFormModal(theme: theme, sizes: sizes),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: sizes.padding * 2,
                      horizontal: sizes.padding,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.track_changes,
                          size: sizes.titleFontSize * 2,
                        ),
                        SizedBox(height: sizes.spacing),
                        Text(
                          'No Active Macro Goal',
                          style: TextStyle(
                            fontSize: sizes.titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[200]
                                : Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: sizes.spacing),
                        Text(
                          'Create a macro goal',
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(sizes.padding * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: sizes.spacing,
                      runSpacing: sizes.spacing,
                      children: [
                        Text(
                          'Active Macro Target',
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('macro-goal-edit-btn'),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: sizes.buttonIconSize,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => MacroGoalFormModal(
                                theme: theme,
                                sizes: sizes,
                                existingGoal: activeGoal,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.spacing / 2),
                    Text(
                      '${activeGoal.name} • ${activeGoal.goalType == MacroGoalType.calorieCycling ? 'Calorie Cycling' : 'Flat Week'}',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: sizes.spacing / 4),
                    Text(
                      activeGoal.goalType == MacroGoalType.calorieCycling
                          ? 'Daily Average: ${activeGoal.targetCalories} kcal / day'
                          : '${activeGoal.targetCalories} kcal / day',
                      style: TextStyle(
                        fontSize: sizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: sizes.spacing),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: sizes.spacing / 2,
                      runSpacing: sizes.spacing / 2,
                      children: [
                        MacroGoalChip(
                          label: 'Protein',
                          value: '${activeGoal.targetProtein}g',
                          color: Colors.blue,
                          sizes: sizes,
                        ),
                        SizedBox(width: sizes.spacing),
                        MacroGoalChip(
                          label: 'Carbs',
                          value: '${activeGoal.targetCarbs}g',
                          color: Colors.amber,
                          sizes: sizes,
                        ),
                        SizedBox(width: sizes.spacing),
                        MacroGoalChip(
                          label: 'Fat',
                          value: '${activeGoal.targetFat}g',
                          color: Colors.red,
                          sizes: sizes,
                        ),
                        if (activeGoal.targetWaterIntakeMl != null) ...[
                          SizedBox(width: sizes.spacing),
                          MacroGoalChip(
                            label: 'Water',
                            value: '${activeGoal.targetWaterIntakeMl}ml',
                            color: Colors.cyan,
                            sizes: sizes,
                          ),
                        ],
                      ],
                    ),
                    _buildCyclingSchedule(activeGoal),
                    SizedBox(height: sizes.spacing),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: sizes.spacing,
                      runSpacing: sizes.spacing,
                      children: [
                        TextButton.icon(
                          key: const ValueKey('macro-goal-deactivate-btn'),
                          icon: Icon(
                            Icons.stop_circle_outlined,
                            color: Colors.orange,
                            size: sizes.buttonIconSize,
                          ),
                          label: Text(
                            'Deactivate',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: sizes.fontSize,
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<MacroTrackingCubit>()
                                .completeMacroGoal(activeGoal.id);
                          },
                        ),
                        SizedBox(width: sizes.spacing),
                        TextButton.icon(
                          key: const ValueKey('macro-goal-delete-btn'),
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: sizes.buttonIconSize,
                          ),
                          label: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: sizes.fontSize,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmationDialog(
                                title: 'Delete Macro Goal',
                                content: 'Are you sure you want to delete this macro goal?',
                                onConfirm: () {
                                  context
                                      .read<MacroTrackingCubit>()
                                      .deleteMacroGoal(activeGoal.id);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: sizes.spacing * 2),
          Text(
            'Goal History',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: sizes.spacing),
          history.isEmpty
              ? Center(
                  child: Text(
                    'No past macro goals.',
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: sizes.spacing / 2),
                  itemBuilder: (context, index) {
                    final g = history[index];

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: Text(
                          '${g.goalType == MacroGoalType.calorieCycling ? 'Daily Average: ' : ''}'
                          '${g.targetCalories} kcal • P: ${g.targetProtein}g C: ${g.targetCarbs}g F: ${g.targetFat}g',
                          style: TextStyle(
                            fontSize: sizes.fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${g.goalType == MacroGoalType.calorieCycling ? 'Calorie Cycling • ' : ''}'
                          'Water: ${g.targetWaterIntakeMl ?? 0}ml • ${g.name}',
                          style: TextStyle(
                            fontSize: sizes.fontSize * 0.9,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                            size: sizes.buttonIconSize,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmationDialog(
                                title: 'Delete Past Goal',
                                content: 'Are you sure you want to delete this past goal?',
                                onConfirm: () {
                                  context
                                      .read<MacroTrackingCubit>()
                                      .deleteMacroGoal(g.id);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
