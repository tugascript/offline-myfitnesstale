import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/entitlement_guard.dart';
import '../services/entitlement_service.dart';
import '../services/workout_plan_service.dart';
import 'states/common_state.dart';
import 'states/workout_plan_state.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  final EntitlementService _entitlementService = EntitlementService();

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

  Future<void> getWorkoutPlan(int id, {bool isRefresh = false}) async {
    _logger.info('Getting workout plan $id');
    if (!isRefresh) {
      emit(state.copyWith(isLoading: true));
    }

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

  Future<void> createWorkoutPlanVersionWithWeeks({
    required int workoutPlanId,
    required List<WorkoutPlanWeekBatchCreateInput> weeks,
  }) async {
    _logger.info('Creating workout plan version for plan $workoutPlanId');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: weeks,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create workout plan version", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    await getWorkoutPlan(workoutPlanId, isRefresh: true);
  }

  Future<void> createWorkoutPlan({
    required String name,
    required Difficulty difficulty,
    required bool isFavorite,
    int totalWeeks = 0,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Creating workout plan');
    emit(state.copyWith(isLoading: true));

    final entitlementSnapshotResult =
        await _entitlementService.getEntitlementSnapshot();
    if (entitlementSnapshotResult.isErr()) {
      emit(state.copyWith(
        error: const ErrorState(
          type: 'entitlement_unavailable',
          description:
              'Premium status unavailable. Please refresh and try again.',
        ),
        isLoading: false,
      ));
      return;
    }

    final bool isPremium =
        EntitlementGuard.canUsePremium(entitlementSnapshotResult.value);
    if (!isPremium) {
      final countResult = await _workoutPlanService.countWorkoutPlans(
        createdBy: CreatedBy.user,
      );
      if (countResult.isErr()) {
        emit(state.copyWith(
          error: ErrorState(
            type: countResult.error.type.name,
            description: countResult.error.description,
          ),
          isLoading: false,
        ));
        return;
      }

      if (countResult.value >= 3) {
        emit(state.copyWith(
          error: const ErrorState(
            type: 'plan_limit_reached',
            description:
                'Free users can create up to 3 workout plans. Upgrade to premium to create more.',
          ),
          isLoading: false,
        ));
        return;
      }
    }

    final result = await _workoutPlanService.createWorkoutPlan(
      name: name,
      totalWeeks: totalWeeks,
      difficulty: difficulty,
      isFavorite: isFavorite,
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
      selectedWorkoutPlan: newPlan,
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
    bool? isFavorite,
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
      isFavorite: isFavorite,
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
    await getWorkoutPlan(id, isRefresh: true);
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
