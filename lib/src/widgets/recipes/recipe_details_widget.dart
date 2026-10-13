import 'package:flutter/material.dart';
import '../../services/dtos/recipe_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'recipe_macro_item.dart';

class RecipeDetailsWidget extends StatelessWidget {
  final RecipeDto recipe;
  final DataDisplaySizesList sizes;

  const RecipeDetailsWidget(
      {super.key, required this.recipe, required this.sizes});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: sizes.spacing,
          runSpacing: sizes.spacing,
          children: [
            Text(
              'Servings: ${recipe.servingsYield}',
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (recipe.description != null && recipe.description!.isNotEmpty) ...[
          SizedBox(height: sizes.spacing / 2),
          Text(
            recipe.description!,
            style: TextStyle(
              fontSize: sizes.fontSize,
              color: Colors.grey[700],
            ),
          ),
        ],
        SizedBox(height: sizes.spacing),
        // Nutrition Card (Per Serving)
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(sizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition Per Serving',
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
                    RecipeMacroItem(
                      label: 'Calories',
                      value: '${recipe.servingCalories} kcal',
                      color: Colors.orange,
                      sizes: sizes,
                    ),
                    RecipeMacroItem(
                      label: 'Protein',
                      value: '${recipe.servingProtein}g',
                      color: Colors.blue,
                      sizes: sizes,
                    ),
                    RecipeMacroItem(
                      label: 'Carbs',
                      value: '${recipe.servingCarbs}g',
                      color: Colors.amber,
                      sizes: sizes,
                    ),
                    RecipeMacroItem(
                      label: 'Fat',
                      value: '${recipe.servingFat}g',
                      color: Colors.red,
                      sizes: sizes,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: sizes.spacing),
        // Ingredients List
        Text(
          'Ingredients (${recipe.items.length})',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
        if (recipe.items.isEmpty)
          Text(
            'No ingredients listed.',
            style: TextStyle(
              fontSize: sizes.fontSize,
              color: Colors.grey,
            ),
          )
        else
          ...recipe.items.map((item) {
            final portionLabel = item.portionName != null
                ? '${item.amount} × ${item.portionName}'
                : '${item.amount}g';
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.teal),
                title: Text(item.foodName ?? 'Food #${item.foodId}'),
                subtitle: Text(portionLabel),
              ),
            );
          }),
        SizedBox(height: sizes.spacing * 1.5),
      ]);
}
