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
import 'package:intl/intl.dart';

import '../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../core/sizes/data_display_sizes.dart';

class NutritionLogEntry extends StatelessWidget {
  final MealLogItemDto item;
  final DateTime logTime;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onDelete;

  const NutritionLogEntry({
    super.key,
    required this.item,
    required this.logTime,
    required this.sizes,
    required this.theme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = item.foodId == null
        ? '${item.amount} serving${item.amount == 1 ? '' : 's'}'
        : item.portionName != null
        ? '${item.amount} × ${item.portionName}'
        : '${item.amount}g';
    return Container(
      margin: EdgeInsets.only(top: sizes.spacing / 2),
      padding: EdgeInsets.all(sizes.padding / 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('HH:mm').format(logTime.toLocal()),
                  style: TextStyle(
                    fontSize: sizes.smallFontSize,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.loggedFoodName,
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$quantity · ${item.loggedCalories} kcal',
                  style: TextStyle(fontSize: sizes.smallFontSize),
                ),
                Text(
                  'P ${item.loggedProtein}g · C ${item.loggedCarbs}g · F ${item.loggedFat}g',
                  style: TextStyle(
                    fontSize: sizes.smallFontSize,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete ${item.loggedFoodName}',
            icon: Icon(Icons.delete_outline, size: sizes.compactIconSize),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
