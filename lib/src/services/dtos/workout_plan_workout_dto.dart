import 'package:equatable/equatable.dart';

import '../../models/workout_plan_workout_model.dart';
import '../../models/enums.dart';
import 'dto.dart';
import 'workout_dto.dart';

class WorkoutPlanWorkoutDto extends Equatable
    implements Dto<WorkoutPlanWorkout> {
  @override
  final int id;
  final int position;
  final TimeOfDay? timeOfDay;
  final int workoutId;

  // Related data
  final WorkoutDto? workout;

  const WorkoutPlanWorkoutDto({
    required this.id,
    required this.position,
    this.timeOfDay,
    required this.workoutId,
    this.workout,
  });

  @override
  factory WorkoutPlanWorkoutDto.fromModel(
    WorkoutPlanWorkout model, {
    WorkoutDto? workout,
  }) {
    return WorkoutPlanWorkoutDto(
      id: model.id!,
      position: model.position,
      timeOfDay: model.timeOfDay,
      workoutId: model.workoutId,
      workout: workout,
    );
  }

  @override
  WorkoutPlanWorkoutDto copyWith({
    int? id,
    int? position,
    TimeOfDay? timeOfDay,
    int? workoutId,
    WorkoutDto? workout,
  }) {
    return WorkoutPlanWorkoutDto(
      id: id ?? this.id,
      position: position ?? this.position,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      workoutId: workoutId ?? this.workoutId,
      workout: workout ?? this.workout,
    );
  }

  @override
  List<Object?> get props => [
        id,
        position,
        timeOfDay,
        workoutId,
        workout,
      ];
}
