import 'package:flutter/foundation.dart';

import '../../../../models/enums.dart';
import '../../../../models/workout_set_exercise_model.dart';

enum ComplexSetEditorDataStatus {
  initial,
  pending,
  created,
}

final class AlternativeExerciseData {
  final int id;
  final String name;

  const AlternativeExerciseData({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlternativeExerciseData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

final class ComplexSetExerciseEditorData {
  final int internalId;
  int? id;
  int position;
  int minReps;
  int? maxReps;
  bool toMaxReps;
  WorkoutSetExerciseDifficulty? difficulty;
  int? exerciseId;
  String? exerciseName;
  Set<AlternativeExerciseData> alternativeExercises;
  ComplexSetEditorDataStatus status;

  ComplexSetExerciseEditorData({
    this.id,
    required this.position,
    required this.minReps,
    this.maxReps,
    required this.toMaxReps,
    this.difficulty,
    this.exerciseId,
    this.exerciseName,
    this.alternativeExercises = const {},
    this.status = ComplexSetEditorDataStatus.initial,
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}

final class ComplexSetEditorData {
  final int internalId;
  int? id;
  WorkoutSetType setType;
  int position;
  int minSets;
  int? maxSets;
  int recommendedRestSecs;
  int? maxRestSecs;
  List<ComplexSetExerciseEditorData> exercises;
  ComplexSetEditorDataStatus status;

  ComplexSetEditorData({
    this.id,
    required this.position,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.setType,
    this.exercises = const [],
    this.status = ComplexSetEditorDataStatus.initial,
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}
