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

import '../../../../data/utils/dates.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../view_models/macro_tracking_cubit.dart';
import '../../view_models/states/macro_tracking_state.dart';
import '../log_food_modal.dart';
import '../nutrition_timeline_widget.dart';
import 'macro_progress_bar.dart';

class MacroTrackerDayWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final DateTime selectedDate;

  const MacroTrackerDayWidget({
    required this.theme,
    super.key,
    required this.sizes,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final selectedNumericDate = DateUtilities.getNumericDate(selectedDate);
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      buildWhen: (previous, current) =>
          previous.selectedDailyLog != current.selectedDailyLog ||
          previous.activeGoal != current.activeGoal,
      builder: (context, state) {
        final rawDailyLog = state.selectedDailyLog;
        final isLogSynced =
            rawDailyLog != null && rawDailyLog.date == selectedNumericDate;
        final dailyLog = isLogSynced ? rawDailyLog : null;
        final activeGoal = state.activeGoal;
        final dayGoal = activeGoal?.effectiveGoalForDate(selectedDate);

        final currentCal = dailyLog?.totalCalories ?? 0;
        final targetCal = dayGoal?.targetCalories ?? 2000;
        final calProgress = targetCal > 0
            ? (currentCal / targetCal).clamp(0.0, 1.0)
            : 0.0;

        final currentProtein = dailyLog?.totalProtein ?? 0;
        final targetProtein = dayGoal?.targetProtein ?? 150;

        final currentCarbs = dailyLog?.totalCarbs ?? 0;
        final targetCarbs = dayGoal?.targetCarbs ?? 200;

        final currentFat = dailyLog?.totalFat ?? 0;
        final targetFat = dayGoal?.targetFat ?? 65;

        final currentWater = dailyLog?.waterIntakeMl ?? 0;
        final targetWater = dayGoal?.targetWaterIntakeMl ?? 2500;

        return ListView(
          children: [
            SizedBox(height: sizes.halfSpacing),
            // Macro Target Summary Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(sizes.padding / 1.5),
                child: Column(
                  children: [
                    Text(
                      'Calories: $currentCal / $targetCal kcal',
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: sizes.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: sizes.spacing),
                    LinearProgressIndicator(
                      value: calProgress,
                      minHeight: sizes.halfSpacing,
                      borderRadius: BorderRadius.zero,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: sizes.spacing),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final minWidth = MediaQuery.textScalerOf(context)
                            .scale(sizes.fontSize * 7);
                        final columns =
                            ((constraints.maxWidth + sizes.spacing) /
                                    (minWidth + sizes.spacing))
                                .floor()
                                .clamp(1, 3);
                        final width =
                            (constraints.maxWidth -
                                sizes.spacing * (columns - 1)) /
                            columns;
                        final metrics = <Widget>[
                          MacroProgressBar(
                            label: 'Protein',
                            current: currentProtein,
                            target: targetProtein,
                            unit: 'g',
                            color: Colors.blue,
                            sizes: sizes,
                          ),
                          MacroProgressBar(
                            label: 'Carbs',
                            current: currentCarbs,
                            target: targetCarbs,
                            unit: 'g',
                            color: Colors.amber,
                            sizes: sizes,
                          ),
                          MacroProgressBar(
                            label: 'Fat',
                            current: currentFat,
                            target: targetFat,
                            unit: 'g',
                            color: Colors.red,
                            sizes: sizes,
                          ),
                        ];
                        return Wrap(
                          spacing: sizes.spacing,
                          runSpacing: sizes.spacing / 2,
                          children: [
                            for (final metric in metrics)
                              SizedBox(width: width, child: metric),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sizes.spacing),
            // Water Intake Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(sizes.padding / 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.cyan,
                          size: sizes.buttonIconSize,
                        ),
                        SizedBox(width: sizes.spacing),
                        Expanded(
                          child: Text(
                            'Water: $currentWater / $targetWater ml',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.remove, size: sizes.compactIconSize),
                          onPressed: isLogSynced
                              ? () {
                                  final newWater = (currentWater - 250).clamp(
                                    0,
                                    100000,
                                  );
                                  context
                                      .read<MacroTrackingCubit>()
                                      .updateWaterIntake(
                                        newWater,
                                        date: selectedDate,
                                      );
                                }
                              : null,
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.add, size: sizes.compactIconSize),
                          onPressed: isLogSynced
                              ? () {
                                  context
                                      .read<MacroTrackingCubit>()
                                      .updateWaterIntake(
                                        currentWater + 250,
                                        date: selectedDate,
                                      );
                                }
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.halfSpacing),
                    LinearProgressIndicator(
                      value: targetWater > 0
                          ? (currentWater / targetWater).clamp(0.0, 1.0)
                          : 0.0,
                      color: Colors.cyan,
                      backgroundColor: Colors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.zero,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sizes.spacing * 1.5),
            NutritionTimelineWidget(
              meals: dailyLog?.meals ?? const [],
              selectedDate: selectedDate,
              theme: theme,
              sizes: sizes,
              onAdd: (hour) => showDialog(
                context: context,
                builder: (_) => LogFoodModal(
                  theme: theme,
                  sizes: sizes,
                  selectedDate: selectedDate,
                  initialTime: TimeOfDay(hour: hour, minute: 0),
                ),
              ),
              onDelete: (item) => showDialog(
                context: context,
                builder: (_) => ConfirmationDialog(
                  title: 'Delete Item',
                  content: 'Are you sure you want to remove this logged food?',
                  onConfirm: () => context
                      .read<MacroTrackingCubit>()
                      .deleteMealLogItem(item.id),
                ),
              ),
            ),
            SizedBox(height: sizes.buttonSize * 1.5),
          ],
        );
      },
    );
  }
}
