import 'package:flutter/material.dart';

import '../../services/dtos/macro_tracking_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'nutrition_hour_row.dart';

class NutritionTimelineWidget extends StatelessWidget {
  final List<MealLogDto> meals;
  final DateTime selectedDate;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final ValueChanged<int> onAdd;
  final ValueChanged<MealLogItemDto> onDelete;

  const NutritionTimelineWidget({
    super.key,
    required this.meals,
    required this.selectedDate,
    required this.theme,
    required this.sizes,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(24, (_) => <MealLogDto>[]);
    for (final meal in meals) {
      if (meal.items.isNotEmpty) hours[meal.logTime.toLocal().hour].add(meal);
    }
    for (final hour in hours) {
      hour.sort((a, b) {
        final timeOrder = a.logTime.compareTo(b.logTime);
        return timeOrder == 0 ? a.id.compareTo(b.id) : timeOrder;
      });
    }
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(selectedDate, now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: sizes.spacing),
          child: Text(
            'FOOD TIMELINE',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (var hour = 0; hour < 24; hour++)
          NutritionHourRow(
            key: ValueKey('nutrition-hour-$hour'),
            hour: hour,
            meals: hours[hour],
            isCurrentHour: isToday && now.hour == hour,
            theme: theme,
            sizes: sizes,
            onAdd: () => onAdd(hour),
            onDelete: onDelete,
          ),
      ],
    );
  }
}
