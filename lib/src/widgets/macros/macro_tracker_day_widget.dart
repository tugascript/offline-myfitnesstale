import '../layout/responsive_fields.dart';
import '../../widgets/macros/macro_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/states/macro_tracking_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/macros/log_food_modal.dart';
import '../../views/macro_goals/macro_goals_view.dart';
import 'planned_meals_widget.dart';

class MacroTrackerDayWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final DateTime selectedDate;
  const MacroTrackerDayWidget(
      {required this.theme,
      super.key,
      required this.sizes,
      required this.selectedDate});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      builder: (context, state) {
        final dailyLog = state.selectedDailyLog;
        final activeGoal = state.activeGoal;

        final currentCal = dailyLog?.totalCalories ?? 0;
        final targetCal = activeGoal?.targetCalories ?? 2000;
        final calProgress = (currentCal / targetCal).clamp(0.0, 1.0);

        final currentProtein = dailyLog?.totalProtein ?? 0;
        final targetProtein = activeGoal?.targetProtein ?? 150;

        final currentCarbs = dailyLog?.totalCarbs ?? 0;
        final targetCarbs = activeGoal?.targetCarbs ?? 200;

        final currentFat = dailyLog?.totalFat ?? 0;
        final targetFat = activeGoal?.targetFat ?? 65;

        final currentWater = dailyLog?.waterIntakeMl ?? 0;
        final targetWater = activeGoal?.targetWaterIntakeMl ?? 2500;

        return ListView(
          children: [
            // Active Meal Plan Integration Banner
            PlannedMealsWidget(sizes: sizes, selectedDate: selectedDate),
            SizedBox(height: sizes.spacing),
            // Macro Target Summary Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: sizes.spacing / 2,
                      children: [
                        Text(
                          'Calories: $currentCal / $targetCal kcal',
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (activeGoal == null)
                          TextButton(
                            onPressed: () =>
                                context.push(MacroGoalsView.routeName),
                            child: Text('Set Goal',
                                style: TextStyle(fontSize: sizes.fontSize)),
                          ),
                      ],
                    ),
                    SizedBox(height: sizes.spacing),
                    LinearProgressIndicator(
                      value: calProgress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                    SizedBox(height: sizes.spacing),
                    ResponsiveFields(sizes: sizes, children: [
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
                    ]),
                  ],
                ),
              ),
            ),
            SizedBox(height: sizes.spacing),
            // Water Intake Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop,
                            color: Colors.cyan, size: sizes.buttonIconSize),
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
                          onPressed: () {
                            final newWater =
                                (currentWater - 250).clamp(0, 100000);
                            context
                                .read<MacroTrackingCubit>()
                                .updateWaterIntake(newWater);
                          },
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.add, size: sizes.compactIconSize),
                          onPressed: () {
                            context
                                .read<MacroTrackingCubit>()
                                .updateWaterIntake(currentWater + 250);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.spacing / 2),
                    LinearProgressIndicator(
                      value: (currentWater / targetWater).clamp(0.0, 1.0),
                      color: Colors.cyan,
                      backgroundColor: Colors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sizes.spacing * 1.5),
            // Meal Logs by MealType
            ...MealType.values.map((type) {
              final mealLog = dailyLog?.meals.where((m) => m.mealType == type);
              final hasLog = mealLog != null && mealLog.isNotEmpty;
              final meal = hasLog ? mealLog.first : null;

              return Card(
                margin: EdgeInsets.only(bottom: sizes.padding),
                child: Padding(
                  padding: EdgeInsets.all(sizes.padding),
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
                            type.value[0].toUpperCase() +
                                type.value.substring(1),
                            style: TextStyle(
                              fontSize: sizes.subtitleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: sizes.spacing / 2,
                            runSpacing: sizes.spacing / 2,
                            children: [
                              if (meal != null)
                                Text(
                                  '${meal.totalCalories} kcal',
                                  style: TextStyle(
                                    fontSize: sizes.fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    size: sizes.compactIconSize),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => LogFoodModal(
                                      theme: theme,
                                      sizes: sizes,
                                      initialMealType: type,
                                      selectedDate: selectedDate,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (meal != null && meal.items.isNotEmpty) ...[
                        Divider(height: sizes.spacing),
                        ...meal.items.map((item) {
                          final portionText = item.portionName != null
                              ? '${item.amount} × ${item.portionName}'
                              : '${item.amount}g';
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: sizes.padding / 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.loggedFoodName,
                                        style: TextStyle(
                                          fontSize: sizes.fontSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$portionText • ${item.loggedCalories} kcal (P: ${item.loggedProtein}g C: ${item.loggedCarbs}g F: ${item.loggedFat}g)',
                                        style: TextStyle(
                                          fontSize: sizes.fontSize * 0.85,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      size: sizes.compactIconSize,
                                      color: Colors.grey),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ConfirmationDialog(
                                        title: 'Delete Item',
                                        content:
                                            'Are you sure you want to remove this logged food?',
                                        onConfirm: () {
                                          context
                                              .read<MacroTrackingCubit>()
                                              .deleteMealLogItem(item.id);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
