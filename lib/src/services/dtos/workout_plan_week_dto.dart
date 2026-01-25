import 'package:equatable/equatable.dart';

import '../../models/workout_plan_week_model.dart';
import 'dto.dart';
import 'workout_plan_day_dto.dart';

class WorkoutPlanWeekDto extends Equatable implements Dto<WorkoutPlanWeek> {
  @override
  final int id;
  final int startWeek;
  final int endWeek;

  // Related data
  final List<WorkoutPlanDayDto>? days;

  const WorkoutPlanWeekDto({
    required this.id,
    required this.startWeek,
    required this.endWeek,
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
      days: days,
    );
  }

  @override
  WorkoutPlanWeekDto copyWith({
    int? id,
    int? startWeek,
    int? endWeek,
    List<WorkoutPlanDayDto>? days,
  }) {
    return WorkoutPlanWeekDto(
      id: id ?? this.id,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [id, startWeek, endWeek];
}
