import 'package:equatable/equatable.dart';

import '../../models/workout_plan_day_model.dart';
import 'dto.dart';
import 'workout_plan_workout_dto.dart';

class WorkoutPlanDayDto extends Equatable implements Dto<WorkoutPlanDay> {
  @override
  final int id;
  final int planVersion;
  final int day;
  final int totalWorkouts;
  final bool isRestDay;

  // Related data
  final List<WorkoutPlanWorkoutDto>? planWorkouts;

  const WorkoutPlanDayDto({
    required this.id,
    required this.planVersion,
    required this.day,
    required this.totalWorkouts,
    required this.isRestDay,
    this.planWorkouts,
  });

  factory WorkoutPlanDayDto.fromModel(
    WorkoutPlanDay model, {
    List<WorkoutPlanWorkoutDto>? planWorkouts,
  }) {
    return WorkoutPlanDayDto(
      id: model.id!,
      planVersion: model.planVersion,
      day: model.day,
      totalWorkouts: model.totalWorkouts,
      isRestDay: model.isRestDay,
      planWorkouts: planWorkouts,
    );
  }

  @override
  WorkoutPlanDayDto copyWith({
    int? id,
    int? planVersion,
    int? day,
    bool? isRestDay,
    int? totalWorkouts,
    List<WorkoutPlanWorkoutDto>? planWorkouts,
  }) {
    return WorkoutPlanDayDto(
      id: id ?? this.id,
      planVersion: planVersion ?? this.planVersion,
      day: day ?? this.day,
      isRestDay: isRestDay ?? this.isRestDay,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      planWorkouts: planWorkouts ?? this.planWorkouts,
    );
  }

  factory WorkoutPlanDayDto.autoRestDay(int day) {
    return WorkoutPlanDayDto(
      id: 0,
      planVersion: 0,
      day: day,
      totalWorkouts: 0,
      isRestDay: true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        planVersion,
        day,
        totalWorkouts,
        isRestDay,
        planWorkouts,
      ];
}
