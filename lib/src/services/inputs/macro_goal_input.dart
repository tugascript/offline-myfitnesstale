import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/enums.dart';

class DayMacroGoalInput extends Equatable {
  final String? name;
  final List<DayOfWeek> days;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final Nullable<int> targetFiber;
  final Nullable<int> targetSodium;
  final Nullable<int> targetWaterIntakeMl;
  final WeightGoalPhase phase;
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
    this.phase = WeightGoalPhase.maintain,
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

class MacroGoalInput extends Equatable {
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
