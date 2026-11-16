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

import '../../../../routing/routes.dart';
import '../../../core/sizes/data_display_sizes.dart';
import './active_plan_frame.dart';

class EmptyMealPlanOrMacroGoal extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool showTitle;

  const EmptyMealPlanOrMacroGoal({
    super.key,
    required this.sizes,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = sizes.spacing / 3;

    return ActivePlanFrame(
      title: 'Active Meal Plan',
      sizes: sizes,
      showTitle: showTitle,
      child: InkWell(
        key: const ValueKey('empty-active-meal-plan-card'),
        onTap: () => context.push(Routes.mealPlanList.name),
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Icon(Icons.snooze, size: sizes.subtitleFontSize * 2),
                SizedBox(height: spacing),
                Text(
                  'No active meal plan or macro goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  'Start a meal plan or set a daily macro goal',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: sizes.spacing / 2,
                  runSpacing: sizes.spacing / 2,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.push(Routes.mealPlanList.name),
                      icon: Icon(
                        Icons.restaurant_menu,
                        size: sizes.compactIconSize,
                      ),
                      label: Text(
                        'Browse Plans',
                        style: TextStyle(fontSize: sizes.fontSize),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push(Routes.macroGoals.name),
                      icon: Icon(
                        Icons.flag_outlined,
                        size: sizes.compactIconSize,
                      ),
                      label: Text(
                        'Set Macro Goal',
                        style: TextStyle(fontSize: sizes.fontSize),
                      ),
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
