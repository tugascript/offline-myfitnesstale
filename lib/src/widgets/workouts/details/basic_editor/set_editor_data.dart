import 'package:flutter/material.dart';

enum SetEditorDataStatus {
  initial,
  pending,
  created,
}

final class SetEditorData {
  int? id;
  final int internalId;
  int position;
  int minSets;
  int maxSets;
  int minReps;
  int maxReps;
  bool toMaxReps;
  int recommendedRestSecs;
  int maxRestSecs;
  int? setExerciseId;
  int? exerciseId;
  String? exerciseName;
  SetEditorDataStatus status;

  SetEditorData({
    required this.id,
    required this.position,
    required this.minSets,
    required this.maxSets,
    required this.minReps,
    required this.maxReps,
    required this.toMaxReps,
    required this.recommendedRestSecs,
    required this.maxRestSecs,
    required this.setExerciseId,
    required this.exerciseId,
    required this.exerciseName,
    required this.status,
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}
