import 'package:flutter/material.dart';
import '../../services/dtos/meal_plan_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class MealPlanListItemWidget extends StatelessWidget {
  final MealPlanDto plan;
  final DataDisplaySizesList sizes;
  final VoidCallback onStart;
  final VoidCallback onView;
  final VoidCallback onToggleFavorite;

  const MealPlanListItemWidget(
      {super.key,
      required this.plan,
      required this.sizes,
      required this.onStart,
      required this.onView,
      required this.onToggleFavorite});
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
                        plan.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: plan.isFavorite ? Colors.red : Colors.grey,
                        size: sizes.buttonIconSize),
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
                    child: Text('View Plan',
                        style: TextStyle(fontSize: sizes.fontSize)),
                  ),
                  ElevatedButton.icon(
                    key: ValueKey('meal-plan-start-btn-${plan.id}'),
                    icon: Icon(Icons.play_arrow, size: sizes.buttonIconSize),
                    label: Text('Start Plan',
                        style: TextStyle(fontSize: sizes.fontSize)),
                    onPressed: onStart,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
