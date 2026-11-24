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
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../routing/routes.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../macros/view_models/macro_tracking_cubit.dart';
import '../../../macros/view_models/states/macro_tracking_state.dart';
import './active_plan_frame.dart';
import './empty_macro_goal.dart';

class ActiveMacroGoalWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool showTitle;

  const ActiveMacroGoalWidget({
    super.key,
    required this.sizes,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      builder: (context, macroState) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final goal = macroState.activeGoal;

        if (goal == null) {
          return EmptyMacroGoal(sizes: sizes, showTitle: showTitle);
        }

        final dayGoal = goal.effectiveGoalForDate(DateTime.now());

        return ActivePlanFrame(
          title: 'Active Macro Goal',
          sizes: sizes,
          showTitle: showTitle,
          child: InkWell(
            key: const ValueKey('active-macro-goal-card'),
            onTap: () => context.push(Routes.macroTracker.name),
            child: Padding(
              padding: EdgeInsets.all(sizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Macro Target',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sizes.padding),
                    decoration: BoxDecoration(color: colors.primaryContainer),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: sizes.fontSize * 2,
                          color: colors.onPrimaryContainer,
                        ),
                        SizedBox(width: sizes.spacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Nutrition',
                                style: TextStyle(
                                  fontSize: sizes.smallFontSize,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                '${dayGoal.targetCalories} kcal',
                                style: TextStyle(
                                  fontSize: sizes.fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  Text(
                    'Protein: ${dayGoal.targetProtein}g • Carbs: ${dayGoal.targetCarbs}g • Fat: ${dayGoal.targetFat}g'
                    '${dayGoal.targetWaterIntakeMl != null ? ' • Water: ${dayGoal.targetWaterIntakeMl}ml' : ''}',
                    style: TextStyle(
                      fontSize: sizes.smallFontSize,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
