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

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import './quick_action_category.dart';
import './quick_action_category_card.dart';
import './quick_action_destination_sheet.dart';

class QuickActionsWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const QuickActionsWidget({
    super.key,
    required this.theme,
    required this.sizes,
  });

  static final categories = [
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
          Routes.workouts.name,
        ),
        QuickActionDestination(
          'workout-history',
          'Workout History',
          Icons.history,
          Routes.workoutHistory.name,
        ),
        QuickActionDestination(
          'workout-plans',
          'Workout Plans',
          Icons.event_note,
          Routes.workoutPlanList.name,
        ),
        QuickActionDestination(
          'workout-plan-history',
          'Workout Plan History',
          Icons.event_note_outlined,
          Routes.workoutPlanHistory.name,
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
          Routes.weightRecords.name,
        ),
        QuickActionDestination(
          'weight-goal',
          'Weight Goals',
          Icons.flag_outlined,
          Routes.weightGoal.name,
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
          Routes.exercises.name,
        ),
        QuickActionDestination(
          'exercise-progress',
          'Exercise Progress',
          Icons.trending_up,
          Routes.exerciseProgress.name,
        ),
        QuickActionDestination(
          'strength-goals',
          'Strength Goals',
          Icons.emoji_events_outlined,
          Routes.strengthGoals.name,
        ),
        QuickActionDestination(
          'equipments',
          'Equipment',
          Icons.build_outlined,
          Routes.equipments.name,
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
          Routes.macroGoals.name,
        ),
        QuickActionDestination(
          'meal-plans',
          'Meal Plans',
          Icons.restaurant_menu,
          Routes.mealPlanList.name,
        ),
        QuickActionDestination(
          'recipe',
          'Recipes',
          Icons.menu_book,
          Routes.recipes.name,
        ),
        QuickActionDestination(
          'food',
          'Foods',
          Icons.lunch_dining_outlined,
          Routes.foods.name,
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
