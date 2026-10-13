import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/meal_plan_day_model.dart';
import '../../models/meal_plan_meal_item_model.dart';
import '../../models/meal_plan_meal_model.dart';
import '../../models/meal_plan_model.dart';
import '../../models/meal_plan_week_model.dart';

class MealPlanMealItemDto extends Equatable {
  final int id;
  final int mealPlanMealId;
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

  const MealPlanMealItemDto({
    required this.id,
    required this.mealPlanMealId,
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

  factory MealPlanMealItemDto.fromModel(
    MealPlanMealItem model, {
    String? foodName,
    String? portionName,
  }) {
    return MealPlanMealItemDto(
      id: model.id!,
      mealPlanMealId: model.mealPlanMealId,
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

  @override
  List<Object?> get props => [
        id,
        mealPlanMealId,
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

class MealPlanMealDto extends Equatable {
  final int id;
  final int position;
  final String? timeOfDay;
  final int mealPlanId;
  final int mealPlanWeekId;
  final int mealPlanDayId;
  final int planVersion;
  final MealType mealType;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;
  final String name;
  final int? recipeId;
  final String? recipeName;
  final CreatedBy createdBy;
  final List<MealPlanMealItemDto> items;

  const MealPlanMealDto({
    required this.id,
    required this.position,
    this.timeOfDay,
    required this.mealPlanId,
    required this.mealPlanWeekId,
    required this.mealPlanDayId,
    required this.planVersion,
    required this.mealType,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    required this.name,
    this.recipeId,
    this.recipeName,
    required this.createdBy,
    this.items = const [],
  });

  factory MealPlanMealDto.fromModel(
    MealPlanMeal model, {
    String? recipeName,
    List<MealPlanMealItemDto> items = const [],
  }) {
    return MealPlanMealDto(
      id: model.id!,
      position: model.position,
      timeOfDay: model.timeOfDay,
      mealPlanId: model.mealPlanId,
      mealPlanWeekId: model.mealPlanWeekId,
      mealPlanDayId: model.mealPlanDayId,
      planVersion: model.planVersion,
      mealType: model.mealType,
      totalCalories: model.totalCalories,
      totalProtein: model.totalProtein,
      totalCarbs: model.totalCarbs,
      totalFat: model.totalFat,
      totalFiber: model.totalFiber,
      name: model.name,
      recipeId: model.recipeId,
      recipeName: recipeName,
      createdBy: model.createdBy,
      items: items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        position,
        timeOfDay,
        mealPlanId,
        mealPlanWeekId,
        mealPlanDayId,
        planVersion,
        mealType,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        totalFiber,
        name,
        recipeId,
        recipeName,
        createdBy,
        items,
      ];
}

class MealPlanDayDto extends Equatable {
  final int id;
  final int mealPlanId;
  final int mealPlanWeekId;
  final int planVersion;
  final int day;
  final String? name;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final int? targetFiber;
  final int totalMeals;
  final CreatedBy createdBy;
  final List<MealPlanMealDto> meals;

  const MealPlanDayDto({
    required this.id,
    required this.mealPlanId,
    required this.mealPlanWeekId,
    required this.planVersion,
    required this.day,
    this.name,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.targetFiber,
    required this.totalMeals,
    required this.createdBy,
    this.meals = const [],
  });

  factory MealPlanDayDto.fromModel(
    MealPlanDay model, {
    List<MealPlanMealDto> meals = const [],
  }) {
    return MealPlanDayDto(
      id: model.id!,
      mealPlanId: model.mealPlanId,
      mealPlanWeekId: model.mealPlanWeekId,
      planVersion: model.planVersion,
      day: model.day,
      name: model.name,
      targetCalories: model.targetCalories,
      targetProtein: model.targetProtein,
      targetCarbs: model.targetCarbs,
      targetFat: model.targetFat,
      targetFiber: model.targetFiber,
      totalMeals: model.totalMeals,
      createdBy: model.createdBy,
      meals: meals,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mealPlanId,
        mealPlanWeekId,
        planVersion,
        day,
        name,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
        targetFiber,
        totalMeals,
        createdBy,
        meals,
      ];
}

class MealPlanWeekDto extends Equatable {
  final int id;
  final int mealPlanId;
  final int planVersion;
  final int weekNumber;
  final MealPlanPhase phase;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final int? targetFiber;
  final int totalDays;
  final int totalMeals;
  final CreatedBy createdBy;
  final List<MealPlanDayDto> days;

  const MealPlanWeekDto({
    required this.id,
    required this.mealPlanId,
    required this.planVersion,
    required this.weekNumber,
    required this.phase,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.targetFiber,
    required this.totalDays,
    required this.totalMeals,
    required this.createdBy,
    this.days = const [],
  });

  factory MealPlanWeekDto.fromModel(
    MealPlanWeek model, {
    List<MealPlanDayDto> days = const [],
  }) {
    return MealPlanWeekDto(
      id: model.id!,
      mealPlanId: model.mealPlanId,
      planVersion: model.planVersion,
      weekNumber: model.weekNumber,
      phase: model.phase,
      targetCalories: model.targetCalories,
      targetProtein: model.targetProtein,
      targetCarbs: model.targetCarbs,
      targetFat: model.targetFat,
      targetFiber: model.targetFiber,
      totalDays: model.totalDays,
      totalMeals: model.totalMeals,
      createdBy: model.createdBy,
      days: days,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mealPlanId,
        planVersion,
        weekNumber,
        phase,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
        targetFiber,
        totalDays,
        totalMeals,
        createdBy,
        days,
      ];
}

class MealPlanDto extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int version;
  final int totalWeeks;
  final int totalDays;
  final int totalMeals;
  final bool isFavorite;
  final CreatedBy createdBy;
  final List<MealPlanWeekDto> weeks;

  const MealPlanDto({
    required this.id,
    required this.name,
    this.description,
    required this.version,
    required this.totalWeeks,
    required this.totalDays,
    required this.totalMeals,
    required this.isFavorite,
    required this.createdBy,
    this.weeks = const [],
  });

  factory MealPlanDto.fromModel(
    MealPlan model, {
    List<MealPlanWeekDto> weeks = const [],
  }) {
    return MealPlanDto(
      id: model.id!,
      name: model.name,
      description: model.description,
      version: model.version,
      totalWeeks: model.totalWeeks,
      totalDays: model.totalDays,
      totalMeals: model.totalMeals,
      isFavorite: model.isFavorite,
      createdBy: model.createdBy,
      weeks: weeks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        version,
        totalWeeks,
        totalDays,
        totalMeals,
        isFavorite,
        createdBy,
        weeks,
      ];
}
