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
import 'workout_cardio_set_exercise_model.dart';
import 'workout_cardio_set_record_model.dart';
import 'workout_record_model.dart';

const String _table = 'workout_cardio_set_exercise_records';

enum WorkoutCardioSetExerciseRecordColumns with Columns {
  id("id"),
  workoutCardioSetExerciseId("workout_cardio_set_exercise_id"),
  workoutRecordId("workout_record_id"),
  workoutCardioSetRecordId("workout_cardio_set_record_id"),
  exerciseId("exercise_id"),
  position("position"),
  mode("mode"),
  quantity("quantity"),
  durationSecs("duration_secs"),
  restSecs("rest_secs"),
  rpe("rpe"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutCardioSetExerciseRecordColumns(this.value);
}

final class WorkoutCardioSetExerciseRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutCardioSetExerciseId;
  final int workoutRecordId;
  final int workoutCardioSetRecordId;
  final int exerciseId;
  final int position;
  final CardioBaseMode mode;
  final int quantity;
  final int durationSecs;
  final int restSecs;
  final int rpe;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutCardioSetExerciseRecord({
    this.id,
    required this.workoutCardioSetExerciseId,
    required this.workoutRecordId,
    required this.workoutCardioSetRecordId,
    required this.exerciseId,
    required this.position,
    required this.mode,
    required this.quantity,
    required this.durationSecs,
    this.restSecs = 0,
    required this.rpe,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutCardioSetExerciseRecordColumns.id.value} INTEGER PRIMARY KEY,
    ${WorkoutCardioSetExerciseRecordColumns.workoutCardioSetExerciseId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.workoutRecordId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.workoutCardioSetRecordId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.exerciseId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.position.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.mode.value} TEXT NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.quantity.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.durationSecs.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.restSecs.value} INTEGER NOT NULL DEFAULT 0,
    ${WorkoutCardioSetExerciseRecordColumns.rpe.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutCardioSetExerciseRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutCardioSetExerciseRecordColumns.workoutCardioSetExerciseId.value}) REFERENCES ${WorkoutCardioSetExercise.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutCardioSetExerciseRecordColumns.workoutCardioSetRecordId.value}) REFERENCES ${WorkoutCardioSetRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutCardioSetExerciseRecordColumns.workoutRecordId.value}) REFERENCES ${WorkoutRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutCardioSetExerciseRecordColumns.exerciseId.value}) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_exercise_records_set_exercise_id ON $_table (${WorkoutCardioSetExerciseRecordColumns.workoutCardioSetExerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_exercise_records_set_record_id ON $_table (${WorkoutCardioSetExerciseRecordColumns.workoutCardioSetRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_exercise_records_workout_record_id ON $_table (${WorkoutCardioSetExerciseRecordColumns.workoutRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_exercise_records_exercise_id ON $_table (${WorkoutCardioSetExerciseRecordColumns.exerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_exercise_records_set_exercise_id_set_record_id_position ON $_table (${WorkoutCardioSetExerciseRecordColumns.workoutCardioSetExerciseId.value}, ${WorkoutCardioSetExerciseRecordColumns.workoutCardioSetRecordId.value}, ${WorkoutCardioSetExerciseRecordColumns.position.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutCardioSetExerciseRecordColumns.id.value: id,
      WorkoutCardioSetExerciseRecordColumns.workoutCardioSetExerciseId.value:
          workoutCardioSetExerciseId,
      WorkoutCardioSetExerciseRecordColumns.workoutRecordId.value:
          workoutRecordId,
      WorkoutCardioSetExerciseRecordColumns.workoutCardioSetRecordId.value:
          workoutCardioSetRecordId,
      WorkoutCardioSetExerciseRecordColumns.exerciseId.value: exerciseId,
      WorkoutCardioSetExerciseRecordColumns.position.value: position,
      WorkoutCardioSetExerciseRecordColumns.mode.value: mode.value,
      WorkoutCardioSetExerciseRecordColumns.quantity.value: quantity,
      WorkoutCardioSetExerciseRecordColumns.durationSecs.value: durationSecs,
      WorkoutCardioSetExerciseRecordColumns.restSecs.value: restSecs,
      WorkoutCardioSetExerciseRecordColumns.rpe.value: rpe,
      WorkoutCardioSetExerciseRecordColumns.createdAt.value: createdAt,
      WorkoutCardioSetExerciseRecordColumns.updatedAt.value: updatedAt,
    };
  }

  factory WorkoutCardioSetExerciseRecord.fromMap(Map<String, Object?> map) {
    return WorkoutCardioSetExerciseRecord(
      id: map[WorkoutCardioSetExerciseRecordColumns.id.value] as int?,
      workoutCardioSetExerciseId:
          map[WorkoutCardioSetExerciseRecordColumns
                  .workoutCardioSetExerciseId
                  .value]
              as int,
      workoutRecordId:
          map[WorkoutCardioSetExerciseRecordColumns.workoutRecordId.value]
              as int,
      workoutCardioSetRecordId:
          map[WorkoutCardioSetExerciseRecordColumns
                  .workoutCardioSetRecordId
                  .value]
              as int,
      exerciseId:
          map[WorkoutCardioSetExerciseRecordColumns.exerciseId.value] as int,
      position:
          map[WorkoutCardioSetExerciseRecordColumns.position.value] as int,
      mode: CardioBaseMode.fromValue(
        map[WorkoutCardioSetExerciseRecordColumns.mode.value] as String,
      ),
      quantity:
          map[WorkoutCardioSetExerciseRecordColumns.quantity.value] as int,
      durationSecs:
          map[WorkoutCardioSetExerciseRecordColumns.durationSecs.value] as int,
      restSecs:
          map[WorkoutCardioSetExerciseRecordColumns.restSecs.value] as int? ??
          0,
      rpe: map[WorkoutCardioSetExerciseRecordColumns.rpe.value] as int,
      createdAt:
          map[WorkoutCardioSetExerciseRecordColumns.createdAt.value] as int,
      updatedAt:
          map[WorkoutCardioSetExerciseRecordColumns.updatedAt.value] as int,
    );
  }

  factory WorkoutCardioSetExerciseRecord.create({
    required int workoutCardioSetExerciseId,
    required int workoutRecordId,
    required int workoutCardioSetRecordId,
    required int exerciseId,
    required int position,
    required CardioBaseMode mode,
    required int quantity,
    required int durationSecs,
    int restSecs = 0,
    required int rpe,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutCardioSetExerciseRecord(
      workoutCardioSetExerciseId: workoutCardioSetExerciseId,
      workoutRecordId: workoutRecordId,
      workoutCardioSetRecordId: workoutCardioSetRecordId,
      exerciseId: exerciseId,
      position: position,
      mode: mode,
      quantity: quantity,
      durationSecs: durationSecs,
      restSecs: restSecs,
      rpe: rpe,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutCardioSetExerciseRecord copyWith({
    Nullable<int>? id,
    int? workoutCardioSetExerciseId,
    int? workoutRecordId,
    int? workoutCardioSetRecordId,
    int? exerciseId,
    int? position,
    CardioBaseMode? mode,
    int? quantity,
    int? durationSecs,
    int? restSecs,
    int? rpe,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutCardioSetExerciseRecord(
      id: id != null ? id.value : this.id,
      workoutCardioSetExerciseId:
          workoutCardioSetExerciseId ?? this.workoutCardioSetExerciseId,
      workoutRecordId: workoutRecordId ?? this.workoutRecordId,
      workoutCardioSetRecordId:
          workoutCardioSetRecordId ?? this.workoutCardioSetRecordId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      mode: mode ?? this.mode,
      quantity: quantity ?? this.quantity,
      durationSecs: durationSecs ?? this.durationSecs,
      restSecs: restSecs ?? this.restSecs,
      rpe: rpe ?? this.rpe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutCardioSetExerciseRecord{id: $id, workoutCardioSetExerciseId: $workoutCardioSetExerciseId, workoutRecordId: $workoutRecordId, workoutCardioSetRecordId: $workoutCardioSetRecordId, exerciseId: $exerciseId, position: $position, mode: $mode, quantity: $quantity, durationSecs: $durationSecs, restSecs: $restSecs, rpe: $rpe, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  List<Object?> get props => [
    id,
    workoutCardioSetExerciseId,
    workoutRecordId,
    workoutCardioSetRecordId,
    exerciseId,
    position,
    mode,
    quantity,
    durationSecs,
    restSecs,
    rpe,
    createdAt,
    updatedAt,
  ];
}
