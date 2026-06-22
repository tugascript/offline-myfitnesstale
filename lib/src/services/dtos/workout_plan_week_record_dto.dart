import 'package:equatable/equatable.dart';

import '../../models/workout_plan_week_record_model.dart';
import 'dto.dart';
import 'workout_plan_day_record_dto.dart';

class WorkoutPlanWeekRecordDto extends Equatable
    implements Dto<WorkoutPlanWeekRecord> {
  @override
  final int id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekId;
  final int week;
  final DateTime? completedAt;

  final List<WorkoutPlanDayRecordDto> days;

  const WorkoutPlanWeekRecordDto({
    required this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekId,
    required this.week,
    this.completedAt,
    this.days = const [],
  });

  @override
  factory WorkoutPlanWeekRecordDto.fromModel(
    WorkoutPlanWeekRecord model, {
    List<WorkoutPlanDayRecordDto>? days,
  }) {
    return WorkoutPlanWeekRecordDto(
      id: model.id!,
      workoutPlanRecordId: model.workoutPlanRecordId,
      workoutPlanWeekId: model.workoutPlanWeekId,
      week: model.week,
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(model.completedAt! * 1000,
              isUtc: true)
          : null,
      days: days ?? const [],
    );
  }

  @override
  WorkoutPlanWeekRecordDto copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekId,
    int? week,
    DateTime? completedAt,
    List<WorkoutPlanDayRecordDto>? days,
  }) {
    return WorkoutPlanWeekRecordDto(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      week: week ?? this.week,
      completedAt: completedAt ?? this.completedAt,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanRecordId,
        workoutPlanWeekId,
        week,
        completedAt,
        days.length,
      ];
}
