import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/dtos/macro_tracking_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

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
