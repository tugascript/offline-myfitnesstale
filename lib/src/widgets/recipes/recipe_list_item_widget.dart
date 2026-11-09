import 'package:flutter/material.dart';

import '../../services/dtos/recipe_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class RecipeListItemWidget extends StatelessWidget {
  final RecipeDto recipe;
  final DataDisplaySizesList sizes;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const RecipeListItemWidget({
    super.key,
    required this.recipe,
    required this.sizes,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      title: Text(
        recipe.name,
        style: TextStyle(fontSize: sizes.fontSize, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Serving: ${recipe.servingCalories} kcal • P: ${recipe.servingProtein}g C: ${recipe.servingCarbs}g F: ${recipe.servingFat}g'
        '\nServings: ${recipe.servingsYield}',
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
            tooltip: recipe.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
            icon: Icon(
              recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: recipe.isFavorite ? Colors.red : Colors.grey,
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
