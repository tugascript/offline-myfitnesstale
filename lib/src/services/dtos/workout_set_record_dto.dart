import 'package:equatable/equatable.dart';

import '../../models/workout_set_record_model.dart';
import 'workout_set_exercise_record_dto.dart';
import 'dto.dart';

class WorkoutSetRecordDto extends Equatable implements Dto<WorkoutSetRecord> {
  @override
  final int id;
  final int workoutSetId;
  final int setNumber;
  final int? totalRestSecs;
  final DateTime startedAt;
  final DateTime? completedAt;

  // Related data
  final List<WorkoutSetExerciseRecordDto>? setExerciseRecords;

  const WorkoutSetRecordDto({
    required this.id,
    required this.workoutSetId,
    required this.setNumber,
    required this.startedAt,
    this.totalRestSecs,
    this.completedAt,
    this.setExerciseRecords,
  });

  @override
  factory WorkoutSetRecordDto.fromModel(
    WorkoutSetRecord model, {
    List<WorkoutSetExerciseRecordDto>? setExerciseRecords,
  }) {
    return WorkoutSetRecordDto(
      id: model.id!,
      workoutSetId: model.workoutSetId,
      setNumber: model.setNumber,
      totalRestSecs: model.totalRestSecs,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        model.startedAt * 1000,
        isUtc: true,
      ),
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              model.completedAt! * 1000,
              isUtc: true,
            )
          : null,
      setExerciseRecords: setExerciseRecords,
    );
  }

  @override
  WorkoutSetRecordDto copyWith({
    int? id,
    int? workoutSetId,
    int? setNumber,
    int? totalRestSecs,
    DateTime? startedAt,
    DateTime? completedAt,
    List<WorkoutSetExerciseRecordDto>? setExerciseRecords,
  }) {
    return WorkoutSetRecordDto(
      id: id ?? this.id,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      setNumber: setNumber ?? this.setNumber,
      totalRestSecs: totalRestSecs ?? this.totalRestSecs,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      setExerciseRecords: setExerciseRecords ?? this.setExerciseRecords,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutSetId,
        setNumber,
        totalRestSecs,
        startedAt,
        completedAt,
      ];
}
