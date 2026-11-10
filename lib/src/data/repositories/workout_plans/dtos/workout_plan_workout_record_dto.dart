import 'package:equatable/equatable.dart';

import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/models/workout_plan_workout_record_model.dart';
import 'package:myfitnesstale/src/data/repositories/core/dtos/dto.dart';

class WorkoutPlanWorkoutRecordDto extends Equatable
    implements Dto<WorkoutPlanWorkoutRecord> {
  @override
  final int id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekRecordId;
  final int workoutPlanDayRecordId;
  final int workoutPlanWorkoutId;
  final int workoutRecordId;
  final int position;
  final DateTime startedAt;
  final ProgressStatus status;
  final DateTime? completedAt;

  const WorkoutPlanWorkoutRecordDto({
    required this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekRecordId,
    required this.workoutPlanDayRecordId,
    required this.workoutPlanWorkoutId,
    required this.workoutRecordId,
    required this.position,
    required this.startedAt,
    required this.status,
    this.completedAt,
  });

  factory WorkoutPlanWorkoutRecordDto.fromModel(
    WorkoutPlanWorkoutRecord model,
  ) {
    return WorkoutPlanWorkoutRecordDto(
      id: model.id!,
      workoutPlanRecordId: model.workoutPlanRecordId,
      workoutPlanWeekRecordId: model.workoutPlanWeekRecordId,
      workoutPlanDayRecordId: model.workoutPlanDayRecordId,
      workoutPlanWorkoutId: model.workoutPlanWorkoutId,
      workoutRecordId: model.workoutRecordId,
      position: model.position,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        model.startedAt * 1000,
        isUtc: true,
      ),
      status: model.status,
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              model.completedAt! * 1000,
              isUtc: true,
            )
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
    int? position,
    DateTime? startedAt,
    ProgressStatus? status,
    Nullable<DateTime>? completedAt,
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
      position: position ?? this.position,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
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
    position,
    startedAt,
    status,
    completedAt,
  ];
}
