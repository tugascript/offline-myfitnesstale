import 'package:equatable/equatable.dart';

import '../../models/common.dart';
import '../../models/utilities.dart';
import '../../models/workout_record_model.dart';
import 'dto.dart';
import 'workout_set_record_dto.dart';

class WorkoutRecordDto extends Equatable implements Dto<WorkoutRecord> {
  @override
  final int id;
  final int workoutId;
  final int totalSets;
  final int totalReps;
  final int totalRestSecs;
  final int totalVolume;
  final TargetMuscles muscles;
  final int currentSetPosition;
  final int currentSetNumber;
  final int currentExercisePosition;
  final DateTime startedAt;
  final DateTime? completedAt;

  // Related data
  final List<WorkoutSetRecordDto>? setRecords;

  const WorkoutRecordDto({
    required this.id,
    required this.workoutId,
    required this.currentSetPosition,
    required this.currentSetNumber,
    required this.currentExercisePosition,
    required this.totalSets,
    required this.totalReps,
    required this.totalRestSecs,
    required this.totalVolume,
    required this.muscles,
    required this.startedAt,
    this.completedAt,
    this.setRecords,
  });

  factory WorkoutRecordDto.fromModel(
    WorkoutRecord model, {
    List<WorkoutSetRecordDto>? setRecords,
  }) {
    return WorkoutRecordDto(
      id: model.id!,
      workoutId: model.workoutId,
      currentSetPosition: model.currentSetPosition,
      currentSetNumber: model.currentSetNumber,
      currentExercisePosition: model.currentExercisePosition,
      totalSets: model.totalSets,
      totalReps: model.totalReps,
      totalRestSecs: model.totalRestSecs,
      totalVolume: model.totalVolume,
      muscles: model.muscles,
      startedAt: DateUtilities.getDateFromUnix(model.startedAt),
      completedAt: model.completedAt != null
          ? DateUtilities.getDateFromUnix(model.completedAt!)
          : null,
      setRecords: setRecords,
    );
  }

  factory WorkoutRecordDto.empty() {
    return WorkoutRecordDto(
      id: 0,
      workoutId: 0,
      currentSetPosition: 0,
      currentSetNumber: 1,
      currentExercisePosition: 0,
      totalSets: 0,
      totalReps: 0,
      totalRestSecs: 0,
      totalVolume: 0,
      muscles: TargetMuscles(primary: {}, secondary: {}),
      startedAt: DateTime.now(),
    );
  }

  @override
  WorkoutRecordDto copyWith({
    int? id,
    int? workoutId,
    int? totalSets,
    int? totalReps,
    int? totalRestSecs,
    int? totalVolume,
    TargetMuscles? muscles,
    int? currentSetPosition,
    int? currentSetNumber,
    int? currentExercisePosition,
    DateTime? startedAt,
    DateTime? completedAt,
    List<WorkoutSetRecordDto>? setRecords,
  }) {
    return WorkoutRecordDto(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      currentSetPosition: currentSetPosition ?? this.currentSetPosition,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
      currentExercisePosition:
          currentExercisePosition ?? this.currentExercisePosition,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalRestSecs: totalRestSecs ?? this.totalRestSecs,
      totalVolume: totalVolume ?? this.totalVolume,
      muscles: muscles ?? this.muscles,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      setRecords: setRecords ?? this.setRecords,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutId,
        totalSets,
        totalReps,
        totalRestSecs,
        totalVolume,
        muscles,
        currentSetPosition,
        currentSetNumber,
        currentExercisePosition,
        startedAt,
        setRecords?.length,
        completedAt,
      ];
}
