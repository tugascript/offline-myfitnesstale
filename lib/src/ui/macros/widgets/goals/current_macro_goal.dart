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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../view_models/macro_tracking_cubit.dart';
import './macro_goal_chip.dart';
import './macro_goal_form_modal.dart';

const _skeletonMacroGoal = MacroGoalDto(
  id: 0,
  name: 'Daily Macro Target',
  targetCalories: 2000,
  targetProtein: 150,
  targetCarbs: 200,
  targetFat: 65,
  targetWaterIntakeMl: 2500,
  isActive: true,
  phase: WeightGoalPhase.maintain,
);

class CurrentMacroGoal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MacroGoalDto? goal;
  final bool isLoading;
  final ValueChanged<MacroGoalDto>? onEditGoal;

  const CurrentMacroGoal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.goal,
    this.isLoading = false,
    this.onEditGoal,
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

  Widget _buildCyclingSchedule(MacroGoalDto displayGoal) {
    if (displayGoal.goalType != MacroGoalType.calorieCycling ||
        displayGoal.days.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: sizes.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule (${displayGoal.totalTargetCalories} kcal / week)',
            style: TextStyle(
              fontSize: sizes.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sizes.spacing / 2),
          for (final dayGroup in displayGoal.days)
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
    final isSkeleton = isLoading || goal == null;
    final activeGoal = goal;
    final displayGoal = activeGoal ?? _skeletonMacroGoal;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(sizes.padding * 1.5),
          child: Skeletonizer(
            enabled: isSkeleton,
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
                      onPressed: isSkeleton || activeGoal == null
                          ? null
                          : () {
                              if (onEditGoal != null) {
                                onEditGoal!(activeGoal);
                                return;
                              }
                              showDialog<void>(
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
                  '${displayGoal.name} • ${displayGoal.goalType == MacroGoalType.calorieCycling ? 'Calorie Cycling' : 'Flat Week'}',
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: sizes.spacing / 4),
                Text(
                  displayGoal.goalType == MacroGoalType.calorieCycling
                      ? 'Daily Average: ${displayGoal.targetCalories} kcal / day'
                      : '${displayGoal.targetCalories} kcal / day',
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
                      value: '${displayGoal.targetProtein}g',
                      color: Colors.blue,
                      sizes: sizes,
                    ),
                    SizedBox(width: sizes.spacing),
                    MacroGoalChip(
                      label: 'Carbs',
                      value: '${displayGoal.targetCarbs}g',
                      color: Colors.amber,
                      sizes: sizes,
                    ),
                    SizedBox(width: sizes.spacing),
                    MacroGoalChip(
                      label: 'Fat',
                      value: '${displayGoal.targetFat}g',
                      color: Colors.red,
                      sizes: sizes,
                    ),
                    if (displayGoal.targetWaterIntakeMl != null) ...[
                      SizedBox(width: sizes.spacing),
                      MacroGoalChip(
                        label: 'Water',
                        value: '${displayGoal.targetWaterIntakeMl}ml',
                        color: Colors.cyan,
                        sizes: sizes,
                      ),
                    ],
                  ],
                ),
                _buildCyclingSchedule(displayGoal),
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
                      onPressed: isSkeleton || activeGoal == null
                          ? null
                          : () {
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
                      onPressed: isSkeleton || activeGoal == null
                          ? null
                          : () {
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
      ),
    );
  }
}
