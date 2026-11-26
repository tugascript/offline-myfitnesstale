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

import '../../../utils/nullable.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import 'model.dart';
import 'workout_model.dart';

const String _table = 'workout_cardio_sets';

enum WorkoutCardioSetColumns with Columns {
  id("id"),
  position("position"),
  workoutId("workout_id"),
  workoutVersion("workout_version"),
  setType("set_type"),
  restSecs("rest_secs"),
  rounds("rounds"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutCardioSetColumns(this.value);
}

final class WorkoutCardioSet extends Equatable implements Model {
  @override
  final int? id;
  final int position;
  final int workoutId;
  final int workoutVersion;
  final CardioSetType setType;
  final int restSecs;
  final int rounds;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutCardioSet({
    this.id,
    required this.position,
    required this.workoutId,
    required this.workoutVersion,
    this.setType = CardioSetType.constant,
    this.restSecs = 0,
    this.rounds = 1,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutCardioSetColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutCardioSetColumns.position.value} INTEGER NOT NULL,
    ${WorkoutCardioSetColumns.workoutId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetColumns.workoutVersion.value} INTEGER NOT NULL,
    ${WorkoutCardioSetColumns.setType.value} TEXT NOT NULL DEFAULT '${CardioSetType.constant.value}',
    ${WorkoutCardioSetColumns.restSecs.value} INTEGER NOT NULL DEFAULT 0,
    ${WorkoutCardioSetColumns.rounds.value} INTEGER NOT NULL DEFAULT 1,
    ${WorkoutCardioSetColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutCardioSetColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutCardioSetColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutCardioSetColumns.workoutId.value}) REFERENCES ${Workout.table} (${WorkoutColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_workout_cardio_sets_workout_id ON $_table (${WorkoutCardioSetColumns.workoutId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_sets_workout_id_version ON $_table (${WorkoutCardioSetColumns.workoutId.value}, ${WorkoutCardioSetColumns.workoutVersion.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_sets_workout_id_position ON $_table (${WorkoutCardioSetColumns.workoutId.value}, ${WorkoutCardioSetColumns.position.value});
  ''';

  @override
  Map<String, Object?> toMap() => {
    WorkoutCardioSetColumns.id.value: id,
    WorkoutCardioSetColumns.position.value: position,
    WorkoutCardioSetColumns.workoutId.value: workoutId,
    WorkoutCardioSetColumns.workoutVersion.value: workoutVersion,
    WorkoutCardioSetColumns.setType.value: setType.value,
    WorkoutCardioSetColumns.restSecs.value: restSecs,
    WorkoutCardioSetColumns.rounds.value: rounds,
    WorkoutCardioSetColumns.createdBy.value: createdBy.value,
    WorkoutCardioSetColumns.createdAt.value: createdAt,
    WorkoutCardioSetColumns.updatedAt.value: updatedAt,
  };

  factory WorkoutCardioSet.fromMap(Map<String, Object?> map) =>
      WorkoutCardioSet(
        id: map[WorkoutCardioSetColumns.id.value] as int?,
        position: map[WorkoutCardioSetColumns.position.value] as int,
        workoutId: map[WorkoutCardioSetColumns.workoutId.value] as int,
        workoutVersion:
            map[WorkoutCardioSetColumns.workoutVersion.value] as int,
        setType: CardioSetType.fromValue(
          map[WorkoutCardioSetColumns.setType.value] as String,
        ),
        restSecs: map[WorkoutCardioSetColumns.restSecs.value] as int? ?? 0,
        rounds: map[WorkoutCardioSetColumns.rounds.value] as int? ?? 1,
        createdBy: CreatedBy.fromValue(
          map[WorkoutCardioSetColumns.createdBy.value] as String,
        ),
        createdAt: map[WorkoutCardioSetColumns.createdAt.value] as int,
        updatedAt: map[WorkoutCardioSetColumns.updatedAt.value] as int,
      );

  factory WorkoutCardioSet.create({
    required int position,
    required int workoutId,
    required int workoutVersion,
    CardioSetType setType = CardioSetType.constant,
    int restSecs = 0,
    int rounds = 1,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutCardioSet(
      position: position,
      workoutId: workoutId,
      workoutVersion: workoutVersion,
      setType: setType,
      restSecs: restSecs,
      rounds: rounds,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutCardioSet copyWith({
    Nullable<int>? id,
    int? position,
    int? workoutId,
    int? workoutVersion,
    CardioSetType? setType,
    int? restSecs,
    int? rounds,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) => WorkoutCardioSet(
    id: id != null ? id.value : this.id,
    position: position ?? this.position,
    workoutId: workoutId ?? this.workoutId,
    workoutVersion: workoutVersion ?? this.workoutVersion,
    setType: setType ?? this.setType,
    restSecs: restSecs ?? this.restSecs,
    rounds: rounds ?? this.rounds,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    position,
    workoutId,
    workoutVersion,
    setType,
    restSecs,
    rounds,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
