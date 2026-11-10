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
import '../../../utils/json_data.dart';
import '../../../models/sqlite/daily_nutrition_log_model.dart';
import '../../../models/sqlite/day_macro_goal_model.dart';
import '../../../utils/enums.dart';
import '../../../models/sqlite/meal_log_item_model.dart';
import '../../../models/sqlite/meal_log_model.dart';

import '../../../models/sqlite/week_macro_goal_model.dart';
import '../../../utils/dates.dart';
import '../../core/dtos/dto.dart';

class DayMacroGoalDto extends Equatable implements Dto<DayMacroGoal> {
  @override
  final int id;
  final int weekMacroGoalId;
  final List<DayOfWeek> days;
  final String? name;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final int? targetFiber;
  final int? targetSodium;
  final int? targetWaterIntakeMl;
  final bool isActive;
  final WeightGoalPhase phase;

  const DayMacroGoalDto({
    required this.id,
    required this.weekMacroGoalId,
    required this.days,
    this.name,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.targetFiber,
    this.targetSodium,
    this.targetWaterIntakeMl,
    this.isActive = true,
    this.phase = WeightGoalPhase.maintain,
  });

  factory DayMacroGoalDto.fromModel(DayMacroGoal model) {
    return DayMacroGoalDto(
      id: model.id!,
      weekMacroGoalId: model.weekMacroGoalId,
      days: model.days,
      name: model.name,
      targetCalories: model.targetCalories,
      targetProtein: model.targetProtein,
      targetCarbs: model.targetCarbs,
      targetFat: model.targetFat,
      targetFiber: model.targetFiber,
      targetSodium: model.targetSodium,
      targetWaterIntakeMl: model.targetWaterIntakeMl,
      isActive: model.isActive,
      phase: model.phase,
    );
  }

  @override
  DayMacroGoalDto copyWith({
    int? id,
    int? weekMacroGoalId,
    List<DayOfWeek>? days,
    Nullable<String>? name,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    Nullable<int>? targetFiber,
    Nullable<int>? targetSodium,
    Nullable<int>? targetWaterIntakeMl,
    bool? isActive,
    WeightGoalPhase? phase,
  }) {
    return DayMacroGoalDto(
      id: id ?? this.id,
      weekMacroGoalId: weekMacroGoalId ?? this.weekMacroGoalId,
      days: days ?? this.days,
      name: name != null ? name.value : this.name,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      targetFiber: targetFiber != null ? targetFiber.value : this.targetFiber,
      targetSodium: targetSodium != null
          ? targetSodium.value
          : this.targetSodium,
      targetWaterIntakeMl: targetWaterIntakeMl != null
          ? targetWaterIntakeMl.value
          : this.targetWaterIntakeMl,
      isActive: isActive ?? this.isActive,
      phase: phase ?? this.phase,
    );
  }

  @override
  List<Object?> get props => [
    id,
    weekMacroGoalId,
    days,
    name,
    targetCalories,
    targetProtein,
    targetCarbs,
    targetFat,
    targetFiber,
    targetSodium,
    targetWaterIntakeMl,
    isActive,
    phase,
  ];
}

class MacroGoalDto extends Equatable implements Dto<WeekMacroGoal> {
  @override
  final int id;
  final String name;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final int? targetFiber;
  final int? targetSodium;
  final int? targetWaterIntakeMl;
  final int totalTargetCalories;
  final int totalTargetProtein;
  final int totalTargetCarbs;
  final int totalTargetFat;
  final int? totalTargetFiber;
  final int? totalTargetSodium;
  final int? totalTargetWaterIntakeMl;
  final MacroGoalType goalType;
  final List<DayMacroGoalDto> days;
  final bool isActive;
  final WeightGoalPhase phase;

