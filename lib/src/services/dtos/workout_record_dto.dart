import 'package:equatable/equatable.dart';

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
  final DateTime startedAt;
  final DateTime? completedAt;

  // Related data
  final List<WorkoutSetRecordDto>? setRecords;

  const WorkoutRecordDto({
    required this.id,
    required this.workoutId,
    required this.totalSets,
    required this.totalReps,
    required this.totalRestSecs,
    required this.startedAt,
    this.completedAt,
    this.setRecords,
  });

  @override
  factory WorkoutRecordDto.fromModel(
    WorkoutRecord model, {
    List<WorkoutSetRecordDto>? setRecords,
  }) {
    return WorkoutRecordDto(
      id: model.id!,
      workoutId: model.workoutId,
      totalSets: model.totalSets,
      totalReps: model.totalReps,
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
      setRecords: setRecords,
    );
  }

  @override
  WorkoutRecordDto copyWith({
    int? id,
    int? workoutId,
    int? totalSets,
    int? totalReps,
    int? totalRestSecs,
    DateTime? startedAt,
    DateTime? completedAt,
    double? weight,
    int? reps,
    List<WorkoutSetRecordDto>? setRecords,
  }) {
    return WorkoutRecordDto(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalRestSecs: totalRestSecs ?? this.totalRestSecs,
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
        startedAt,
        setRecords?.length,
        completedAt,
      ];
}
