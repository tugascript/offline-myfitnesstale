import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/enums.dart';

class MealPlanMealItemInput extends Equatable {
  final int foodId;
  final int? portionId;
  final int amount;

  const MealPlanMealItemInput({
    required this.foodId,
    this.portionId,
    required this.amount,
  });

  @override
  List<Object?> get props => [foodId, portionId, amount];
}

class MealPlanMealInput extends Equatable {
  final int position;
  final String? timeOfDay;
  final MealType mealType;
  final String name;
  final int? recipeId;
  final List<MealPlanMealItemInput> items;

  const MealPlanMealInput({
    required this.position,
    this.timeOfDay,
    required this.mealType,
    required this.name,
    this.recipeId,
    this.items = const [],
  });

  @override
  List<Object?> get props => [
    position,
    timeOfDay,
    mealType,
    name,
    recipeId,
    items,
  ];
}

class MealPlanDayInput extends Equatable {
  final int day;
  final String? name;
  final List<MealPlanMealInput> meals;

  const MealPlanDayInput({required this.day, this.name, this.meals = const []});

  @override
  List<Object?> get props => [day, name, meals];
}

class MealPlanWeekInput extends Equatable {
  final int weekNumber;
  final MealPlanPhase phase;
  final List<MealPlanDayInput> days;

  const MealPlanWeekInput({
    required this.weekNumber,
    required this.phase,
    this.days = const [],
  });

  @override
  List<Object?> get props => [weekNumber, phase, days];
}

class MealPlanInput {
  final String name;
  final Nullable<String> description;
  final List<MealPlanWeekInput> weeks;
  const MealPlanInput({
    required this.name,
    this.description = const Nullable(null),
    required this.weeks,
  });
}
