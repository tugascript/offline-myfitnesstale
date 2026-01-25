import 'package:equatable/equatable.dart';

import '../../models/workout_plan_day_record_model.dart';
import 'dto.dart';

class WorkoutPlanDayRecordDto extends Equatable implements Dto<WorkoutPlanDayRecord> {
  @override
  final int id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekRecordId;
  final int workoutPlanDayId;
  final DateTime? completedAt;

  const WorkoutPlanDayRecordDto({
    required this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekRecordId,
    required this.workoutPlanDayId,
    this.completedAt,
  });

  @override
  factory WorkoutPlanDayRecordDto.fromModel(WorkoutPlanDayRecord model) {
    return WorkoutPlanDayRecordDto(
      id: model.id!,
      workoutPlanRecordId: model.workoutPlanRecordId,
      workoutPlanWeekRecordId: model.workoutPlanWeekRecordId,
      workoutPlanDayId: model.workoutPlanDayId,
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(model.completedAt! * 1000, isUtc: true)
          : null,
    );
  }

  @override
  WorkoutPlanDayRecordDto copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayId,
    DateTime? completedAt,
  }) {
    return WorkoutPlanDayRecordDto(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekRecordId: workoutPlanWeekRecordId ?? this.workoutPlanWeekRecordId,
      workoutPlanDayId: workoutPlanDayId ?? this.workoutPlanDayId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanRecordId,
        workoutPlanWeekRecordId,
        workoutPlanDayId,
        completedAt,
      ];
}
