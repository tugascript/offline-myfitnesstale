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

import '../../../../utils/nullable.dart';
import '../../../utils/json_data.dart';

class WorkoutRecordInput {
  final int workoutId;
  final DateTime startedAt;
  final Nullable<DateTime> completedAt;
  final Nullable<DateTime> droppedAt;

  const WorkoutRecordInput({
    required this.workoutId,
    required this.startedAt,
    this.completedAt = const Nullable<DateTime>(null),
    this.droppedAt = const Nullable<DateTime>(null),
  });
}

class WorkoutSetRecordInput {
  final int workoutSetId;
  final int workoutRecordId;
  final int setNumber;
  final DateTime startedAt;
  final Nullable<int> totalRestSecs;
  final Nullable<DateTime> completedAt;

  const WorkoutSetRecordInput({
    required this.workoutSetId,
    required this.workoutRecordId,
    required this.setNumber,
    required this.startedAt,
    this.totalRestSecs = const Nullable<int>(null),
    this.completedAt = const Nullable<DateTime>(null),
  });
}

class WorkoutSetExerciseRecordInput {
  final int workoutSetExerciseId;
  final int workoutRecordId;
  final int workoutSetRecordId;
  final int exerciseId;
  final int position;
  final int reps;
  final int weight;
  final WorkoutSetExerciseDifficulty difficulty;

  const WorkoutSetExerciseRecordInput({
    required this.workoutSetExerciseId,
    required this.workoutRecordId,
    required this.workoutSetRecordId,
    required this.exerciseId,
    required this.position,
    required this.reps,
    required this.weight,
    required this.difficulty,
  });
}

final class WorkoutRecordBatchInput {
  final int workoutId;
  final int version;
  final DateTime startedAt;
  final DateTime completedAt;
  final List<WorkoutSetRecordBatchInput> sets;

  const WorkoutRecordBatchInput({
    required this.workoutId,
    required this.version,
    required this.startedAt,
    required this.completedAt,
    required this.sets,
  });
}

final class WorkoutSetRecordBatchInput {
  final int workoutSetId;
  final int setNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalRestSecs;
  final List<WorkoutSetExerciseRecordBatchInput> exercises;

  const WorkoutSetRecordBatchInput({
    required this.workoutSetId,
    required this.setNumber,
    required this.startedAt,
    this.completedAt,
    this.totalRestSecs = 0,
    required this.exercises,
  });
}

final class WorkoutSetExerciseRecordBatchInput {
  final int workoutSetExerciseId;
  final int exerciseId;
  final int position;
  final int weight;
  final int reps;
  final WorkoutSetExerciseDifficulty difficulty;

  const WorkoutSetExerciseRecordBatchInput({
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.position,
    required this.weight,
    required this.reps,
    required this.difficulty,
  });

  WorkoutSetExerciseRecordBatchInput copyWith({
    int? workoutSetExerciseId,
    int? exerciseId,
    int? position,
    int? weight,
    int? reps,
    WorkoutSetExerciseDifficulty? difficulty,
  }) {
    return WorkoutSetExerciseRecordBatchInput(
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
