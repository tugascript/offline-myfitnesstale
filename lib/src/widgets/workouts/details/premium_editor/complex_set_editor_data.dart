import 'package:flutter/foundation.dart';

import '../../../../models/enums.dart';

enum ComplexSetEditorDataStatus {
  initial,
  pending,
  created,
}

final class RepEditorData {
  final int internalId;
  int? id;
  int position;
  int minReps;
  int maxReps;
  bool toMaxReps;
  int? exerciseId;
  String? exerciseName;

  RepEditorData({
    this.id,
    required this.position,
    required this.minReps,
    required this.maxReps,
    required this.toMaxReps,
    this.exerciseId,
    this.exerciseName,
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}

final class FullSetEditorData {
  final int internalId;
  int? id;
  WorkoutSetType setType;
  int position;
  int minSets;
  int maxSets;
  int recommendedRestSecs;
  int maxRestSecs;
  final List<RepEditorData> reps;

  FullSetEditorData({
    this.id,
    required this.position,
    required this.minSets,
    required this.maxSets,
    required this.recommendedRestSecs,
    required this.maxRestSecs,
    required this.setType,
    required this.reps,
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}
