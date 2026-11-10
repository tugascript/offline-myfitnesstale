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

import '../../../data/repositories/foods/dtos/food_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import './food_macro_column.dart';

class FoodDetailsWidget extends StatelessWidget {
  final FoodDto food;
  final DataDisplaySizesList sizes;
  final VoidCallback onToggleFavorite;
  const FoodDetailsWidget({
    super.key,
    required this.food,
    required this.sizes,
    required this.onToggleFavorite,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Header with category & favorite
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: sizes.spacing,
        runSpacing: sizes.spacing,
        children: [
          Chip(
            label: Text(
              food.category.value[0].toUpperCase() +
                  food.category.value.substring(1),
              style: TextStyle(fontSize: sizes.fontSize),
            ),
          ),
          IconButton(
            icon: Icon(
              food.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: food.isFavorite ? Colors.red : Colors.grey,
              size: sizes.buttonIconSize,
            ),
            onPressed: onToggleFavorite,
          ),
        ],
      ),
      if (food.brand != null) ...[
        Text(
          'Brand: ${food.brand}',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
      ],
      Text(
        'Serving Size: ${food.servingSizeBaseGrams}g',
        style: TextStyle(fontSize: sizes.fontSize),
      ),
      SizedBox(height: sizes.spacing),
      // Macro summary card
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrition per Serving',
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: sizes.spacing),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: sizes.spacing,
                runSpacing: sizes.spacing,
                children: [
                  FoodMacroColumn(
                    label: 'Calories',
                    value: '${food.caloriesBase} kcal',
                    sizes: sizes,
                    color: Colors.orange,
                  ),
                  FoodMacroColumn(
                    label: 'Protein',
                    value: '${food.proteinBase}g',
                    sizes: sizes,
                    color: Colors.blue,
                  ),
                  FoodMacroColumn(
                    label: 'Carbs',
                    value: '${food.carbsBase}g',
                    sizes: sizes,
                    color: Colors.amber,
                  ),
                  FoodMacroColumn(
                    label: 'Fat',
                    value: '${food.fatBase}g',
                    sizes: sizes,
                    color: Colors.red,
                  ),
                ],
              ),
              if (food.fiberBase != null || food.sodiumBase != null) ...[
                Divider(height: sizes.spacing * 2),
                Wrap(
                  spacing: sizes.spacing,
                  runSpacing: sizes.spacing,
                  children: [
                    if (food.fiberBase != null)
                      Text(
                        'Fiber: ${food.fiberBase}g',
                        style: TextStyle(fontSize: sizes.fontSize),
                      ),
                    if (food.sodiumBase != null)
                      Text(
                        'Sodium: ${food.sodiumBase}mg',
                        style: TextStyle(fontSize: sizes.fontSize),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      SizedBox(height: sizes.spacing),
      // Portions list
      Text(
        'Defined Portions',
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: sizes.spacing / 2),
      if (food.portions.isEmpty)
        Text(
          'No portions defined. Serving size: ${food.servingSizeBaseGrams}g.',
          style: TextStyle(fontSize: sizes.fontSize, color: Colors.grey),
        )
      else
        ...food.portions.map((p) {
          return Card(
            margin: EdgeInsets.only(bottom: sizes.padding / 2),
            child: ListTile(
              title: Text(
                p.portionName,
                style: TextStyle(fontSize: sizes.fontSize),
              ),
              subtitle: Text(
                '${p.gramWeight}g',
                style: TextStyle(fontSize: sizes.fontSize),
              ),
            ),
          );
        }),
      SizedBox(height: sizes.spacing * 1.5),
    ],
  );
}
