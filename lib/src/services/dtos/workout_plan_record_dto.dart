import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/workout_plan_record_model.dart';
import 'dto.dart';
import 'workout_plan_week_record_dto.dart';

class WorkoutPlanRecordDto extends Equatable implements Dto<WorkoutPlanRecord> {
  @override
  final int id;
  final int workoutPlanId;
  final int workoutPlanVersion;
  final ProgressStatus status;
  final int currentWeek;
  final int currentDay;
  final int currentWorkoutPosition;
  final DateTime startedAt;
  final DateTime? completedAt;

  final List<WorkoutPlanWeekRecordDto> weeks;

  const WorkoutPlanRecordDto({
    required this.id,
    required this.workoutPlanId,
    required this.workoutPlanVersion,
    required this.status,
    required this.currentWeek,
    required this.currentDay,
    required this.currentWorkoutPosition,
    required this.startedAt,
    this.completedAt,
    this.weeks = const [],
  });

  factory WorkoutPlanRecordDto.fromModel(
    WorkoutPlanRecord model, {
    List<WorkoutPlanWeekRecordDto>? weeks,
  }) {
    return WorkoutPlanRecordDto(
      id: model.id!,
      workoutPlanId: model.workoutPlanId,
      workoutPlanVersion: model.workoutPlanVersion,
      status: model.status,
      currentWeek: model.currentWeek,
      currentDay: model.currentDay,
      currentWorkoutPosition: model.currentWorkoutPosition,
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
      weeks: weeks ?? const [],
    );
  }

  @override
  WorkoutPlanRecordDto copyWith({
    int? id,
    int? workoutPlanId,
    int? workoutPlanVersion,
    ProgressStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentWeek,
    int? currentDay,
    int? currentWorkoutPosition,
    List<WorkoutPlanWeekRecordDto>? weeks,
  }) {
    return WorkoutPlanRecordDto(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanVersion: workoutPlanVersion ?? this.workoutPlanVersion,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      currentWorkoutPosition:
          currentWorkoutPosition ?? this.currentWorkoutPosition,
      weeks: weeks ?? this.weeks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanId,
        workoutPlanVersion,
        status,
        startedAt,
        completedAt,
        currentWeek,
        currentDay,
        currentWorkoutPosition,
        weeks.length,
      ];
}
