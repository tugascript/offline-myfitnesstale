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

final class MealPlanMealItemInput extends Equatable {
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
