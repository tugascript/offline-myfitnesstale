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

import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';

import '../../../utils/enums.dart';
import '../../../models/sqlite/meal_plan_day_model.dart';
import '../../../models/sqlite/meal_plan_meal_item_model.dart';
import '../../../models/sqlite/meal_plan_meal_model.dart';
import '../../../models/sqlite/meal_plan_model.dart';
import '../../../models/sqlite/meal_plan_week_model.dart';
import '../../core/dtos/dto.dart';

class MealPlanMealItemDto extends Equatable implements Dto<MealPlanMealItem> {
  @override
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
  MealPlanMealItemDto copyWith({
    int? id,
    int? mealPlanMealId,
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
    return MealPlanMealItemDto(
      id: id ?? this.id,
      mealPlanMealId: mealPlanMealId ?? this.mealPlanMealId,
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

class MealPlanMealDto extends Equatable implements Dto<MealPlanMeal> {
  @override
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
  MealPlanMealDto copyWith({
    int? id,
    int? position,
    Nullable<String>? timeOfDay,
    int? mealPlanId,
    int? mealPlanWeekId,
    int? mealPlanDayId,
    int? planVersion,
    MealType? mealType,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    Nullable<int>? totalFiber,
    String? name,
    Nullable<int>? recipeId,
    Nullable<String>? recipeName,
    CreatedBy? createdBy,
    List<MealPlanMealItemDto>? items,
  }) {
    return MealPlanMealDto(
      id: id ?? this.id,
      position: position ?? this.position,
      timeOfDay: timeOfDay != null ? timeOfDay.value : this.timeOfDay,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlanWeekId: mealPlanWeekId ?? this.mealPlanWeekId,
      mealPlanDayId: mealPlanDayId ?? this.mealPlanDayId,
      planVersion: planVersion ?? this.planVersion,
      mealType: mealType ?? this.mealType,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber != null ? totalFiber.value : this.totalFiber,
      name: name ?? this.name,
      recipeId: recipeId != null ? recipeId.value : this.recipeId,
      recipeName: recipeName != null ? recipeName.value : this.recipeName,
      createdBy: createdBy ?? this.createdBy,
      items: items ?? this.items,
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

class MealPlanDayDto extends Equatable implements Dto<MealPlanDay> {
  @override
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
  MealPlanDayDto copyWith({
    int? id,
    int? mealPlanId,
    int? mealPlanWeekId,
    int? planVersion,
    int? day,
    Nullable<String>? name,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    Nullable<int>? targetFiber,
    int? totalMeals,
    CreatedBy? createdBy,
    List<MealPlanMealDto>? meals,
  }) {
    return MealPlanDayDto(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlanWeekId: mealPlanWeekId ?? this.mealPlanWeekId,
      planVersion: planVersion ?? this.planVersion,
      day: day ?? this.day,
      name: name != null ? name.value : this.name,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      targetFiber: targetFiber != null ? targetFiber.value : this.targetFiber,
      totalMeals: totalMeals ?? this.totalMeals,
      createdBy: createdBy ?? this.createdBy,
      meals: meals ?? this.meals,
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

class MealPlanWeekDto extends Equatable implements Dto<MealPlanWeek> {
  @override
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
  MealPlanWeekDto copyWith({
    int? id,
    int? mealPlanId,
    int? planVersion,
    int? weekNumber,
    MealPlanPhase? phase,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    Nullable<int>? targetFiber,
    int? totalDays,
    int? totalMeals,
    CreatedBy? createdBy,
    List<MealPlanDayDto>? days,
  }) {
    return MealPlanWeekDto(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      planVersion: planVersion ?? this.planVersion,
      weekNumber: weekNumber ?? this.weekNumber,
      phase: phase ?? this.phase,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      targetFiber: targetFiber != null ? targetFiber.value : this.targetFiber,
      totalDays: totalDays ?? this.totalDays,
      totalMeals: totalMeals ?? this.totalMeals,
      createdBy: createdBy ?? this.createdBy,
      days: days ?? this.days,
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

class MealPlanDto extends Equatable implements Dto<MealPlan> {
  @override
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
  MealPlanDto copyWith({
    int? id,
    String? name,
    Nullable<String>? description,
    int? version,
    int? totalWeeks,
    int? totalDays,
    int? totalMeals,
    bool? isFavorite,
    CreatedBy? createdBy,
    List<MealPlanWeekDto>? weeks,
  }) {
    return MealPlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description != null ? description.value : this.description,
      version: version ?? this.version,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      totalDays: totalDays ?? this.totalDays,
      totalMeals: totalMeals ?? this.totalMeals,
      isFavorite: isFavorite ?? this.isFavorite,
      createdBy: createdBy ?? this.createdBy,
      weeks: weeks ?? this.weeks,
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
