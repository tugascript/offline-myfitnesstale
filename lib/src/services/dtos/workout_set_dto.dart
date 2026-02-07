import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/workout_set_model.dart';
import 'dto.dart';
import 'workout_set_exercise_dto.dart';

class WorkoutSetDto extends Equatable implements Dto<WorkoutSet> {
  @override
  final int id;
  final int position;
  final WorkoutSetType setType;
  final int minSets;
  final int? maxSets;
  final int recommendedRestSecs;
  final int? maxRestSecs;
  final int totalExercises;
  final int totalReps;

  // related data
  final List<WorkoutSetExerciseDto>? exercises;

  const WorkoutSetDto({
    required this.id,
    required this.position,
    required this.setType,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.totalExercises,
    required this.totalReps,
    this.exercises,
  });

  @override
  WorkoutSetDto copyWith({
    int? id,
    int? position,
    WorkoutSetType? setType,
    int? minSets,
    int? maxSets,
    int? recommendedRestSecs,
    int? maxRestSecs,
    int? totalExercises,
    int? totalReps,
    List<WorkoutSetExerciseDto>? exercises,
  }) {
    return WorkoutSetDto(
      id: id ?? this.id,
      position: position ?? this.position,
      setType: setType ?? this.setType,
      minSets: minSets ?? this.minSets,
      maxSets: maxSets ?? this.maxSets,
      recommendedRestSecs: recommendedRestSecs ?? this.recommendedRestSecs,
      maxRestSecs: maxRestSecs ?? this.maxRestSecs,
      totalExercises: totalExercises ?? this.totalExercises,
      totalReps: totalReps ?? this.totalReps,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  List<Object?> get props => [
        id,
        position,
        setType,
        minSets,
        maxSets,
        recommendedRestSecs,
        maxRestSecs,
        totalExercises,
        totalReps,
        exercises,
      ];

  @override
  factory WorkoutSetDto.fromModel(
    WorkoutSet model, {
    List<WorkoutSetExerciseDto>? exercises,
  }) {
    return WorkoutSetDto(
      id: model.id!,
      position: model.position,
      setType: model.setType,
      minSets: model.minSets,
      maxSets: model.maxSets,
      recommendedRestSecs: model.recommendedRestSecs,
      maxRestSecs: model.maxRestSecs,
      totalExercises: model.totalExercises,
      totalReps: model.totalReps,
      exercises: exercises,
    );
  }
}
