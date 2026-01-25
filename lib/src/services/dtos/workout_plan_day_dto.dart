import 'package:equatable/equatable.dart';

import '../../models/workout_plan_day_model.dart';
import 'dto.dart';
import 'workout_plan_workout_dto.dart';

class WorkoutPlanDayDto extends Equatable implements Dto<WorkoutPlanDay> {
  @override
  final int id;
  final int day;

  // Related data
  final List<WorkoutPlanWorkoutDto>? planWorkouts;

  const WorkoutPlanDayDto({
    required this.id,
    required this.day,
    this.planWorkouts,
  });

  @override
  factory WorkoutPlanDayDto.fromModel(
    WorkoutPlanDay model, {
    List<WorkoutPlanWorkoutDto>? planWorkouts,
  }) {
    return WorkoutPlanDayDto(
      id: model.id!,
      day: model.day,
      planWorkouts: planWorkouts,
    );
  }

  @override
  WorkoutPlanDayDto copyWith({
    int? id,
    int? day,
    List<WorkoutPlanWorkoutDto>? planWorkouts,
  }) {
    return WorkoutPlanDayDto(
      id: id ?? this.id,
      day: day ?? this.day,
      planWorkouts: planWorkouts ?? this.planWorkouts,
    );
  }

  @override
  List<Object?> get props => [id, day, planWorkouts];
}
