import 'package:flutter/material.dart';

import '../../services/dtos/macro_tracking_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'nutrition_log_entry.dart';

class NutritionHourRow extends StatelessWidget {
  final int hour;
  final List<MealLogDto> meals;
  final bool isCurrentHour;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final VoidCallback onAdd;
  final ValueChanged<MealLogItemDto> onDelete;

  const NutritionHourRow({
    super.key,
    required this.hour,
    required this.meals,
    required this.isCurrentHour,
    required this.theme,
    required this.sizes,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${hour.toString().padLeft(2, '0')}:00';
    final color = isCurrentHour
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final calories = meals.fold(0, (sum, meal) => sum + meal.totalCalories);
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color)),
      ),
      padding: EdgeInsets.only(left: sizes.padding, bottom: sizes.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: sizes.spacing,
                  runSpacing: sizes.spacing / 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sizes.padding / 2,
                        vertical: sizes.spacing / 2,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrentHour
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.bold,
                          color: isCurrentHour
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (meals.isNotEmpty)
                      Text(
                        '$calories kcal',
                        style: TextStyle(fontSize: sizes.smallFontSize),
                      ),
                  ],
                ),
              ),
              SizedBox(width: sizes.spacing / 2),
              IconButton.outlined(
                key: ValueKey('nutrition-add-$hour'),
                tooltip: 'Log food at $label',
                style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  side: BorderSide(color: color),
                ),
                icon: Icon(Icons.add, size: sizes.buttonIconSize),
                onPressed: onAdd,
              ),
            ],
          ),
          for (final meal in meals)
            for (final item in meal.items)
              NutritionLogEntry(
                key: ValueKey('nutrition-item-${item.id}'),
                item: item,
                logTime: meal.logTime,
                sizes: sizes,
                theme: theme,
                onDelete: () => onDelete(item),
              ),
        ],
      ),
    );
  }
}
