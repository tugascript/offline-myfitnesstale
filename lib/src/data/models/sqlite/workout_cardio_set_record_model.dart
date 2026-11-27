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
import 'model.dart';
import 'workout_cardio_set_model.dart';
import 'workout_record_model.dart';

const String _table = 'workout_cardio_set_records';

enum WorkoutCardioSetRecordColumns with Columns {
  id("id"),
  workoutCardioSetId("workout_cardio_set_id"),
  workoutRecordId("workout_record_id"),
  roundNumber("round_number"),
  totalRestSecs("total_rest_secs"),
  startedAt("started_at"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutCardioSetRecordColumns(this.value);
}

final class WorkoutCardioSetRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutCardioSetId;
  final int workoutRecordId;
  final int roundNumber;
  final int startedAt;
  final int? totalRestSecs;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutCardioSetRecord({
    this.id,
    required this.workoutCardioSetId,
    required this.workoutRecordId,
    required this.roundNumber,
    required this.startedAt,
    this.totalRestSecs,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutCardioSetRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutCardioSetRecordColumns.workoutCardioSetId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetRecordColumns.workoutRecordId.value} INTEGER NOT NULL,
    ${WorkoutCardioSetRecordColumns.roundNumber.value} INTEGER NOT NULL,
    ${WorkoutCardioSetRecordColumns.totalRestSecs.value} INTEGER,
    ${WorkoutCardioSetRecordColumns.startedAt.value} INTEGER NOT NULL,
    ${WorkoutCardioSetRecordColumns.completedAt.value} INTEGER,
    ${WorkoutCardioSetRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutCardioSetRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutCardioSetRecordColumns.workoutCardioSetId.value}) REFERENCES ${WorkoutCardioSet.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutCardioSetRecordColumns.workoutRecordId.value}) REFERENCES ${WorkoutRecord.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_records_set_id ON $_table (${WorkoutCardioSetRecordColumns.workoutCardioSetId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_records_record_id ON $_table (${WorkoutCardioSetRecordColumns.workoutRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_records_set_id_round_number ON $_table (${WorkoutCardioSetRecordColumns.workoutCardioSetId.value}, ${WorkoutCardioSetRecordColumns.roundNumber.value});
  CREATE INDEX IF NOT EXISTS idx_workout_cardio_set_records_set_id_record_id_round_number ON $_table (${WorkoutCardioSetRecordColumns.workoutCardioSetId.value}, ${WorkoutCardioSetRecordColumns.workoutRecordId.value}, ${WorkoutCardioSetRecordColumns.roundNumber.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutCardioSetRecordColumns.id.value: id,
      WorkoutCardioSetRecordColumns.workoutCardioSetId.value:
          workoutCardioSetId,
      WorkoutCardioSetRecordColumns.workoutRecordId.value: workoutRecordId,
      WorkoutCardioSetRecordColumns.roundNumber.value: roundNumber,
      WorkoutCardioSetRecordColumns.totalRestSecs.value: totalRestSecs,
      WorkoutCardioSetRecordColumns.startedAt.value: startedAt,
      WorkoutCardioSetRecordColumns.completedAt.value: completedAt,
      WorkoutCardioSetRecordColumns.createdAt.value: createdAt,
      WorkoutCardioSetRecordColumns.updatedAt.value: updatedAt,
    };
  }

  factory WorkoutCardioSetRecord.fromMap(Map<String, Object?> map) {
    return WorkoutCardioSetRecord(
      id: map[WorkoutCardioSetRecordColumns.id.value] as int?,
      workoutCardioSetId:
          map[WorkoutCardioSetRecordColumns.workoutCardioSetId.value] as int,
      workoutRecordId:
          map[WorkoutCardioSetRecordColumns.workoutRecordId.value] as int,
      roundNumber: map[WorkoutCardioSetRecordColumns.roundNumber.value] as int,
      totalRestSecs:
          map[WorkoutCardioSetRecordColumns.totalRestSecs.value] as int?,
      startedAt: map[WorkoutCardioSetRecordColumns.startedAt.value] as int,
      completedAt: map[WorkoutCardioSetRecordColumns.completedAt.value] as int?,
      createdAt: map[WorkoutCardioSetRecordColumns.createdAt.value] as int,
      updatedAt: map[WorkoutCardioSetRecordColumns.updatedAt.value] as int,
    );
  }

  factory WorkoutCardioSetRecord.create({
    required int workoutCardioSetId,
    required int workoutRecordId,
    required int roundNumber,
    required int startedAt,
    int? totalRestSecs,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutCardioSetRecord(
      workoutCardioSetId: workoutCardioSetId,
      workoutRecordId: workoutRecordId,
      roundNumber: roundNumber,
      startedAt: startedAt,
      totalRestSecs: totalRestSecs,
      completedAt: completedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutCardioSetRecord copyWith({
    Nullable<int>? id,
    int? workoutCardioSetId,
    int? workoutRecordId,
    int? roundNumber,
    Nullable<int>? totalRestSecs,
    int? startedAt,
    Nullable<int>? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutCardioSetRecord(
      id: id != null ? id.value : this.id,
      workoutCardioSetId: workoutCardioSetId ?? this.workoutCardioSetId,
      workoutRecordId: workoutRecordId ?? this.workoutRecordId,
      roundNumber: roundNumber ?? this.roundNumber,
      totalRestSecs: totalRestSecs != null
          ? totalRestSecs.value
          : this.totalRestSecs,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutCardioSetRecord{id: $id, workoutCardioSetId: $workoutCardioSetId, workoutRecordId: $workoutRecordId, roundNumber: $roundNumber, totalRestSecs: $totalRestSecs, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  List<Object?> get props => [
    id,
    workoutCardioSetId,
    workoutRecordId,
    roundNumber,
    startedAt,
    totalRestSecs,
    completedAt,
    createdAt,
    updatedAt,
  ];
}