  const MacroGoalDto({
    required this.id,
    required this.name,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.targetFiber,
    this.targetSodium,
    this.targetWaterIntakeMl,
    int? totalTargetCalories,
    int? totalTargetProtein,
    int? totalTargetCarbs,
    int? totalTargetFat,
    this.totalTargetFiber,
    this.totalTargetSodium,
    this.totalTargetWaterIntakeMl,
    this.goalType = MacroGoalType.flat,
    this.days = const [],
    required this.isActive,
    required this.phase,
  }) : totalTargetCalories = totalTargetCalories ?? targetCalories * 7,
       totalTargetProtein = totalTargetProtein ?? targetProtein * 7,
       totalTargetCarbs = totalTargetCarbs ?? targetCarbs * 7,
       totalTargetFat = totalTargetFat ?? targetFat * 7;

  factory MacroGoalDto.fromWeekModel(
    WeekMacroGoal week,
    List<DayMacroGoal> dayModels,
  ) {
    final dayDtos = dayModels.map(DayMacroGoalDto.fromModel).toList();
    final isSingleDay =
        week.goalType == MacroGoalType.flat && dayDtos.length == 1;
    final firstDay = isSingleDay ? dayDtos.first : null;

    return MacroGoalDto(
      id: week.id!,
      name: week.name ?? 'Daily Target',
      targetCalories:
          firstDay?.targetCalories ?? (week.totalTargetCalories / 7).round(),
      targetProtein:
          firstDay?.targetProtein ?? (week.totalTargetProtein / 7).round(),
      targetCarbs: firstDay?.targetCarbs ?? (week.totalTargetCarbs / 7).round(),
      targetFat: firstDay?.targetFat ?? (week.totalTargetFat / 7).round(),
      targetFiber: firstDay != null
          ? firstDay.targetFiber
          : (week.totalTargetFiber != null
                ? (week.totalTargetFiber! / 7).round()
                : null),
      targetSodium: firstDay != null
          ? firstDay.targetSodium
          : (week.totalTargetSodium != null
                ? (week.totalTargetSodium! / 7).round()
                : null),
      targetWaterIntakeMl: firstDay != null
          ? firstDay.targetWaterIntakeMl
          : (week.totalTargetWaterIntakeMl != null
                ? (week.totalTargetWaterIntakeMl! / 7).round()
                : null),
      totalTargetCalories: week.totalTargetCalories,
      totalTargetProtein: week.totalTargetProtein,
      totalTargetCarbs: week.totalTargetCarbs,
      totalTargetFat: week.totalTargetFat,
      totalTargetFiber: week.totalTargetFiber,
      totalTargetSodium: week.totalTargetSodium,
      totalTargetWaterIntakeMl: week.totalTargetWaterIntakeMl,
      goalType: week.goalType,
      days: dayDtos,
      isActive: week.isActive,
      phase: week.phase,
    );
  }

  DayMacroGoalDto? goalForDayOfWeek(DayOfWeek dayOfWeek) {
    for (final dayGoal in days) {
      if (dayGoal.days.contains(dayOfWeek)) {
        return dayGoal;
      }
    }
    return null;
  }

  DayMacroGoalDto? goalForDate(DateTime date) =>
      goalForDayOfWeek(DayOfWeek.fromDateTime(date));

  DayMacroGoalDto effectiveGoalForDate(DateTime date) {
    final matched = goalForDate(date);
    if (matched != null) return matched;
    return DayMacroGoalDto(
      id: 0,
      weekMacroGoalId: id,
      days: DayOfWeek.values,
      name: name,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      targetFiber: targetFiber,
      targetSodium: targetSodium,
      targetWaterIntakeMl: targetWaterIntakeMl,
      isActive: isActive,
      phase: phase,
    );
  }

