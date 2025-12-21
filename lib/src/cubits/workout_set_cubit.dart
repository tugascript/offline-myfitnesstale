import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../models/workout_set_exercise_model.dart';
import '../models/workout_set_exercise_option_model.dart';
import '../models/workout_set_model.dart';
import '../services/exercise_service.dart';
import '../services/workout_set_exercise_service.dart';
import '../services/workout_set_exercise_option_service.dart';
import '../services/workout_set_service.dart';
import 'states/workout_set_state.dart';

class WorkoutSetCubit extends Cubit<WorkoutSetState> {
  final WorkoutSetService _workoutSetService = WorkoutSetService();
  final WorkoutSetExerciseService _workoutSetExerciseService =
      WorkoutSetExerciseService();
  final WorkoutSetExerciseOptionService _workoutSetExerciseOptionService =
      WorkoutSetExerciseOptionService();
  final ExerciseService _exerciseService = ExerciseService();

  WorkoutSetCubit() : super(WorkoutSetState.initial());

  Future<void> getWorkoutSets(int workoutId) async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<WorkoutSet> workoutSets =
          await _workoutSetService.getWorkoutSets(workoutId);
      final Map<int, List<WorkoutSetExercise>> setExercises =
          await _workoutSetExerciseService
              .getWorkoutSetExercisesByWorkoutIdSetLoader(workoutId);
      final Map<int, List<WorkoutSetExerciseOption>> exerciseOptions =
          await _workoutSetExerciseOptionService
              .getWorkoutSetExerciseOptionsByWorkoutIdLoader(workoutId);

      final List<int> allExerciseIds = [
        ...setExercises.values
            .expand((element) => element)
            .map((e) => e.exerciseId),
        ...exerciseOptions.values
            .expand((element) => element)
            .map((e) => e.exerciseId),
      ];

      final Map<int, Exercise> exercises =
          await _exerciseService.getExercisesByIdsLoader(allExerciseIds);

