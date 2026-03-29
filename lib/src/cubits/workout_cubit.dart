import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/dtos/workout_dto.dart';
import '../services/entitlement_guard.dart';
import '../services/entitlement_service.dart';
import '../services/workout_service.dart';
import 'states/common_state.dart';
import 'states/workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutService _workoutService = WorkoutService();
  final EntitlementService _entitlementService = EntitlementService();

  final Logger _logger = Logger('WorkoutCubit');

  WorkoutCubit() : super(WorkoutState.initial());

  Future<void> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    int? limit,
    int? offset,
    bool isFavorite = false,
  }) async {
    _logger.info('Getting workouts');
    final isLoadMore = (offset ?? state.pagination.offset) > 0;

    // Only set loading to true if not loading more to avoid flickering or full screen loader?
    // Usually for infinite scroll we might want a different loading state or just check isLoading in UI
    // For now let's keep it simple, but we might check this in UI to show bottom loader vs full loader
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.getWorkouts(
      name: name,
      difficulty: difficulty,
      muscleGroup: muscleGroup,
      isFavorite: isFavorite,
      limit: limit ?? state.pagination.limit,
      offset: offset ?? state.pagination.offset,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workouts", error);

      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get workouts",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("Got workouts successfully");
    final paginatedData = result.value;

    late final List<WorkoutDto> updatedWorkouts;
    if (isLoadMore) {
      updatedWorkouts = [...state.workouts, ...paginatedData.data];
    } else {
      updatedWorkouts = paginatedData.data;
    }

    emit(state.copyWith(
      workouts: updatedWorkouts,
      pagination: state.pagination.copyWith(
        name: name,
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        limit: paginatedData.limit,
        offset: paginatedData.offset,
        total: paginatedData.total,
        isFavorite: isFavorite,
      ),
      isLoading: false,
    ));
  }

  Future<void> createWorkout({
    required String name,
    required bool isFavorite,
    required Difficulty difficulty,
    EditorType editorType = EditorType.basic,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Creating workout');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.createWorkout(
      name: name,
      isFavorite: isFavorite,
      difficulty: difficulty,
      editorType: editorType,
      description: description,
      picture: picture,
      video: video,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create workout", error);

      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to create workout",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("Workout created successfully");
    final workout = result.value;
    emit(state.copyWith(
      workouts: [workout, ...state.workouts],
      selectedWorkout: workout,
      pagination: state.pagination.copyWith(
        total: state.pagination.total + 1,
      ),
      error: null,
      isLoading: false,
    ));
  }

  Future<void> getWorkout(
    int id, {
    int? version,
    bool refresh = false,
  }) async {
    _logger.info('Getting workout with id $id');
    if (!refresh) {
      emit(state.copyWith(isLoading: true));
    }

    final result = await _workoutService.getWorkout(id, version: version);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: error.description,
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: "Failed to get workout",
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout got successfully");
    emit(state.copyWith(
      selectedWorkout: result.value,
      isLoading: false,
      error: null,
    ));
  }

  Future<void> updateWorkout({
    required int id,
    String? name,
    Difficulty? difficulty,
    EditorType? editorType,
    String? description,
    PictureData? picture,
    VideoData? video,
    bool? isFavorite,
  }) async {
    _logger.info('Updating workout with id $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.updateWorkout(
      id: id,
      name: name,
      difficulty: difficulty,
      editorType: editorType,
      description: description,
      picture: picture,
      video: video,
      isFavorite: isFavorite,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: error.description,
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: "Failed to update workout",
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout updated successfully");
    final workout = result.value.copyWith(
      sets: state.selectedWorkout?.id == id
          ? state.selectedWorkout?.sets
          : result.value.sets,
    );
    emit(state.copyWith(
      selectedWorkout: workout,
      workouts: state.workouts.map((w) => w.id == id ? workout : w).toList(),
      isLoading: false,
    ));
  }

  Future<void> deleteWorkout(int id) async {
    _logger.info("Deleting workout id: $id");
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.deleteWorkout(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to delete workout", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: error.description,
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: "Failed to delete workout",
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout deleted successfully");
    emit(state.copyWith(
      workouts: state.workouts.where((w) => w.id != id).toList(),
      selectedWorkout: null,
      pagination: state.pagination.copyWith(
        total: state.pagination.total - 1,
      ),
      isLoading: false,
    ));
  }

  Future<void> refreshWorkoutSets(int workoutId) async {
    _logger.info('Refreshing workout sets for workout $workoutId');

    final sets = await _workoutService.getWorkoutSets(workoutId);
    if (sets.isErr()) {
      final error = sets.error;
      _logger.warning("Failed to get workout sets", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    final updatedSets = sets.value;
    emit(state.copyWith(
      selectedWorkout: state.selectedWorkout?.copyWith(sets: updatedSets),
      isLoading: false,
    ));
  }

  Future<void> batchUpsertBasicWorkoutSets({
    required int workoutId,
    required List<StandardSetInput> sets,
  }) async {
    _logger.info('Batch updating workout sets for workout $workoutId');
    emit(state.copyWith(isLoading: true));

    final List<WorkoutSetUpsertInput> setsToUpsert = [];
    for (int i = 0; i < sets.length; i++) {
      final s = sets[i];
      setsToUpsert.add(
        WorkoutSetUpsertInput(
          id: s.id,
          setType: WorkoutSetType.standard,
          minSets: s.minSets,
          maxSets: s.maxSets >= s.minSets ? s.maxSets : null,
          recommendedRestSecs: s.recommendedRestSecs,
          maxRestSecs: s.maxRestSecs,
          position: i + 1,
          exercises: [
            WorkoutSetExerciseUpsertInput(
              id: s.setExerciseId,
              position: 1,
              exerciseId: s.exerciseId,
              minReps: s.minReps,
              maxReps: s.maxReps >= s.minReps ? s.maxReps : null,
              toMaxReps: s.toMaxReps,
            ),
          ],
        ),
      );
    }

    final result = await _workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      inputs: setsToUpsert,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to batch upsert workout sets", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    await getWorkout(workoutId, refresh: true);
  }

  Future<void> batchUpsertComplexWorkoutSets({
    required int workoutId,
    required List<ComplexSetInput> sets,
  }) async {
    _logger.info('Batch updating complex workout sets for workout $workoutId');
    if (!(await _ensurePremiumAccessForMutation())) {
      return;
    }
    emit(state.copyWith(isLoading: true));

    if (sets.isEmpty) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final List<WorkoutSetUpsertInput> setsToUpsert = [];
    for (int i = 0; i < sets.length; i++) {
      final s = sets[i];
      final exercises = s.exercises.map((exercise) {
        return WorkoutSetExerciseUpsertInput(
          id: exercise.id,
          exerciseId: exercise.exerciseId,
          position: exercise.position,
          minReps: exercise.minReps,
          maxReps:
              exercise.maxReps != null && exercise.maxReps! >= exercise.minReps
                  ? exercise.maxReps
                  : null,
          toMaxReps: exercise.toMaxReps,
          difficulty: exercise.difficulty,
          alternativeExerciseIds: exercise.alternativeExerciseIds.isEmpty
              ? null
              : exercise.alternativeExerciseIds.toList(),
        );
      }).toList();

      setsToUpsert.add(
        WorkoutSetUpsertInput(
          id: s.id,
          setType: s.setType,
          minSets: s.minSets,
          maxSets:
              s.maxSets != null && s.maxSets! >= s.minSets ? s.maxSets : null,
          recommendedRestSecs: s.recommendedRestSecs,
          maxRestSecs: s.maxRestSecs,
          position: s.position,
          exercises: exercises,
        ),
      );
    }

    final result = await _workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      inputs: setsToUpsert,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to batch upsert complex workout sets", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    await getWorkout(workoutId, refresh: true);
  }

  Future<void> getSelectionWorkouts({
    MuscleGroup? muscleGroup,
    String name = "",
    bool isFavorite = false,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.getAllWorkouts(
      muscleGroup: muscleGroup,
      name: name,
      isFavorite: isFavorite,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get selection workouts", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      workoutSelection: result.value,
      isLoading: false,
    ));
  }

  Future<bool> _ensurePremiumAccessForMutation() async {
    final snapshotResult = await _entitlementService.getEntitlementSnapshot();
    if (snapshotResult.isErr()) {
      emit(state.copyWith(
        error: const ErrorState(
          type: 'entitlement_unavailable',
          description:
              'Premium status unavailable. Please refresh and try again.',
        ),
      ));
      return false;
    }

    if (!EntitlementGuard.canUsePremium(snapshotResult.value)) {
      emit(state.copyWith(
        error: const ErrorState(
          type: 'premium_required',
          description:
              'Premium subscription required. Restore purchases or subscribe to continue.',
        ),
      ));
      return false;
    }

    return true;
  }
}

final class StandardSetInput {
  final int? id;
  final int minSets;
  final int maxSets;
  final int minReps;
  final int maxReps;
  final bool toMaxReps;
  final int recommendedRestSecs;
  final int maxRestSecs;
  final int exerciseId;
  final int? setExerciseId;

  const StandardSetInput({
    this.id,
    required this.minSets,
    required this.maxSets,
    required this.minReps,
    required this.maxReps,
    required this.toMaxReps,
    required this.recommendedRestSecs,
    required this.maxRestSecs,
    required this.exerciseId,
    this.setExerciseId,
  });
}

final class ComplexSetExerciseInput {
  final int? id;
  final int position;
  final int exerciseId;
  final int minReps;
  final int? maxReps;
  final bool toMaxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final Set<int> alternativeExerciseIds;

  const ComplexSetExerciseInput({
    this.id,
    required this.position,
    required this.exerciseId,
    required this.minReps,
    this.maxReps,
    required this.toMaxReps,
    this.difficulty,
    this.alternativeExerciseIds = const {},
  });
}

final class ComplexSetInput {
  final int? id;
  final WorkoutSetType setType;
  final int position;
  final int minSets;
  final int? maxSets;
  final int recommendedRestSecs;
  final int? maxRestSecs;
  final List<ComplexSetExerciseInput> exercises;

  const ComplexSetInput({
    this.id,
    required this.setType,
    required this.position,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.exercises,
  });
}
