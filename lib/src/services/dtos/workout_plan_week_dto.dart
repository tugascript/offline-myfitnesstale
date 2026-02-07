import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/workout_plan_week_model.dart';
import 'dto.dart';
import 'workout_plan_day_dto.dart';

class WorkoutPlanWeekDto extends Equatable implements Dto<WorkoutPlanWeek> {
  @override
  final int id;
  final int startWeek;
  final int endWeek;
  final int totalDays;
  final int totalWorkouts;
  final WorkoutPlanWeekScheduleMode scheduleMode;
  final WorkoutPhase? phase;

  // Related data
  final List<WorkoutPlanDayDto>? days;

  const WorkoutPlanWeekDto({
    required this.id,
    required this.startWeek,
    required this.endWeek,
    required this.totalDays,
    required this.totalWorkouts,
    required this.scheduleMode,
    this.phase,
    this.days,
  });

  @override
  factory WorkoutPlanWeekDto.fromModel(
    WorkoutPlanWeek model, {
    List<WorkoutPlanDayDto>? days,
  }) {
    return WorkoutPlanWeekDto(
      id: model.id!,
      startWeek: model.startWeek,
      endWeek: model.endWeek,
      totalDays: model.totalDays,
      totalWorkouts: model.totalWorkouts,
      scheduleMode: model.scheduleMode,
      phase: model.phase,
      days: days,
    );
  }

  @override
  WorkoutPlanWeekDto copyWith({
    int? id,
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
        startWeek,
        endWeek,
        totalDays,
        totalWorkouts,
        scheduleMode,
        phase,
        days?.length,
      ];
}