      emit(state.copyWith(
        workoutId: workoutId,
        workoutSets: workoutSets.map((workoutSet) {
          return WorkoutSetWithExercises(
            workoutSet: workoutSet,
            exercises:
                (setExercises[workoutSet.id] ?? []).map((workoutSetExercise) {
              final List<WorkoutSetExerciseOptionWithExercise> options =
                  (exerciseOptions[workoutSetExercise.id] ?? [])
                      .map((option) => WorkoutSetExerciseOptionWithExercise(
                            workoutSetExerciseOption: option,
                            exercise: exercises[option.exerciseId]!,
                          ))
                      .toList();
              return WorkoutSetExerciseWithExercise(
                workoutSetExercise: workoutSetExercise,
                exercise: exercises[workoutSetExercise.exerciseId]!,
                options: options,
              );
            }).toList(),
          );
        }).toList(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> createWorkoutSet({
    required int workoutId,
    required int minSets,
    required int recommendedRestSecs,
    required List<WorkoutSetExerciseInput> exerciseInputs,
    int? maxSets,
    int? maxRestSecs,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final WorkoutSet workoutSet = await _workoutSetService.createWorkoutSet(
        workoutId: workoutId,
        minSets: minSets,
        recommendedRestSecs: recommendedRestSecs,
        exercises: exerciseInputs,
        maxSets: maxSets,
        maxRestSecs: maxRestSecs,
      );
      final List<WorkoutSetExercise> workoutSetExercises =
          await _workoutSetExerciseService
              .getWorkoutSetExercises(workoutSet.id!);
      final Map<int, List<WorkoutSetExerciseOption>> exerciseOptions = {};
      for (final exercise in workoutSetExercises) {
        if (exercise.id != null) {
          exerciseOptions[exercise.id!] =
              await _workoutSetExerciseOptionService
                  .getWorkoutSetExerciseOptions(exercise.id!);
        }
      }

      final List<int> allExerciseIds = [
        ...workoutSetExercises.map((e) => e.exerciseId),
        ...exerciseOptions.values
            .expand((element) => element)
            .map((e) => e.exerciseId),
      ];

      final Map<int, Exercise> exercises =
          await _exerciseService.getExercisesByIdsLoader(allExerciseIds);
      final WorkoutSetWithExercises workoutSetWithExercises =
          WorkoutSetWithExercises(
        workoutSet: workoutSet,
        exercises: workoutSetExercises
            .map((workoutSetExercise) {
              final List<WorkoutSetExerciseOptionWithExercise> options =
                  (workoutSetExercise.id != null
                          ? exerciseOptions[workoutSetExercise.id!] ?? []
                          : [])
                      .map((option) => WorkoutSetExerciseOptionWithExercise(
                            workoutSetExerciseOption: option,
                            exercise: exercises[option.exerciseId]!,
                          ))
                      .toList();
              return WorkoutSetExerciseWithExercise(
                workoutSetExercise: workoutSetExercise,
                exercise: exercises[workoutSetExercise.exerciseId]!,
                options: options,
              );
            })
            .toList(),
      );

      emit(state.copyWith(
        workoutSets: [
          ...state.workoutSets,
          workoutSetWithExercises,
        ],
        selectedWorkoutSet: workoutSetWithExercises,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateWorkoutSet(
    int id, {
    int? minSets,
    int? recommendedRestSecs,
    int? maxSets,
    int? maxRestSecs,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final WorkoutSet? workoutSet = await _workoutSetService.updateWorkoutSet(
        id,
        minSets: minSets,
        recommendedRestSecs: recommendedRestSecs,
        maxSets: maxSets,
        maxRestSecs: maxRestSecs,
      );

      if (workoutSet == null) {
        emit(state.copyWith(
          error: 'Workout set not found',
          isLoading: false,
        ));
        return;
      }

      emit(state.copyWith(
        workoutSets: state.workoutSets
            .map((w) => w.workoutSet.id == workoutSet.id
                ? w.copyWith(workoutSet: workoutSet)
                : w)
            .toList(),
        selectedWorkoutSet: state.selectedWorkoutSet?.copyWith(
          workoutSet: workoutSet,
        ),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateWorkoutSetPosition(int id, int position) async {
    emit(state.copyWith(isLoading: true));

    final WorkoutSet? workoutSet =
        await _workoutSetService.updateWorkoutSetPosition(id, position);

    if (workoutSet == null) {
      emit(state.copyWith(
        error: 'Workout set not found',
        isLoading: false,
      ));
      return;
    }

      final List<WorkoutSet> workoutSets =
          await _workoutSetService.getWorkoutSets(workoutSet.workoutId);
      final Map<int, List<WorkoutSetExercise>> setExercises =
          await _workoutSetExerciseService
              .getWorkoutSetExercisesByWorkoutIdSetLoader(workoutSet.workoutId);
      final Map<int, List<WorkoutSetExerciseOption>> exerciseOptions =
          await _workoutSetExerciseOptionService
              .getWorkoutSetExerciseOptionsByWorkoutIdLoader(
        workoutSet.workoutId,
      );

      final List<int> allExerciseIds = [
        ...setExercises.values
            .expand((element) => element)
            .map((e) => e.exerciseId),
        ...exerciseOptions.values
            .expand((element) => element)
            .map((e) => e.exerciseId),
      ];

      final Map<int, Exercise> exercises =
          await _exerciseService.getExercisesByIdsLoader(allExerciseIds);

      emit(state.copyWith(
        workoutSets: workoutSets.map((workoutSet) {
          return WorkoutSetWithExercises(
            workoutSet: workoutSet,
            exercises:
                (setExercises[workoutSet.id] ?? []).map((workoutSetExercise) {
              final List<WorkoutSetExerciseOptionWithExercise> options =
                  (exerciseOptions[workoutSetExercise.id] ?? [])
                      .map((option) => WorkoutSetExerciseOptionWithExercise(
                            workoutSetExerciseOption: option,
                            exercise: exercises[option.exerciseId]!,
                          ))
                      .toList();
              return WorkoutSetExerciseWithExercise(
                workoutSetExercise: workoutSetExercise,
                exercise: exercises[workoutSetExercise.exerciseId]!,
                options: options,
              );
            }).toList(),
          );
        }).toList(),
        isLoading: false,
      ));
  }

  Future<void> deleteWorkoutSet(int id) async {
    emit(state.copyWith(isLoading: true));

    final bool deleted = await _workoutSetService.deleteWorkoutSet(id);

    if (!deleted) {
      emit(state.copyWith(
        error: 'Workout set not found',
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      workoutSets: state.workoutSets
          .where((workoutSet) => workoutSet.workoutSet.id != id)
          .toList(),
      selectedWorkoutSet: null,
      isLoading: false,
    ));
  }

  Future<void> addWorkoutSetExercise({
    required int workoutSetId,
    required int exerciseId,
    required int minReps,
    int? maxReps,
    (int, WorkoutSetExerciseDifficulty)? difficulty,
    List<int>? alternativeExerciseIds,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final int workoutSetIndex = state.workoutSets
          .indexWhere((workoutSet) => workoutSet.workoutSet.id == workoutSetId);

      if (workoutSetIndex == -1) {
        emit(state.copyWith(
          error: 'Workout set not found',
          isLoading: false,
        ));
        return;
      }

      final WorkoutSet workoutSet =
          state.workoutSets[workoutSetIndex].workoutSet;
      final Exercise? exercise = await _exerciseService.getExercise(exerciseId);

      if (exercise == null) {
        emit(state.copyWith(
          error: 'Exercise not found',
          isLoading: false,
        ));
        return;
      }

      final WorkoutSetExercise workoutSetExercise =
          await _workoutSetExerciseService.createWorkoutSetExercise(
        workoutId: workoutSet.workoutId,
        workoutSetId: workoutSetId,
        exerciseId: exerciseId,
        minReps: minReps,
        maxReps: maxReps,
        difficulty: difficulty?.$1,
        difficultyText: difficulty?.$2,
        alternativeExerciseIds: alternativeExerciseIds,
      );

      // Load options if they were created
      final List<WorkoutSetExerciseOption> options = workoutSetExercise.id != null
          ? await _workoutSetExerciseOptionService
              .getWorkoutSetExerciseOptions(workoutSetExercise.id!)
          : [];
      final List<int> optionExerciseIds =
          options.map((o) => o.exerciseId).toList();
      final Map<int, Exercise> optionExercises =
          optionExerciseIds.isNotEmpty
              ? await _exerciseService.getExercisesByIdsLoader(optionExerciseIds)
              : {};

      final List<WorkoutSetExerciseOptionWithExercise> optionWithExercises =
          options
              .map((option) => WorkoutSetExerciseOptionWithExercise(
                    workoutSetExerciseOption: option,
                    exercise: optionExercises[option.exerciseId]!,
                  ))
              .toList();

      final List<WorkoutSetWithExercises> workoutSets = state.workoutSets;
      workoutSets[workoutSetIndex] =
          workoutSets[workoutSetIndex].copyWith(exercises: [
        ...workoutSets[workoutSetIndex].exercises,
        WorkoutSetExerciseWithExercise(
          workoutSetExercise: workoutSetExercise,
          exercise: exercise,
          options: optionWithExercises,
        ),
      ]);
      emit(state.copyWith(
        workoutSets: workoutSets,
        selectedWorkoutSet: state.selectedWorkoutSet?.copyWith(
          exercises: [
            ...state.selectedWorkoutSet!.exercises,
            WorkoutSetExerciseWithExercise(
              workoutSetExercise: workoutSetExercise,
              exercise: exercise,
              options: optionWithExercises,
            ),
          ],
        ),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> addWorkoutSetExerciseOption({
    required int workoutSetExerciseId,
    required int exerciseId,
    required int position,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final WorkoutSetExerciseOption option =
          await _workoutSetExerciseOptionService.createWorkoutSetExerciseOption(
        workoutSetExerciseId: workoutSetExerciseId,
        exerciseId: exerciseId,
        position: position,
      );

      final Exercise? exercise = await _exerciseService.getExercise(exerciseId);
      if (exercise == null) {
        emit(state.copyWith(
          error: 'Exercise not found',
          isLoading: false,
        ));
        return;
      }

      // Update state with new option
      final List<WorkoutSetWithExercises> updatedWorkoutSets =
          state.workoutSets.map((workoutSet) {
        return workoutSet.copyWith(
          exercises: workoutSet.exercises.map((exerciseWithExercise) {
            if (exerciseWithExercise.workoutSetExercise.id ==
                workoutSetExerciseId) {
              return exerciseWithExercise.copyWith(
                options: [
                  ...exerciseWithExercise.options,
                  WorkoutSetExerciseOptionWithExercise(
                    workoutSetExerciseOption: option,
                    exercise: exercise,
                  ),
                ],
              );
            }
            return exerciseWithExercise;
          }).toList(),
        );
      }).toList();

      emit(state.copyWith(
        workoutSets: updatedWorkoutSets,
        selectedWorkoutSet: state.selectedWorkoutSet?.copyWith(
          exercises: state.selectedWorkoutSet!.exercises.map((exerciseWithExercise) {
            if (exerciseWithExercise.workoutSetExercise.id ==
                workoutSetExerciseId) {
              return exerciseWithExercise.copyWith(
                options: [
                  ...exerciseWithExercise.options,
                  WorkoutSetExerciseOptionWithExercise(
                    workoutSetExerciseOption: option,
                    exercise: exercise,
                  ),
                ],
              );
            }
            return exerciseWithExercise;
          }).toList(),
        ),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateWorkoutSetExerciseOptionPosition(
    int optionId,
    int position,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final WorkoutSetExerciseOption updatedOption =
          await _workoutSetExerciseOptionService
              .updateWorkoutSetExerciseOptionPosition(optionId, position);

      // Update state
      final List<WorkoutSetWithExercises> updatedWorkoutSets =
          state.workoutSets.map((workoutSet) {
        return workoutSet.copyWith(
          exercises: workoutSet.exercises.map((exerciseWithExercise) {
            final int optionIndex = exerciseWithExercise.options
                .indexWhere((opt) => opt.workoutSetExerciseOption.id == optionId);
            if (optionIndex != -1) {
              final List<WorkoutSetExerciseOptionWithExercise> updatedOptions =
                  List.from(exerciseWithExercise.options);
              updatedOptions[optionIndex] =
                  exerciseWithExercise.options[optionIndex].copyWith(
                workoutSetExerciseOption: updatedOption,
              );
              return exerciseWithExercise.copyWith(options: updatedOptions);
            }
            return exerciseWithExercise;
          }).toList(),
        );
      }).toList();

      emit(state.copyWith(
        workoutSets: updatedWorkoutSets,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> deleteWorkoutSetExerciseOption(int optionId) async {
    emit(state.copyWith(isLoading: true));

    try {
      final bool deleted =
          await _workoutSetExerciseOptionService
              .deleteWorkoutSetExerciseOption(optionId);

      if (!deleted) {
        emit(state.copyWith(
          error: 'Exercise option not found',
          isLoading: false,
        ));
        return;
      }

      // Update state
      final List<WorkoutSetWithExercises> updatedWorkoutSets =
          state.workoutSets.map((workoutSet) {
        return workoutSet.copyWith(
          exercises: workoutSet.exercises.map((exerciseWithExercise) {
            return exerciseWithExercise.copyWith(
              options: exerciseWithExercise.options
                  .where((opt) => opt.workoutSetExerciseOption.id != optionId)
                  .toList(),
            );
          }).toList(),
        );
      }).toList();

      emit(state.copyWith(
        workoutSets: updatedWorkoutSets,
        selectedWorkoutSet: state.selectedWorkoutSet?.copyWith(
          exercises: state.selectedWorkoutSet!.exercises.map((exerciseWithExercise) {
            return exerciseWithExercise.copyWith(
              options: exerciseWithExercise.options
                  .where((opt) => opt.workoutSetExerciseOption.id != optionId)
                  .toList(),
            );
          }).toList(),
        ),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}