  @override
  MacroGoalDto copyWith({
    int? id,
    String? name,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    Nullable<int>? targetFiber,
    Nullable<int>? targetSodium,
    Nullable<int>? targetWaterIntakeMl,
    int? totalTargetCalories,
    int? totalTargetProtein,
    int? totalTargetCarbs,
    int? totalTargetFat,
    Nullable<int>? totalTargetFiber,
    Nullable<int>? totalTargetSodium,
    Nullable<int>? totalTargetWaterIntakeMl,
    MacroGoalType? goalType,
    List<DayMacroGoalDto>? days,
    bool? isActive,
    WeightGoalPhase? phase,
  }) {
    return MacroGoalDto(
      id: id ?? this.id,
      name: name ?? this.name,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      targetFiber: targetFiber != null ? targetFiber.value : this.targetFiber,
      targetSodium: targetSodium != null
          ? targetSodium.value
          : this.targetSodium,
      targetWaterIntakeMl: targetWaterIntakeMl != null
          ? targetWaterIntakeMl.value
          : this.targetWaterIntakeMl,
      totalTargetCalories: totalTargetCalories ?? this.totalTargetCalories,
      totalTargetProtein: totalTargetProtein ?? this.totalTargetProtein,
      totalTargetCarbs: totalTargetCarbs ?? this.totalTargetCarbs,
      totalTargetFat: totalTargetFat ?? this.totalTargetFat,
      totalTargetFiber: totalTargetFiber != null
          ? totalTargetFiber.value
          : this.totalTargetFiber,
      totalTargetSodium: totalTargetSodium != null
          ? totalTargetSodium.value
          : this.totalTargetSodium,
      totalTargetWaterIntakeMl: totalTargetWaterIntakeMl != null
          ? totalTargetWaterIntakeMl.value
          : this.totalTargetWaterIntakeMl,
      goalType: goalType ?? this.goalType,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
      phase: phase ?? this.phase,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    targetCalories,
    targetProtein,
    targetCarbs,
    targetFat,
    targetFiber,
    targetSodium,
    targetWaterIntakeMl,
    totalTargetCalories,
    totalTargetProtein,
    totalTargetCarbs,
    totalTargetFat,
    totalTargetFiber,
    totalTargetSodium,
    totalTargetWaterIntakeMl,
    goalType,
    days,
    isActive,
    phase,
  ];
}

typedef WeekMacroGoalDto = MacroGoalDto;

class MealLogItemDto extends Equatable implements Dto<MealLogItem> {
  @override
  final int id;
  final int mealLogId;
  final int? foodId;
  final int? portionId;
  final int amount;
  final String loggedFoodName;
  final int loggedCalories;
  final int loggedProtein;
  final int loggedCarbs;
  final int loggedFat;
  final Micronutrients? loggedMicros;
  final String? portionName;

  const MealLogItemDto({
    required this.id,
    required this.mealLogId,
    this.foodId,
    this.portionId,
    required this.amount,
    required this.loggedFoodName,
    required this.loggedCalories,
    required this.loggedProtein,
    required this.loggedCarbs,
    required this.loggedFat,
    this.loggedMicros,
    this.portionName,
  });

  factory MealLogItemDto.fromModel(MealLogItem model, {String? portionName}) {
    return MealLogItemDto(
      id: model.id!,
      mealLogId: model.mealLogId,
      foodId: model.foodId,
      portionId: model.portionId,
      amount: model.amount,
      loggedFoodName: model.loggedFoodName,
      loggedCalories: model.loggedCalories,
      loggedProtein: model.loggedProtein,
      loggedCarbs: model.loggedCarbs,
      loggedFat: model.loggedFat,
      loggedMicros: model.loggedMicros,
      portionName: portionName,
    );
  }

