/// Nutrition totals for one diary entry, independent of the food library.
class QuickFoodLogInput {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const QuickFoodLogInput({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
