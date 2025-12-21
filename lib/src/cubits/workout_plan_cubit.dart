import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/enums.dart';
import '../models/workout_plan_model.dart';
import '../services/current_workout_plan_record_service.dart';
import '../services/workout_plan_record_service.dart';
import '../services/workout_plan_service.dart';
import 'states/workout_plan_state.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  final WorkoutPlanRecordService _workoutPlanRecordService =
      WorkoutPlanRecordService();
  final CurrentWorkoutPlanRecordService _currentWorkoutPlanRecordService =
      CurrentWorkoutPlanRecordService();

  WorkoutPlanCubit() : super(WorkoutPlanState.initial());

  Future<void> getWorkoutPlans({
    String? name,
    Difficulty? difficulty,
    int? limit,
    int? offset,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<WorkoutPlan> plans = await _workoutPlanService.getWorkoutPlans(
        name: name,
        difficulty: difficulty,
        limit: limit,
        offset: offset,
      );

      emit(state.copyWith(
        workoutPlans: plans,
        pagination: state.pagination.copyWith(
          name: name,
          difficulty: difficulty?.value,
          limit: limit,
          offset: offset,
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

  Future<void> getWorkoutPlan(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final WorkoutPlan? plan = await _workoutPlanService.getWorkoutPlan(id);

      if (plan != null) {
        emit(state.copyWith(
          selectedWorkoutPlan: plan,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Workout plan not found',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<bool> startWorkoutPlan(int workoutPlanId) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Check if user already has an active plan
      final bool hasActivePlan =
          await _currentWorkoutPlanRecordService.hasActivePlan();
      if (hasActivePlan) {
        emit(state.copyWith(
          error: 'You already have an active workout plan',
          isLoading: false,
        ));
        return false;
      }

      // Create workout plan record
      await _workoutPlanRecordService.createWorkoutPlanRecord(
        workoutPlanId: workoutPlanId,
        status: ProgressStatus.inProgress,
      );

      // Set as current plan
      await _currentWorkoutPlanRecordService.setCurrentWorkoutPlan(
        workoutPlanId,
      );

      emit(state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
      return false;
    }
  }
}

