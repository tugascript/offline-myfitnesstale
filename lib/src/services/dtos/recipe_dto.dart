import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/common.dart';
import '../../models/enums.dart';
import '../../models/recipe_item_model.dart';
import '../../models/recipe_model.dart';

class RecipeItemDto extends Equatable {
  final int id;
  final int recipeId;
  final int foodId;
  final int? portionId;
  final int amount;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;
  final String? foodName;
  final String? portionName;

  const RecipeItemDto({
    required this.id,
    required this.recipeId,
    required this.foodId,
    this.portionId,
    required this.amount,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    this.foodName,
    this.portionName,
  });

  factory RecipeItemDto.fromModel(
    RecipeItem model, {
    String? foodName,
    String? portionName,
  }) {
    return RecipeItemDto(
      id: model.id!,
      recipeId: model.recipeId,
      foodId: model.foodId,
      portionId: model.portionId,
      amount: model.amount,
      totalCalories: model.totalCalories,
      totalProtein: model.totalProtein,
      totalCarbs: model.totalCarbs,
      totalFat: model.totalFat,
      totalFiber: model.totalFiber,
      foodName: foodName,
      portionName: portionName,
    );
  }

  RecipeItemDto copyWith({
    int? id,
    int? recipeId,
    int? foodId,
    Nullable<int>? portionId,
    int? amount,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    Nullable<int>? totalFiber,
    Nullable<String>? foodName,
    Nullable<String>? portionName,
  }) {
    return RecipeItemDto(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      foodId: foodId ?? this.foodId,
      portionId: portionId != null ? portionId.value : this.portionId,
      amount: amount ?? this.amount,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber != null ? totalFiber.value : this.totalFiber,
      foodName: foodName != null ? foodName.value : this.foodName,
      portionName: portionName != null ? portionName.value : this.portionName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recipeId,
    foodId,
    portionId,
    amount,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
    totalFiber,
    foodName,
    portionName,
  ];
}

class RecipeDto extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int servingsYield;
  final int servingCalories;
  final int servingProtein;
  final int servingCarbs;
  final int servingFat;
  final Micronutrients? servingMicros;
  final CreatedBy createdBy;

  final List<RecipeItemDto> items;

  const RecipeDto({
    required this.id,
    required this.name,
    this.description,
    required this.servingsYield,
    required this.servingCalories,
    required this.servingProtein,
    required this.servingCarbs,
    required this.servingFat,
    this.servingMicros,
    required this.createdBy,
    this.items = const [],
  });

  factory RecipeDto.fromModel(
    Recipe model, {
    List<RecipeItemDto> items = const [],
  }) {
    return RecipeDto(
      id: model.id!,
      name: model.name,
      description: model.description,
      servingsYield: model.servingsYield,
      servingCalories: model.servingCalories,
      servingProtein: model.servingProtein,
      servingCarbs: model.servingCarbs,
      servingFat: model.servingFat,
      servingMicros: model.servingMicros,
      createdBy: model.createdBy,
      items: items,
    );
  }

  RecipeDto copyWith({
    int? id,
    String? name,
    Nullable<String>? description,
    int? servingsYield,
    int? servingCalories,
    int? servingProtein,
    int? servingCarbs,
    int? servingFat,
    Nullable<Micronutrients>? servingMicros,
    CreatedBy? createdBy,
    List<RecipeItemDto>? items,
  }) {
    return RecipeDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description != null ? description.value : this.description,
      servingsYield: servingsYield ?? this.servingsYield,
      servingCalories: servingCalories ?? this.servingCalories,
      servingProtein: servingProtein ?? this.servingProtein,
      servingCarbs: servingCarbs ?? this.servingCarbs,
      servingFat: servingFat ?? this.servingFat,
      servingMicros: servingMicros != null
          ? servingMicros.value
          : this.servingMicros,
      createdBy: createdBy ?? this.createdBy,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    servingsYield,
    servingCalories,
    servingProtein,
    servingCarbs,
    servingFat,
    servingMicros,
    createdBy,
    items,
  ];
}