  @override
  MealLogItemDto copyWith({
    int? id,
    int? mealLogId,
    Nullable<int>? foodId,
    Nullable<int>? portionId,
    int? amount,
    String? loggedFoodName,
    int? loggedCalories,
    int? loggedProtein,
    int? loggedCarbs,
    int? loggedFat,
    Nullable<Micronutrients>? loggedMicros,
    Nullable<String>? portionName,
  }) {
    return MealLogItemDto(
      id: id ?? this.id,
      mealLogId: mealLogId ?? this.mealLogId,
      foodId: foodId != null ? foodId.value : this.foodId,
      portionId: portionId != null ? portionId.value : this.portionId,
      amount: amount ?? this.amount,
      loggedFoodName: loggedFoodName ?? this.loggedFoodName,
      loggedCalories: loggedCalories ?? this.loggedCalories,
      loggedProtein: loggedProtein ?? this.loggedProtein,
      loggedCarbs: loggedCarbs ?? this.loggedCarbs,
      loggedFat: loggedFat ?? this.loggedFat,
      loggedMicros: loggedMicros != null
          ? loggedMicros.value
          : this.loggedMicros,
      portionName: portionName != null ? portionName.value : this.portionName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    mealLogId,
    foodId,
    portionId,
    amount,
    loggedFoodName,
    loggedCalories,
    loggedProtein,
    loggedCarbs,
    loggedFat,
    loggedMicros,
    portionName,
  ];
}

class MealLogDto extends Equatable implements Dto<MealLog> {
  @override
  final int id;
  final int dailyLogId;
  final MealType mealType;
  final int? recipeId;
  final DateTime logTime;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;
  final List<MealLogItemDto> items;

  const MealLogDto({
    required this.id,
    required this.dailyLogId,
    required this.mealType,
    this.recipeId,
    required this.logTime,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    this.items = const [],
  });

  factory MealLogDto.fromModel(
    MealLog model, {
    List<MealLogItemDto> items = const [],
  }) {
    return MealLogDto(
      id: model.id!,
      dailyLogId: model.dailyLogId,
      mealType: model.mealType,
      recipeId: model.recipeId,
      logTime: DateUtilities.getDateFromUnix(model.logTime),
      totalCalories: model.totalCalories,
      totalProtein: model.totalProtein,
      totalCarbs: model.totalCarbs,
      totalFat: model.totalFat,
      totalFiber: model.totalFiber,
      items: items,
    );
  }

  @override
  MealLogDto copyWith({
    int? id,
    int? dailyLogId,
    MealType? mealType,
    Nullable<int>? recipeId,
    DateTime? logTime,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    Nullable<int>? totalFiber,
    List<MealLogItemDto>? items,
  }) {
    return MealLogDto(
      id: id ?? this.id,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId != null ? recipeId.value : this.recipeId,
      logTime: logTime ?? this.logTime,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber != null ? totalFiber.value : this.totalFiber,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    dailyLogId,
    mealType,
    recipeId,
    logTime,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
    totalFiber,
    items,
  ];
}

class DailyNutritionLogDto extends Equatable implements Dto<DailyNutritionLog> {
  @override
  final int id;
  final int date; // YYYYMMDD
  final int waterIntakeMl;
  final String? notes;
  final List<MealLogDto> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int totalFiber;

  const DailyNutritionLogDto({
    required this.id,
    required this.date,
    required this.waterIntakeMl,
    this.notes,
    this.meals = const [],
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
  });

  factory DailyNutritionLogDto.fromModel(
    DailyNutritionLog model, {
    List<MealLogDto> meals = const [],
  }) {
    int cals = 0;
    int protein = 0;
    int carbs = 0;
    int fat = 0;
    int fiber = 0;

    for (final meal in meals) {
      cals += meal.totalCalories;
      protein += meal.totalProtein;
      carbs += meal.totalCarbs;
      fat += meal.totalFat;
      fiber += meal.totalFiber ?? 0;
    }

    return DailyNutritionLogDto(
      id: model.id!,
      date: model.date,
      waterIntakeMl: model.waterIntakeMl,
      notes: model.notes,
      meals: meals,
      totalCalories: cals,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFat: fat,
      totalFiber: fiber,
    );
  }

  @override
  DailyNutritionLogDto copyWith({
    int? id,
    int? date,
    int? waterIntakeMl,
    Nullable<String>? notes,
    List<MealLogDto>? meals,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    int? totalFiber,
  }) {
    return DailyNutritionLogDto(
      id: id ?? this.id,
      date: date ?? this.date,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      notes: notes != null ? notes.value : this.notes,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    waterIntakeMl,
    notes,
    meals,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
    totalFiber,
  ];
}
