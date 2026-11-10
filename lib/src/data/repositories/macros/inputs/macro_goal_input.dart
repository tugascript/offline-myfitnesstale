// Copyright (C) 2026 Afonso Barracha
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

final class DayMacroGoalInput extends Equatable {
  final String? name;
  final List<DayOfWeek> days;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final Nullable<int> targetFiber;
  final Nullable<int> targetSodium;
  final Nullable<int> targetWaterIntakeMl;
  final WeightGoalPhase? phase;
  final bool isActive;

  const DayMacroGoalInput({
    this.name,
    required this.days,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.targetFiber = const Nullable(null),
    this.targetSodium = const Nullable(null),
    this.targetWaterIntakeMl = const Nullable(null),
    this.phase,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    name,
    days,
    targetCalories,
    targetProtein,
    targetCarbs,
    targetFat,
    targetFiber,
    targetSodium,
    targetWaterIntakeMl,
    phase,
    isActive,
  ];
}

final class MacroGoalInput extends Equatable {
  final String? name;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final Nullable<int> targetFiber;
  final Nullable<int> targetSodium;
  final Nullable<int> targetWaterIntakeMl;
  final WeightGoalPhase phase;
  final MacroGoalType goalType;
  final List<DayMacroGoalInput> days;
  final bool isActive;

  const MacroGoalInput({
    this.name,
    this.targetCalories = 0,
    this.targetProtein = 0,
    this.targetCarbs = 0,
    this.targetFat = 0,
    this.targetFiber = const Nullable(null),
    this.targetSodium = const Nullable(null),
    this.targetWaterIntakeMl = const Nullable(null),
    this.phase = WeightGoalPhase.maintain,
    this.goalType = MacroGoalType.flat,
    this.days = const [],
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    name,
    targetCalories,
    targetProtein,
    targetCarbs,
    targetFat,
    targetFiber,
    targetSodium,
    targetWaterIntakeMl,
    phase,
    goalType,
    days,
    isActive,
  ];
}

typedef WeekMacroGoalInput = MacroGoalInput;
