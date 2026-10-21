import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../../views/equipments/equipments_view.dart';
import '../../views/exercise_progress_view.dart';
import '../../views/exercises/exercises_view.dart';
import '../../views/exercises/strength_goals_view.dart';
import '../../views/foods/foods_view.dart';
import '../../views/macro_goals/macro_goals_view.dart';
import '../../views/meal_plans/meal_plan_list_view.dart';
import '../../views/recipes/recipes_view.dart';
import '../../views/weight/weight_goals_view.dart';
import '../../views/weight/weight_records_view.dart';
import '../../views/workout_plans/workout_plan_list_view.dart';
import '../../views/workouts/workouts_view.dart';
import 'quick_action_category.dart';
import 'quick_action_category_card.dart';
import 'quick_action_destination_sheet.dart';

class QuickActionsWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const QuickActionsWidget({
    super.key,
    required this.theme,
    required this.sizes,
  });

  static const categories = [
    QuickActionCategory(
      id: 'training',
      title: 'Workout Plans',
      subtitle: 'Train and organise your workouts',
      emoji: '🏋️',
      destinations: [
        QuickActionDestination(
          'workouts',
          'Workouts',
          Icons.fitness_center,
          WorkoutsView.routeName,
        ),
        QuickActionDestination(
          'workout-history',
          'Workout History',
          Icons.history,
          WorkoutsView.routeName,
        ),
        QuickActionDestination(
          'workout-plans',
          'Workout Plans',
          Icons.event_note,
          WorkoutPlanListView.routeName,
        ),
        QuickActionDestination(
          'workout-plan-history',
          'Workout Plan History',
          Icons.event_note_outlined,
          WorkoutPlanListView.routeName,
        ),
      ],
    ),
    QuickActionCategory(
      id: 'weight',
      title: 'Weight Goals',
      subtitle: 'Track your weight and targets',
      emoji: '⚖️',
      destinations: [
        QuickActionDestination(
          'weight-records',
          'Weight Records',
          Icons.monitor_weight_outlined,
          WeightRecordsView.routeName,
        ),
        QuickActionDestination(
          'weight-goal',
          'Weight Goals',
          Icons.flag_outlined,
          WeightGoalView.routeName,
        ),
      ],
    ),
    QuickActionCategory(
      id: 'exercises',
      title: 'Exercises',
      subtitle: 'Explore exercises and track progress',
      emoji: '💪',
      destinations: [
        QuickActionDestination(
          'exercises',
          'Exercises',
          Icons.sports_gymnastics,
          ExercisesView.routeName,
        ),
        QuickActionDestination(
          'exercise-progress',
          'Exercise Progress',
          Icons.trending_up,
          ExerciseProgressView.routeName,
        ),
        QuickActionDestination(
          'strength-goals',
          'Strength Goals',
          Icons.emoji_events_outlined,
          StrengthGoalsView.routeName,
        ),
        QuickActionDestination(
          'equipments',
          'Equipment',
          Icons.build_outlined,
          EquipmentsView.routeName,
        ),
      ],
    ),
    QuickActionCategory(
      id: 'nutrition',
      title: 'Nutrition',
      subtitle: 'Plan meals and manage your food',
      emoji: '🍽️',
      destinations: [
        QuickActionDestination(
          'macro-goals',
          'Macro Goals',
          Icons.pie_chart_outline,
          MacroGoalsView.routeName,
        ),
        QuickActionDestination(
          'meal-plans',
          'Meal Plans',
          Icons.restaurant_menu,
          MealPlanListView.routeName,
        ),
        QuickActionDestination(
          'recipe',
          'Recipes',
          Icons.menu_book,
          RecipesView.routeName,
        ),
        QuickActionDestination(
          'food',
          'Foods',
          Icons.lunch_dining_outlined,
          FoodsView.routeName,
        ),
      ],
    ),
  ];

  Future<void> _openCategory(
    BuildContext context,
    QuickActionCategory category,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final sheet = ModalBottomSheetRoute<String>(
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => QuickActionDestinationSheet(
        category: category,
        sizes: sizes,
        theme: theme,
      ),
    );
    final route = await navigator.push(sheet);
    await sheet.completed;
    if (route != null && context.mounted) {
      // The sheet is fully dismissed, so Back returns straight to Home.
      await context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quick Actions',
        style: TextStyle(
          fontSize: sizes.titleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: sizes.spacing),
      LayoutBuilder(
        builder: (context, constraints) {
          final minimumWidth = MediaQuery.textScalerOf(context)
              .scale(sizes.formFieldMinWidth);
          final columns =
              constraints.maxWidth >= minimumWidth * 2 + sizes.spacing ? 2 : 1;
          return Column(
            children: [
              for (
                var start = 0;
                start < categories.length;
                start += columns
              ) ...[
                if (start > 0) SizedBox(height: sizes.inputSpacing),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (
                      var index = start;
                      index < start + columns;
                      index++
                    ) ...[
                      if (index > start) SizedBox(width: sizes.spacing),
                      Expanded(
                        child: QuickActionCategoryCard(
                          key: ValueKey(
                            'quick-action-category-${categories[index].id}',
                          ),
                          category: categories[index],
                          sizes: sizes,
                          theme: theme,
                          onTap: () =>
                              _openCategory(context, categories[index]),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          );
        },
      ),
    ],
  );
}
