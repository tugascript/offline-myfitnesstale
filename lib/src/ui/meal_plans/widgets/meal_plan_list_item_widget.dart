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

import '../../../data/repositories/meal_plans/dtos/meal_plan_dto.dart';
import '../../core/sizes/data_display_sizes.dart';

class MealPlanListItemWidget extends StatelessWidget {
  final MealPlanDto plan;
  final DataDisplaySizesList sizes;
  final VoidCallback onStart;
  final VoidCallback onView;
  final VoidCallback onToggleFavorite;

  const MealPlanListItemWidget({
    super.key,
    required this.plan,
    required this.sizes,
    required this.onStart,
    required this.onView,
    required this.onToggleFavorite,
  });
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: EdgeInsets.all(sizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  plan.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: plan.isFavorite ? Colors.red : Colors.grey,
                  size: sizes.buttonIconSize,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
          if (plan.description != null && plan.description!.isNotEmpty) ...[
            SizedBox(height: sizes.spacing / 4),
            Text(
              plan.description!,
              style: TextStyle(
                fontSize: sizes.fontSize * 0.9,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: sizes.spacing / 2),
          Text(
            '${plan.totalWeeks} weeks • ${plan.totalDays} days • ${plan.totalMeals} meals',
            style: TextStyle(
              fontSize: sizes.fontSize * 0.85,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: sizes.spacing),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: sizes.spacing,
            runSpacing: sizes.spacing,
            children: [
              OutlinedButton(
                key: ValueKey('meal-plan-view-btn-${plan.id}'),
                onPressed: onView,
                child: Text(
                  'View Plan',
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
              ),
              ElevatedButton.icon(
                key: ValueKey('meal-plan-start-btn-${plan.id}'),
                icon: Icon(Icons.play_arrow, size: sizes.buttonIconSize),
                label: Text(
                  'Start Plan',
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
                onPressed: onStart,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
