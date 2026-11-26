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
import 'exercise_model.dart';
import 'model.dart';
import 'workout_cardio_set_model.dart';
import 'workout_model.dart';

const String _table = 'workout_cardio_set_exercises';

enum WorkoutCardioSetExerciseColumns with Columns {
  id("id"),
  position("position"),
  workoutId("workout_id"),
  workoutVersion("workout_version"),
  workoutCardioSetId("workout_cardio_set_id"),
  exerciseId("exercise_id"),
  restSecs("rest_secs"),
  mode("mode"),
  quantity("quantity"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutCardioSetExerciseColumns(this.value);
}

final class WorkoutCardioSetExercise extends Equatable implements Model {
  @override
  final int? id;
  final int position;
  final int workoutId;
  final int workoutVersion;
  final int workoutCardioSetId;
  final int exerciseId;
  final int restSecs;
  final CardioBaseMode mode;
  final int quantity;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutCardioSetExercise({
    this.id,
    required this.position,
    required this.workoutId,
    required this.workoutVersion,
    required this.workoutCardioSetId,
    required this.exerciseId,
    this.restSecs = 0,
    required this.mode,
    required this.quantity,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutCardioSetExerciseColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutCardioSetExerciseColumns.position.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseColumns.workoutId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseColumns.workoutVersion.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseColumns.workoutCardioSetId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseColumns.exerciseId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseColumns.restSecs.value} INTEGER NOT NULL DEFAULT 0,
    ${WorkoutCardioSetExerciseColumns.mode.value} TEXT NOT NULL,
    ${WorkoutCardioSetExerciseColumns.quantity.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutCardioSetExerciseColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutCardioSetExerciseColumns.workoutId.value}) REFERENCES ${Workout.table} (${WorkoutColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutCardioSetExerciseColumns.workoutCardioSetId.value}) REFERENCES ${WorkoutCardioSet.table} (${WorkoutCardioSetColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutCardioSetExerciseColumns.exerciseId.value}) REFERENCES ${Exercise.table} (${ExerciseColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_cardio_set_exercise_set_id ON $_table (${WorkoutCardioSetExerciseColumns.workoutCardioSetId.value});
  CREATE INDEX IF NOT EXISTS idx_cardio_set_exercise_exercise_id ON $_table (${WorkoutCardioSetExerciseColumns.exerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_cardio_set_exercise_workout_id ON $_table (${WorkoutCardioSetExerciseColumns.workoutId.value});
  CREATE INDEX IF NOT EXISTS idx_cardio_set_exercise_position_set_id ON $_table (${WorkoutCardioSetExerciseColumns.position.value}, ${WorkoutCardioSetExerciseColumns.workoutCardioSetId.value});
  CREATE INDEX IF NOT EXISTS idx_cardio_set_exercise_workout_id_version ON $_table (${WorkoutCardioSetExerciseColumns.workoutId.value}, ${WorkoutCardioSetExerciseColumns.workoutVersion.value});
  ''';

  @override
  Map<String, Object?> toMap() => {
    WorkoutCardioSetExerciseColumns.id.value: id,
    WorkoutCardioSetExerciseColumns.position.value: position,
    WorkoutCardioSetExerciseColumns.workoutId.value: workoutId,
    WorkoutCardioSetExerciseColumns.workoutVersion.value: workoutVersion,
    WorkoutCardioSetExerciseColumns.workoutCardioSetId.value: workoutCardioSetId,
    WorkoutCardioSetExerciseColumns.exerciseId.value: exerciseId,
    WorkoutCardioSetExerciseColumns.restSecs.value: restSecs,
    WorkoutCardioSetExerciseColumns.mode.value: mode.value,
    WorkoutCardioSetExerciseColumns.quantity.value: quantity,
    WorkoutCardioSetExerciseColumns.createdBy.value: createdBy.value,
    WorkoutCardioSetExerciseColumns.createdAt.value: createdAt,
    WorkoutCardioSetExerciseColumns.updatedAt.value: updatedAt,
  };

  factory WorkoutCardioSetExercise.fromMap(Map<String, Object?> map) =>
      WorkoutCardioSetExercise(
        id: map[WorkoutCardioSetExerciseColumns.id.value] as int?,
        position: map[WorkoutCardioSetExerciseColumns.position.value] as int,
        workoutId: map[WorkoutCardioSetExerciseColumns.workoutId.value] as int,
        workoutVersion:
            map[WorkoutCardioSetExerciseColumns.workoutVersion.value] as int,
        workoutCardioSetId:
            map[WorkoutCardioSetExerciseColumns.workoutCardioSetId.value]
                as int,
        exerciseId:
            map[WorkoutCardioSetExerciseColumns.exerciseId.value] as int,
        restSecs:
            map[WorkoutCardioSetExerciseColumns.restSecs.value] as int? ?? 0,
        mode: CardioBaseMode.fromValue(
          map[WorkoutCardioSetExerciseColumns.mode.value] as String,
        ),
        quantity: map[WorkoutCardioSetExerciseColumns.quantity.value] as int,
        createdBy: CreatedBy.fromValue(
          map[WorkoutCardioSetExerciseColumns.createdBy.value] as String,
        ),
        createdAt: map[WorkoutCardioSetExerciseColumns.createdAt.value] as int,
        updatedAt: map[WorkoutCardioSetExerciseColumns.updatedAt.value] as int,
      );

  factory WorkoutCardioSetExercise.create({
    required int position,
    required int workoutId,
    required int workoutVersion,
    required int workoutCardioSetId,
    required int exerciseId,
    required CardioBaseMode mode,
    required int quantity,
    int restSecs = 0,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutCardioSetExercise(
      position: position,
      workoutId: workoutId,
      workoutVersion: workoutVersion,
      workoutCardioSetId: workoutCardioSetId,
      exerciseId: exerciseId,
      restSecs: restSecs,
      mode: mode,
      quantity: quantity,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutCardioSetExercise copyWith({
    Nullable<int>? id,
    int? position,
    int? workoutId,
    int? workoutVersion,
    int? workoutCardioSetId,
    int? exerciseId,
    int? restSecs,
    CardioBaseMode? mode,
    int? quantity,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) => WorkoutCardioSetExercise(
    id: id != null ? id.value : this.id,
    position: position ?? this.position,
    workoutId: workoutId ?? this.workoutId,
    workoutVersion: workoutVersion ?? this.workoutVersion,
    workoutCardioSetId: workoutCardioSetId ?? this.workoutCardioSetId,
    exerciseId: exerciseId ?? this.exerciseId,
    restSecs: restSecs ?? this.restSecs,
    mode: mode ?? this.mode,
    quantity: quantity ?? this.quantity,
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
    workoutCardioSetId,
    exerciseId,
    restSecs,
    mode,
    quantity,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
