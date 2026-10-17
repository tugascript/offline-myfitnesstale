import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/common.dart';
import '../../models/daily_nutrition_log_model.dart';
import '../../models/enums.dart';
import '../../models/macro_goal_model.dart';
import '../../models/meal_log_item_model.dart';
import '../../models/meal_log_model.dart';
import '../../models/utilities.dart';

class MacroGoalDto extends Equatable {
  final int id;
  final String name;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final int? targetWaterIntakeMl;
  final bool isActive;
  final WeightGoalPhase phase;

  const MacroGoalDto({
    required this.id,
    required this.name,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.targetWaterIntakeMl,
    required this.isActive,
    required this.phase,
  });

  factory MacroGoalDto.fromModel(MacroGoal model) {
    return MacroGoalDto(
      id: model.id!,
      name: model.name,
      targetCalories: model.targetCalories,
      targetProtein: model.targetProtein,
      targetCarbs: model.targetCarbs,
      targetFat: model.targetFat,
      targetWaterIntakeMl: model.targetWaterIntakeMl,
      isActive: model.isActive,
      phase: model.phase,
    );
  }

  MacroGoalDto copyWith({
    int? id,
    String? name,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    Nullable<int>? targetWaterIntakeMl,
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
    name,
    targetCalories,
    targetProtein,
    targetCarbs,
    targetFat,
    targetWaterIntakeMl,
    isActive,
    phase,
  ];
}

class MealLogItemDto extends Equatable {
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

class MealLogDto extends Equatable {
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

class DailyNutritionLogDto extends Equatable {
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
