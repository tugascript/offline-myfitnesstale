import 'package:equatable/equatable.dart';

import '../../utils/nullable.dart';
import '../utils/enums.dart';
import './model.dart';
import '../utils/dates.dart';

const String _table = 'week_macro_goals';

enum WeekMacroGoalColumns with Columns {
  id("id"),
  name("name"),
  totalTargetCalories("total_target_calories"),
  totalTargetProtein("total_target_protein"),
  totalTargetCarbs("total_target_carbs"),
  totalTargetFat("total_target_fat"),
  totalTargetFiber("total_target_fiber"),
  totalTargetSodium("total_target_sodium"),
  totalTargetWaterIntakeMl("total_target_water_intake_ml"),
  goalType("goal_type"),
  isActive("is_active"),
  phase("phase"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WeekMacroGoalColumns(this.value);
}

class WeekMacroGoal extends Equatable implements Model {
  @override
  final int? id;
  final String? name;
  final int totalTargetCalories;
  final int totalTargetProtein;
  final int totalTargetCarbs;
  final int totalTargetFat;
  final int? totalTargetFiber;
  final int? totalTargetSodium;
  final int? totalTargetWaterIntakeMl;
  final MacroGoalType goalType;
  final bool isActive;
  final WeightGoalPhase phase;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WeekMacroGoal({
    this.id,
    this.name,
    required this.totalTargetCalories,
    required this.totalTargetProtein,
    required this.totalTargetCarbs,
    required this.totalTargetFat,
    this.totalTargetFiber,
    this.totalTargetSodium,
    this.totalTargetWaterIntakeMl,
    required this.goalType,
    this.isActive = true,
    this.phase = WeightGoalPhase.maintain,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WeekMacroGoalColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WeekMacroGoalColumns.name.value} TEXT,
    ${WeekMacroGoalColumns.totalTargetCalories.value} INTEGER NOT NULL,
    ${WeekMacroGoalColumns.totalTargetProtein.value} INTEGER NOT NULL,
    ${WeekMacroGoalColumns.totalTargetCarbs.value} INTEGER NOT NULL,
    ${WeekMacroGoalColumns.totalTargetFat.value} INTEGER NOT NULL,
    ${WeekMacroGoalColumns.totalTargetFiber.value} INTEGER,
    ${WeekMacroGoalColumns.totalTargetSodium.value} INTEGER,
    ${WeekMacroGoalColumns.totalTargetWaterIntakeMl.value} INTEGER,
    ${WeekMacroGoalColumns.goalType.value} TEXT NOT NULL,
    ${WeekMacroGoalColumns.isActive.value} INTEGER NOT NULL DEFAULT 1,
    ${WeekMacroGoalColumns.phase.value} TEXT NOT NULL DEFAULT 'maintain',
    ${WeekMacroGoalColumns.createdAt.value} INTEGER NOT NULL,
    ${WeekMacroGoalColumns.updatedAt.value} INTEGER NOT NULL
  );
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WeekMacroGoalColumns.id.value: id,
      WeekMacroGoalColumns.name.value: name,
      WeekMacroGoalColumns.totalTargetCalories.value: totalTargetCalories,
      WeekMacroGoalColumns.totalTargetProtein.value: totalTargetProtein,
      WeekMacroGoalColumns.totalTargetCarbs.value: totalTargetCarbs,
      WeekMacroGoalColumns.totalTargetFat.value: totalTargetFat,
      WeekMacroGoalColumns.totalTargetFiber.value: totalTargetFiber,
      WeekMacroGoalColumns.totalTargetSodium.value: totalTargetSodium,
      WeekMacroGoalColumns.totalTargetWaterIntakeMl.value:
          totalTargetWaterIntakeMl,
      WeekMacroGoalColumns.goalType.value: goalType.value,
      WeekMacroGoalColumns.isActive.value: isActive ? 1 : 0,
      WeekMacroGoalColumns.phase.value: phase.value,
      WeekMacroGoalColumns.createdAt.value: createdAt,
      WeekMacroGoalColumns.updatedAt.value: updatedAt,
    };
  }

  factory WeekMacroGoal.fromMap(Map<String, Object?> map) {
    return WeekMacroGoal(
      id: map[WeekMacroGoalColumns.id.value] as int?,
      name: map[WeekMacroGoalColumns.name.value] as String?,
      totalTargetCalories:
          map[WeekMacroGoalColumns.totalTargetCalories.value] as int,
      totalTargetProtein:
          map[WeekMacroGoalColumns.totalTargetProtein.value] as int,
      totalTargetCarbs: map[WeekMacroGoalColumns.totalTargetCarbs.value] as int,
      totalTargetFat: map[WeekMacroGoalColumns.totalTargetFat.value] as int,
      totalTargetFiber:
          map[WeekMacroGoalColumns.totalTargetFiber.value] as int?,
      totalTargetSodium:
          map[WeekMacroGoalColumns.totalTargetSodium.value] as int?,
      totalTargetWaterIntakeMl:
          map[WeekMacroGoalColumns.totalTargetWaterIntakeMl.value] as int?,
      goalType: MacroGoalType.fromValue(
        map[WeekMacroGoalColumns.goalType.value] as String,
      ),
      isActive: (map[WeekMacroGoalColumns.isActive.value] as int? ?? 1) == 1,
      phase: WeightGoalPhase.fromValue(
        map[WeekMacroGoalColumns.phase.value] as String? ?? 'maintain',
      ),
      createdAt: map[WeekMacroGoalColumns.createdAt.value] as int,
      updatedAt: map[WeekMacroGoalColumns.updatedAt.value] as int,
    );
  }

  factory WeekMacroGoal.create({
    String? name,
    required int totalTargetCalories,
    required int totalTargetProtein,
    required int totalTargetCarbs,
    required int totalTargetFat,
    int? totalTargetFiber,
    int? totalTargetSodium,
    int? totalTargetWaterIntakeMl,
    required MacroGoalType goalType,
    bool isActive = true,
    WeightGoalPhase phase = WeightGoalPhase.maintain,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WeekMacroGoal(
      name: name,
      totalTargetCalories: totalTargetCalories,
      totalTargetProtein: totalTargetProtein,
      totalTargetCarbs: totalTargetCarbs,
      totalTargetFat: totalTargetFat,
      totalTargetFiber: totalTargetFiber,
      totalTargetSodium: totalTargetSodium,
      totalTargetWaterIntakeMl: totalTargetWaterIntakeMl,
      goalType: goalType,
      isActive: isActive,
      phase: phase,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WeekMacroGoal copyWith({
    Nullable<int>? id,
    Nullable<String>? name,
    int? totalTargetCalories,
    int? totalTargetProtein,
    int? totalTargetCarbs,
    int? totalTargetFat,
    Nullable<int>? totalTargetFiber,
    Nullable<int>? totalTargetSodium,
    Nullable<int>? totalTargetWaterIntakeMl,
    MacroGoalType? goalType,
    bool? isActive,
    WeightGoalPhase? phase,
    int? createdAt,
    int? updatedAt,
  }) {
    return WeekMacroGoal(
      id: id != null ? id.value : this.id,
      name: name != null ? name.value : this.name,
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
      isActive: isActive ?? this.isActive,
      phase: phase ?? this.phase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    totalTargetCalories,
    totalTargetProtein,
    totalTargetCarbs,
    totalTargetFat,
    totalTargetFiber,
    totalTargetSodium,
    totalTargetWaterIntakeMl,
    goalType,
    isActive,
    phase,
    createdAt,
    updatedAt,
  ];
}
