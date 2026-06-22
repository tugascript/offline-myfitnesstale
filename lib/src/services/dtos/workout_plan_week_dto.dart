import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/workout_plan_week_model.dart';
import 'dto.dart';
import 'workout_plan_day_dto.dart';

class WorkoutPlanWeekDto extends Equatable implements Dto<WorkoutPlanWeek> {
  @override
  final int id;
  final int planVersion;
  final int startWeek;
  final int endWeek;
  final int totalDays;
  final int totalWorkouts;
  final WorkoutPlanWeekScheduleMode scheduleMode;
  final WorkoutPhase? phase;

  // Related data
  final List<WorkoutPlanDayDto> days;

  const WorkoutPlanWeekDto({
    required this.id,
    required this.planVersion,
    required this.startWeek,
    required this.endWeek,
    required this.totalDays,
    required this.totalWorkouts,
    required this.scheduleMode,
    this.phase,
    this.days = const [],
  });

  @override
  factory WorkoutPlanWeekDto.fromModel(
    WorkoutPlanWeek model, {
    List<WorkoutPlanDayDto>? days,
  }) {
    return WorkoutPlanWeekDto(
      id: model.id!,
      planVersion: model.planVersion,
      startWeek: model.startWeek,
      endWeek: model.endWeek,
      totalDays: model.totalDays,
      totalWorkouts: model.totalWorkouts,
      scheduleMode: model.scheduleMode,
      phase: model.phase,
      days: days ?? const [],
    );
  }

  @override
  WorkoutPlanWeekDto copyWith({
    int? id,
    int? planVersion,
    int? startWeek,
    int? endWeek,
    int? totalDays,
    int? totalWorkouts,
    WorkoutPlanWeekScheduleMode? scheduleMode,
    WorkoutPhase? phase,
    List<WorkoutPlanDayDto>? days,
  }) {
    return WorkoutPlanWeekDto(
      id: id ?? this.id,
      planVersion: planVersion ?? this.planVersion,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      totalDays: totalDays ?? this.totalDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      phase: phase ?? this.phase,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [
        id,
        planVersion,
        startWeek,
        endWeek,
        totalDays,
        totalWorkouts,
        scheduleMode,
        phase,
        days.length,
      ];
}
