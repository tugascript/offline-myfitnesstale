import 'package:equatable/equatable.dart';

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
    required this.totalVolume,
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
      totalVolume: model.totalVolume,
      startedAt: DateUtilities.getDateFromUnix(model.startedAt),
      completedAt: model.completedAt != null
          ? DateUtilities.getDateFromUnix(model.completedAt!)
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
    int? totalVolume,
    DateTime? startedAt,
    DateTime? completedAt,
    List<WorkoutSetRecordDto>? setRecords,
  }) {
    return WorkoutRecordDto(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalRestSecs: totalRestSecs ?? this.totalRestSecs,
      totalVolume: totalVolume ?? this.totalVolume,
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
        startedAt,
        setRecords?.length,
        completedAt,
      ];
}
