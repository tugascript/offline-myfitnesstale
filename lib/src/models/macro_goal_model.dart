import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'macro_goals';

enum MacroGoalColumns with Columns {
  id("id"),
  name("name"),
  targetCalories("target_calories"),
  targetProtein("target_protein"),
  targetCarbs("target_carbs"),
  targetFat("target_fat"),
  targetWaterIntakeMl("target_water_intake_ml"),
  isActive("is_active"),
  phase("phase"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MacroGoalColumns(this.value);
}

class MacroGoal extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final int? targetWaterIntakeMl;
  final bool isActive;
  final WeightGoalPhase phase;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MacroGoal({
    this.id,
    required this.name,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.isActive,
    required this.targetWaterIntakeMl,
    required this.phase,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MacroGoalColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MacroGoalColumns.name.value} TEXT NOT NULL,
    ${MacroGoalColumns.targetCalories.value} INTEGER NOT NULL,
    ${MacroGoalColumns.targetProtein.value} INTEGER NOT NULL,
    ${MacroGoalColumns.targetCarbs.value} INTEGER NOT NULL,
    ${MacroGoalColumns.targetFat.value} INTEGER NOT NULL,
    ${MacroGoalColumns.isActive.value} INTEGER NOT NULL,
    ${MacroGoalColumns.phase.value} TEXT NOT NULL,
    ${MacroGoalColumns.createdAt.value} INTEGER NOT NULL,
    ${MacroGoalColumns.updatedAt.value} INTEGER NOT NULL
  );
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MacroGoalColumns.id.value: id,
      MacroGoalColumns.name.value: name,
      MacroGoalColumns.targetCalories.value: targetCalories,
      MacroGoalColumns.targetProtein.value: targetProtein,
      MacroGoalColumns.targetCarbs.value: targetCarbs,
      MacroGoalColumns.targetFat.value: targetFat,
      MacroGoalColumns.isActive.value: isActive ? 1 : 0,
      MacroGoalColumns.phase.value: phase.value,
      MacroGoalColumns.createdAt.value: createdAt,
      MacroGoalColumns.updatedAt.value: updatedAt,
    };
  }

  factory MacroGoal.fromMap(Map<String, Object?> map) {
    return MacroGoal(
      id: map[MacroGoalColumns.id.value] as int?,
      name: map[MacroGoalColumns.name.value] as String,
      targetCalories: map[MacroGoalColumns.targetCalories.value] as int,
      targetProtein: map[MacroGoalColumns.targetProtein.value] as int,
      targetCarbs: map[MacroGoalColumns.targetCarbs.value] as int,
      targetFat: map[MacroGoalColumns.targetFat.value] as int,
      targetWaterIntakeMl:
          map[MacroGoalColumns.targetWaterIntakeMl.value] as int?,
      isActive: map[MacroGoalColumns.isActive.value] as int == 1,
      phase: WeightGoalPhase.fromValue(
        map[MacroGoalColumns.phase.value] as String,
      ),
      createdAt: map[MacroGoalColumns.createdAt.value] as int,
      updatedAt: map[MacroGoalColumns.updatedAt.value] as int,
    );
  }

  factory MacroGoal.create({
    required int profileId,
    int? weightGoalId,
    required String name,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
    int? targetWaterIntakeMl,
    required WeightGoalPhase phase,
    bool isActive = true,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MacroGoal(
      name: name,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      targetWaterIntakeMl: targetWaterIntakeMl,
      isActive: isActive,
      phase: phase,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MacroGoal copyWith({
    int? id,
    WeightGoalPhase? phase,
    String? name,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    int? targetWaterIntakeMl,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return MacroGoal(
      id: id ?? this.id,
      phase: phase ?? this.phase,
      name: name ?? this.name,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      targetWaterIntakeMl: targetWaterIntakeMl ?? this.targetWaterIntakeMl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phase,
        name,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
        targetWaterIntakeMl,
        isActive,
        createdAt,
        updatedAt,
      ];
}
