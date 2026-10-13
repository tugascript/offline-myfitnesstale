import 'package:flutter/material.dart';
import '../../services/dtos/food_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'food_macro_column.dart';

class FoodDetailsWidget extends StatelessWidget {
  final FoodDto food;
  final DataDisplaySizesList sizes;
  final VoidCallback onToggleFavorite;
  const FoodDetailsWidget(
      {super.key,
      required this.food,
      required this.sizes,
      required this.onToggleFavorite});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
              ),
            ),
            IconButton(
              icon: Icon(
                food.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: food.isFavorite ? Colors.red : Colors.grey,
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
                  const Divider(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (food.fiberBase != null)
                        Text('Fiber: ${food.fiberBase}g',
                            style: TextStyle(fontSize: sizes.fontSize)),
                      if (food.sodiumBase != null)
                        Text('Sodium: ${food.sodiumBase}mg',
                            style: TextStyle(fontSize: sizes.fontSize)),
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
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                title: Text(p.portionName),
                subtitle: Text('${p.gramWeight}g'),
              ),
            );
          }),
        SizedBox(height: sizes.spacing * 1.5),
      ]);
}
