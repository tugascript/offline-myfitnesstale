import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../utils/nullable.dart';
import '../utils/enums.dart';
import 'model.dart';

import 'week_macro_goal_model.dart';
import '../utils/dates.dart';

const String _table = 'day_macro_goals';

enum DayMacroGoalColumns with Columns {
  id("id"),
  weekMacroGoalId("week_macro_goal_id"),
  days("days"),
  name("name"),
  targetCalories("target_calories"),
  targetProtein("target_protein"),
  targetCarbs("target_carbs"),
  targetFat("target_fat"),
  targetFiber("target_fiber"),
  targetSodium("target_sodium"),
  targetWaterIntakeMl("target_water_intake_ml"),
  isActive("is_active"),
  phase("phase"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const DayMacroGoalColumns(this.value);
}

class DayMacroGoal extends Equatable implements Model {
  @override
  final int? id;
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
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const DayMacroGoal({
    this.id,
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
    required this.isActive,
    required this.phase,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${DayMacroGoalColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DayMacroGoalColumns.weekMacroGoalId.value} INTEGER NOT NULL,
    ${DayMacroGoalColumns.days.value} TEXT NOT NULL,
    ${DayMacroGoalColumns.name.value} TEXT,
    ${DayMacroGoalColumns.targetCalories.value} INTEGER NOT NULL,
    ${DayMacroGoalColumns.targetProtein.value} INTEGER NOT NULL,
    ${DayMacroGoalColumns.targetCarbs.value} INTEGER NOT NULL,
    ${DayMacroGoalColumns.targetFat.value} INTEGER NOT NULL,
    ${DayMacroGoalColumns.targetFiber.value} INTEGER,
    ${DayMacroGoalColumns.targetSodium.value} INTEGER,
    ${DayMacroGoalColumns.targetWaterIntakeMl.value} INTEGER,
    ${DayMacroGoalColumns.isActive.value} INTEGER NOT NULL,
    ${DayMacroGoalColumns.phase.value} TEXT NOT NULL,
    ${DayMacroGoalColumns.createdAt.value} INTEGER NOT NULL,
    ${DayMacroGoalColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${DayMacroGoalColumns.weekMacroGoalId.value}) REFERENCES ${WeekMacroGoal.table} (${WeekMacroGoalColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_day_macro_goals_week_macro_goal_id ON $_table (${DayMacroGoalColumns.weekMacroGoalId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      DayMacroGoalColumns.id.value: id,
      DayMacroGoalColumns.weekMacroGoalId.value: weekMacroGoalId,
      DayMacroGoalColumns.days.value: jsonEncode(
        days.map((d) => d.value).toList(),
      ),
      DayMacroGoalColumns.name.value: name,
      DayMacroGoalColumns.targetCalories.value: targetCalories,
      DayMacroGoalColumns.targetProtein.value: targetProtein,
      DayMacroGoalColumns.targetCarbs.value: targetCarbs,
      DayMacroGoalColumns.targetFat.value: targetFat,
      DayMacroGoalColumns.targetFiber.value: targetFiber,
      DayMacroGoalColumns.targetSodium.value: targetSodium,
      DayMacroGoalColumns.targetWaterIntakeMl.value: targetWaterIntakeMl,
      DayMacroGoalColumns.isActive.value: isActive ? 1 : 0,
      DayMacroGoalColumns.phase.value: phase.value,
      DayMacroGoalColumns.createdAt.value: createdAt,
      DayMacroGoalColumns.updatedAt.value: updatedAt,
    };
  }

  factory DayMacroGoal.fromMap(Map<String, Object?> map) {
    final rawDays = map[DayMacroGoalColumns.days.value];
    List<DayOfWeek> parsedDays = const [];
    if (rawDays is String) {
      try {
        final decoded = jsonDecode(rawDays);
        if (decoded is List) {
          parsedDays = decoded
              .whereType<int>()
              .map(DayOfWeek.tryFromValue)
              .whereType<DayOfWeek>()
              .toList();
        }
      } catch (_) {
        parsedDays = rawDays
            .split(',')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => int.tryParse(s.trim()))
            .whereType<int>()
            .map(DayOfWeek.tryFromValue)
            .whereType<DayOfWeek>()
            .toList();
      }
    } else if (rawDays is List) {
      parsedDays = rawDays
          .map(
            (v) => v is DayOfWeek
                ? v
                : (v is int ? DayOfWeek.tryFromValue(v) : null),
          )
          .whereType<DayOfWeek>()
          .toList();
    }

    return DayMacroGoal(
      id: map[DayMacroGoalColumns.id.value] as int?,
      weekMacroGoalId: map[DayMacroGoalColumns.weekMacroGoalId.value] as int,
      days: parsedDays,
      name: map[DayMacroGoalColumns.name.value] as String?,
      targetCalories: map[DayMacroGoalColumns.targetCalories.value] as int,
      targetProtein: map[DayMacroGoalColumns.targetProtein.value] as int,
      targetCarbs: map[DayMacroGoalColumns.targetCarbs.value] as int,
      targetFat: map[DayMacroGoalColumns.targetFat.value] as int,
      targetFiber: map[DayMacroGoalColumns.targetFiber.value] as int?,
      targetSodium: map[DayMacroGoalColumns.targetSodium.value] as int?,
      targetWaterIntakeMl:
          map[DayMacroGoalColumns.targetWaterIntakeMl.value] as int?,
      isActive: (map[DayMacroGoalColumns.isActive.value] as int? ?? 1) == 1,
      phase: WeightGoalPhase.fromValue(
        map[DayMacroGoalColumns.phase.value] as String? ?? 'maintain',
      ),
      createdAt: map[DayMacroGoalColumns.createdAt.value] as int,
      updatedAt: map[DayMacroGoalColumns.updatedAt.value] as int,
    );
  }

  factory DayMacroGoal.create({
    required int weekMacroGoalId,
    required List<DayOfWeek> days,
    String? name,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
    int? targetFiber,
    int? targetSodium,
    int? targetWaterIntakeMl,
    bool isActive = true,
    WeightGoalPhase phase = WeightGoalPhase.maintain,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return DayMacroGoal(
      weekMacroGoalId: weekMacroGoalId,
      days: days,
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
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  DayMacroGoal copyWith({
    Nullable<int>? id,
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
    int? createdAt,
    int? updatedAt,
  }) {
    return DayMacroGoal(
      id: id != null ? id.value : this.id,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    createdAt,
    updatedAt,
  ];
}
