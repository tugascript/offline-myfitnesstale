// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';

import '../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import './nutrition_hour_row.dart';

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
