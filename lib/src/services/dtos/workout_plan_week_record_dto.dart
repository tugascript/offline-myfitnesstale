import 'package:equatable/equatable.dart';

import '../../models/workout_plan_week_record_model.dart';
import 'dto.dart';

class WorkoutPlanWeekRecordDto extends Equatable implements Dto<WorkoutPlanWeekRecord> {
  @override
  final int id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekId;
  final int week;
  final DateTime? completedAt;

  const WorkoutPlanWeekRecordDto({
    required this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekId,
    required this.week,
    this.completedAt,
  });

  @override
  factory WorkoutPlanWeekRecordDto.fromModel(WorkoutPlanWeekRecord model) {
    return WorkoutPlanWeekRecordDto(
      id: model.id!,
      workoutPlanRecordId: model.workoutPlanRecordId,
      workoutPlanWeekId: model.workoutPlanWeekId,
      week: model.week,
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(model.completedAt! * 1000, isUtc: true)
          : null,
    );
  }

  @override
  WorkoutPlanWeekRecordDto copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekId,
    int? week,
    DateTime? completedAt,
  }) {
    return WorkoutPlanWeekRecordDto(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      week: week ?? this.week,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanRecordId,
        workoutPlanWeekId,
        week,
        completedAt,
      ];
}
