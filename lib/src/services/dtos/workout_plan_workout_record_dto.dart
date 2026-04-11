import 'package:equatable/equatable.dart';

import '../../models/workout_plan_workout_record_model.dart';
import 'dto.dart';

class WorkoutPlanWorkoutRecordDto extends Equatable
    implements Dto<WorkoutPlanWorkoutRecord> {
  @override
  final int id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekRecordId;
  final int workoutPlanDayRecordId;
  final int workoutPlanWorkoutId;
  final int workoutRecordId;
  final DateTime? completedAt;

  const WorkoutPlanWorkoutRecordDto({
    required this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekRecordId,
    required this.workoutPlanDayRecordId,
    required this.workoutPlanWorkoutId,
    required this.workoutRecordId,
    this.completedAt,
  });

  @override
  factory WorkoutPlanWorkoutRecordDto.fromModel(
      WorkoutPlanWorkoutRecord model) {
    return WorkoutPlanWorkoutRecordDto(
      id: model.id!,
      workoutPlanRecordId: model.workoutPlanRecordId,
      workoutPlanWeekRecordId: model.workoutPlanWeekRecordId,
      workoutPlanDayRecordId: model.workoutPlanDayRecordId,
      workoutPlanWorkoutId: model.workoutPlanWorkoutId,
      workoutRecordId: model.workoutRecordId,
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(model.completedAt! * 1000,
              isUtc: true)
          : null,
    );
  }

  @override
  WorkoutPlanWorkoutRecordDto copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayRecordId,
    int? workoutPlanWorkoutId,
    int? workoutRecordId,
    DateTime? completedAt,
  }) {
    return WorkoutPlanWorkoutRecordDto(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekRecordId:
          workoutPlanWeekRecordId ?? this.workoutPlanWeekRecordId,
      workoutPlanDayRecordId:
          workoutPlanDayRecordId ?? this.workoutPlanDayRecordId,
      workoutPlanWorkoutId: workoutPlanWorkoutId ?? this.workoutPlanWorkoutId,
      workoutRecordId: workoutRecordId ?? this.workoutRecordId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanRecordId,
        workoutPlanWeekRecordId,
        workoutPlanDayRecordId,
        workoutPlanWorkoutId,
        workoutRecordId,
        completedAt,
      ];
}
