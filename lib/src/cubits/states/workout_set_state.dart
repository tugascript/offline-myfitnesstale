import 'package:equatable/equatable.dart';

import '../../models/exercise_model.dart';
import '../../models/workout_set_exercise_model.dart';
import '../../models/workout_set_exercise_option_model.dart';
import '../../models/workout_set_model.dart';

final class WorkoutSetExerciseOptionWithExercise extends Equatable {
  final WorkoutSetExerciseOption workoutSetExerciseOption;
  final Exercise exercise;

  const WorkoutSetExerciseOptionWithExercise({
    required this.workoutSetExerciseOption,
    required this.exercise,
  });

  WorkoutSetExerciseOptionWithExercise copyWith({
    WorkoutSetExerciseOption? workoutSetExerciseOption,
    Exercise? exercise,
  }) {
    return WorkoutSetExerciseOptionWithExercise(
      workoutSetExerciseOption:
          workoutSetExerciseOption ?? this.workoutSetExerciseOption,
      exercise: exercise ?? this.exercise,
    );
  }

  @override
  List<Object?> get props => [
        workoutSetExerciseOption.id,
        workoutSetExerciseOption.createdAt,
        workoutSetExerciseOption.updatedAt,
        exercise.id,
        exercise.createdAt,
        exercise.updatedAt,
      ];
}

final class WorkoutSetExerciseWithExercise extends Equatable {
  final WorkoutSetExercise workoutSetExercise;
  final Exercise exercise;
  final List<WorkoutSetExerciseOptionWithExercise> options;

  const WorkoutSetExerciseWithExercise({
    required this.workoutSetExercise,
    required this.exercise,
    this.options = const [],
  });

  WorkoutSetExerciseWithExercise copyWith({
    WorkoutSetExercise? workoutSetExercise,
    Exercise? exercise,
    List<WorkoutSetExerciseOptionWithExercise>? options,
  }) {
    return WorkoutSetExerciseWithExercise(
      workoutSetExercise: workoutSetExercise ?? this.workoutSetExercise,
      exercise: exercise ?? this.exercise,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [
        workoutSetExercise.id,
        workoutSetExercise.createdAt,
        workoutSetExercise.updatedAt,
        exercise.id,
        exercise.createdAt,
        exercise.updatedAt,
        options.length,
      ];
}

final class WorkoutSetWithExercises extends Equatable {
  final WorkoutSet workoutSet;
  final List<WorkoutSetExerciseWithExercise> exercises;

  const WorkoutSetWithExercises({
    required this.workoutSet,
    required this.exercises,
  });

  WorkoutSetWithExercises copyWith({
    WorkoutSet? workoutSet,
    List<WorkoutSetExerciseWithExercise>? exercises,
  }) {
    return WorkoutSetWithExercises(
      workoutSet: workoutSet ?? this.workoutSet,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  List<Object?> get props => [
        workoutSet.id,
        workoutSet.createdAt,
        workoutSet.updatedAt,
      ];
}

final class WorkoutSetState extends Equatable {
  final int workoutId;
  final List<WorkoutSetWithExercises> workoutSets;
  final WorkoutSetWithExercises? selectedWorkoutSet;
  final bool isLoading;
  final String? error;

  const WorkoutSetState({
    required this.workoutId,
    required this.workoutSets,
    this.selectedWorkoutSet,
    required this.isLoading,
    this.error,
  });

  factory WorkoutSetState.initial() {
    return const WorkoutSetState(
      workoutId: 0,
      workoutSets: [],
      isLoading: false,
    );
  }

  WorkoutSetState copyWith({
    int? workoutId,
    List<WorkoutSetWithExercises>? workoutSets,
    WorkoutSetWithExercises? selectedWorkoutSet,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutSetState(
      workoutId: workoutId ?? this.workoutId,
      workoutSets: workoutSets ?? this.workoutSets,
      selectedWorkoutSet: selectedWorkoutSet ?? this.selectedWorkoutSet,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        workoutId,
        workoutSets.length,
        selectedWorkoutSet,
        isLoading,
        error,
      ];
}
