import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/workout_plan_service.dart';
import 'states/common_state.dart';
import 'states/workout_plan_state.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();

  WorkoutPlanCubit() : super(WorkoutPlanState.initial());

  final Logger _logger = Logger('WorkoutPlanCubit');

  Future<void> getWorkoutPlans({
    String? name,
    Difficulty? difficulty,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Getting workout plans');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.getWorkoutPlans(
      name: name,
      difficulty: difficulty,
      limit: limit ?? state.pagination.limit,
      offset: offset ?? state.pagination.offset,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout plans", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get workout plans",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Workout plans retrieved successfully');
    final paginatedData = result.value;
    emit(
      state.copyWith(
        workoutPlans: paginatedData.data,
        pagination: state.pagination.copyWith(
          name: name,
          difficulty: difficulty,
          limit: paginatedData.limit,
          offset: paginatedData.offset,
          total: paginatedData.total,
        ),
        isLoading: false,
      ),
    );
  }

  Future<void> getWorkoutPlan(int id) async {
    _logger.info('Getting workout plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.getWorkoutPlan(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout plan $id", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Workout plan $id retrieved successfully');
    emit(state.copyWith(
      selectedWorkoutPlan: result.value,
      isLoading: false,
    ));
  }

  Future<void> createWorkoutPlan({
    required String name,
    required int totalWeeks,
    required Difficulty difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Creating workout plan');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.createWorkoutPlan(
      name: name,
      totalWeeks: totalWeeks,
      difficulty: difficulty,
      description: description,
      picture: picture,
      video: video,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create workout plan", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    _logger.info('Workout plan created successfully');
    final newPlan = result.value;
    emit(state.copyWith(
      workoutPlans: [newPlan, ...state.workoutPlans],
      pagination: state.pagination.copyWith(
        total: state.pagination.total + 1,
      ),
      isLoading: false,
    ));
  }

  Future<void> updateWorkoutPlan({
    required int id,
    String? name,
    int? totalWeeks,
    Difficulty? difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Updating workout plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.updateWorkoutPlan(
      id,
      name: name,
      totalWeeks: totalWeeks,
      difficulty: difficulty,
      description: description,
      picture: picture,
      video: video,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout plan $id", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    _logger.info('Workout plan $id updated successfully');
    final updatedPlan = result.value;
    emit(state.copyWith(
      workoutPlans:
          state.workoutPlans.map((p) => p.id == id ? updatedPlan : p).toList(),
      selectedWorkoutPlan: state.selectedWorkoutPlan?.id == id
          ? updatedPlan
          : state.selectedWorkoutPlan,
      isLoading: false,
    ));
  }

  Future<void> deleteWorkoutPlan(int id) async {
    _logger.info('Deleting workout plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.deleteWorkoutPlan(id);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to delete workout plan $id", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    _logger.info('Workout plan $id deleted successfully');
    emit(state.copyWith(
      workoutPlans: state.workoutPlans.where((p) => p.id != id).toList(),
      selectedWorkoutPlan: state.selectedWorkoutPlan?.id == id
          ? null
          : state.selectedWorkoutPlan,
      pagination: state.pagination.copyWith(
        total: state.pagination.total - 1,
      ),
      isLoading: false,
    ));
  }
}
