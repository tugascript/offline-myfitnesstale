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

import '../../../data/repositories/recipes/dtos/recipe_dto.dart';
import '../../core/sizes/data_display_sizes.dart';

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
