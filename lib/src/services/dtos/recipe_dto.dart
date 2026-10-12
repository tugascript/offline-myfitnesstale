import 'package:equatable/equatable.dart';

import '../../models/common.dart';
import '../../models/enums.dart';
import '../../models/recipe_item_model.dart';
import '../../models/recipe_model.dart';

class RecipeItemInput extends Equatable {
  final int foodId;
  final int? portionId;
  final int amount;

  const RecipeItemInput({
    required this.foodId,
    this.portionId,
    required this.amount,
  });

  @override
  List<Object?> get props => [foodId, portionId, amount];
}

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
  final int createdAt;
  final int updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
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
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  RecipeItemDto copyWith({
    int? id,
    int? recipeId,
    int? foodId,
    int? portionId,
    int? amount,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    int? totalFiber,
    String? foodName,
    String? portionName,
    int? createdAt,
    int? updatedAt,
  }) {
    return RecipeItemDto(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      foodId: foodId ?? this.foodId,
      portionId: portionId ?? this.portionId,
      amount: amount ?? this.amount,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      foodName: foodName ?? this.foodName,
      portionName: portionName ?? this.portionName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        createdAt,
        updatedAt,
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
  final int createdAt;
  final int updatedAt;
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
    required this.createdAt,
    required this.updatedAt,
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
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      items: items,
    );
  }

  RecipeDto copyWith({
    int? id,
    String? name,
    String? description,
    int? servingsYield,
    int? servingCalories,
    int? servingProtein,
    int? servingCarbs,
    int? servingFat,
    Micronutrients? servingMicros,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
    List<RecipeItemDto>? items,
  }) {
    return RecipeDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      servingsYield: servingsYield ?? this.servingsYield,
      servingCalories: servingCalories ?? this.servingCalories,
      servingProtein: servingProtein ?? this.servingProtein,
      servingCarbs: servingCarbs ?? this.servingCarbs,
      servingFat: servingFat ?? this.servingFat,
      servingMicros: servingMicros ?? this.servingMicros,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        createdAt,
        updatedAt,
        items,
      ];
}
