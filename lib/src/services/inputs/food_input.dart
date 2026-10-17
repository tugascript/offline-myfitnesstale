import '../../common/nullable.dart';
import '../../models/common.dart';
import '../../models/enums.dart';

class FoodPortionInput {
  final String portionName;
  final int gramWeight;

  const FoodPortionInput({required this.portionName, required this.gramWeight});
}

class FoodInput {
  final String name;
  final FoodCategory category;
  final Nullable<String> brand;
  final Nullable<String> barcode;
  final int servingSizeBaseGrams;
  final int caloriesBase;
  final int proteinBase;
  final int carbsBase;
  final int fatBase;
  final Nullable<int> fiberBase;
  final Nullable<int> sodiumBase;
  final Nullable<Micronutrients> micros;
  final bool isFavorite;
  final List<FoodPortionInput> portions;

  const FoodInput({
    required this.name,
    required this.category,
    this.brand = const Nullable<String>(null),
    this.barcode = const Nullable<String>(null),
    required this.servingSizeBaseGrams,
    required this.caloriesBase,
    required this.proteinBase,
    required this.carbsBase,
    required this.fatBase,
    this.fiberBase = const Nullable<int>(null),
    this.sodiumBase = const Nullable<int>(null),
    this.micros = const Nullable<Micronutrients>(null),
    this.isFavorite = false,
    required this.portions,
  });
}
