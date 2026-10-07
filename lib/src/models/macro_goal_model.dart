import 'package:equatable/equatable.dart';

import 'model.dart';
import 'profile_model.dart';
import 'utilities.dart';
import 'weight_goal_model.dart';

const String _table = 'macro_goals';

enum MacroGoalColumns with Columns {
  id("id"),
  profileId("profile_id"),
  weightGoalId("weight_goal_id"),
  name("name"),
  targetCalories("target_calories"),
  targetProtein("target_protein"),
  targetCarbs("target_carbs"),
  targetFat("target_fat"),
  isActive("is_active"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MacroGoalColumns(this.value);
}

class MacroGoal extends Equatable implements Model {
  @override
  final int? id;
  final int profileId;
  final int? weightGoalId;
  final String name;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final bool isActive;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MacroGoal({
    this.id,
    required this.profileId,
    this.weightGoalId,
    required this.name,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MacroGoalColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MacroGoalColumns.profileId.value} INTEGER NOT NULL,
    ${MacroGoalColumns.weightGoalId.value} INTEGER,
    ${MacroGoalColumns.name.value} TEXT NOT NULL,
    ${MacroGoalColumns.targetCalories.value} INTEGER NOT NULL,
    ${MacroGoalColumns.targetProtein.value} INTEGER NOT NULL,
    ${MacroGoalColumns.targetCarbs.value} INTEGER NOT NULL,
    ${MacroGoalColumns.targetFat.value} INTEGER NOT NULL,
    ${MacroGoalColumns.isActive.value} INTEGER NOT NULL DEFAULT 1,
    ${MacroGoalColumns.createdAt.value} INTEGER NOT NULL,
    ${MacroGoalColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MacroGoalColumns.profileId.value}) REFERENCES ${Profile.table} (${ProfileColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MacroGoalColumns.weightGoalId.value}) REFERENCES ${WeightGoal.table} (${WeightGoalColumns.id.value})
      ON DELETE SET NULL
  );

  CREATE INDEX IF NOT EXISTS idx_macro_goals_profile_id ON $_table (${MacroGoalColumns.profileId.value});
  CREATE INDEX IF NOT EXISTS idx_macro_goals_is_active ON $_table (${MacroGoalColumns.isActive.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MacroGoalColumns.id.value: id,
      MacroGoalColumns.profileId.value: profileId,
      MacroGoalColumns.weightGoalId.value: weightGoalId,
      MacroGoalColumns.name.value: name,
      MacroGoalColumns.targetCalories.value: targetCalories,
      MacroGoalColumns.targetProtein.value: targetProtein,
      MacroGoalColumns.targetCarbs.value: targetCarbs,
      MacroGoalColumns.targetFat.value: targetFat,
      MacroGoalColumns.isActive.value: isActive ? 1 : 0,
      MacroGoalColumns.createdAt.value: createdAt,
      MacroGoalColumns.updatedAt.value: updatedAt,
    };
  }

  factory MacroGoal.fromMap(Map<String, Object?> map) {
    return MacroGoal(
      id: map[MacroGoalColumns.id.value] as int?,
      profileId: map[MacroGoalColumns.profileId.value] as int,
      weightGoalId: map[MacroGoalColumns.weightGoalId.value] as int?,
      name: map[MacroGoalColumns.name.value] as String,
      targetCalories: map[MacroGoalColumns.targetCalories.value] as int,
      targetProtein: map[MacroGoalColumns.targetProtein.value] as int,
      targetCarbs: map[MacroGoalColumns.targetCarbs.value] as int,
      targetFat: map[MacroGoalColumns.targetFat.value] as int,
      isActive: (map[MacroGoalColumns.isActive.value] as int? ?? 1) == 1,
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
    bool isActive = true,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MacroGoal(
      profileId: profileId,
      weightGoalId: weightGoalId,
      name: name,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MacroGoal copyWith({
    int? id,
    int? profileId,
    int? weightGoalId,
    String? name,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return MacroGoal(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      weightGoalId: weightGoalId ?? this.weightGoalId,
      name: name ?? this.name,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        weightGoalId,
        name,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
        isActive,
        createdAt,
        updatedAt,
      ];
}
