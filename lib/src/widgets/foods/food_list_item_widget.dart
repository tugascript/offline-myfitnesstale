import 'package:flutter/material.dart';

import '../../services/dtos/food_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class FoodListItemWidget extends StatelessWidget {
  final FoodDto food;
  final DataDisplaySizesList sizes;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const FoodListItemWidget({
    super.key,
    required this.food,
    required this.sizes,
    required this.onTap,
    required this.onToggleFavorite,
  });
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      title: Text(
        food.name,
        style: TextStyle(fontSize: sizes.fontSize, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${food.caloriesBase} kcal • P: ${food.proteinBase}g C: ${food.carbsBase}g F: ${food.fatBase}g'
        '${food.brand != null ? ' • ${food.brand}' : ''}',
        style: TextStyle(
          fontSize: sizes.fontSize * 0.9,
          color: Colors.grey[600],
        ),
      ),
      trailing: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: sizes.spacing / 2,
        runSpacing: sizes.spacing / 2,
        children: [
          IconButton(
            icon: Icon(
              food.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: food.isFavorite ? Colors.red : Colors.grey,
              size: sizes.buttonIconSize,
            ),
            onPressed: onToggleFavorite,
          ),
          Icon(Icons.chevron_right, size: sizes.buttonIconSize),
        ],
      ),
      onTap: onTap,
    ),
  );
}
