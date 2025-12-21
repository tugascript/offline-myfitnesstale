import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/profile_model.dart';
import '../services/current_workout_plan_record_service.dart';
import '../services/workout_plan_day_record_service.dart';
import '../services/workout_plan_record_service.dart';
import '../services/workout_plan_service.dart';
import 'states/current_workout_plan_record_state.dart';

class CurrentWorkoutPlanRecordCubit
    extends Cubit<CurrentWorkoutPlanRecordState> {
  final CurrentWorkoutPlanRecordService _currentWorkoutPlanRecordService =
      CurrentWorkoutPlanRecordService();
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  final WorkoutPlanRecordService _workoutPlanRecordService =
      WorkoutPlanRecordService();
  final WorkoutPlanDayRecordService _workoutPlanDayRecordService =
      WorkoutPlanDayRecordService();
  final Logger _logger = Logger("WorkoutPlanRecordCubit");

  CurrentWorkoutPlanRecordCubit()
      : super(CurrentWorkoutPlanRecordState.initial());

  Future<void> getActivePlanRecord([Profile? profile]) async {
    _logger.info(
      "Getting active plan record",
      {"method": "getActivePlanRecord"},
    );
    // Prevent multiple simultaneous calls
    if (state.isLoading) {
      _logger.info("Already loading, skipping");
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      // Pass profile to avoid fetching it again (which calls selectLatest)
      final currentPlanRecord =
          await _currentWorkoutPlanRecordService.getCurrentWorkoutPlanRecord(
        profile,
      );

      if (currentPlanRecord == null) {
        emit(state.copyWith(
          currentPlanRecord: null,
          workoutPlan: null,
          isLoading: false,
        ));
        return;
      }

      final workoutPlan = await _workoutPlanService.getWorkoutPlan(
        currentPlanRecord.workoutPlanId,
      );

      if (workoutPlan == null) {
        emit(state.copyWith(
          error: 'Workout plan not found',
          isLoading: false,
        ));
        return;
      }

      // Get the active plan record
      final planRecord = await _workoutPlanRecordService.getActivePlanRecord(
        currentPlanRecord.workoutPlanId,
      );

      // Get progress
      double progressPercentage = 0.0;
      int completedWorkouts = 0;
      int totalWorkouts = 0;

      if (planRecord != null) {
        progressPercentage =
            await _workoutPlanRecordService.getPlanProgressPercentage(
          planRecord.id!,
          workoutPlan.id!,
        );
        completedWorkouts =
            await _workoutPlanRecordService.getCompletedWorkoutsCount(
          planRecord.id!,
        );
        totalWorkouts = await _workoutPlanRecordService.getTotalWorkoutsCount(
          workoutPlan.id!,
        );
      }

      emit(state.copyWith(
        currentPlanRecord: currentPlanRecord,
        workoutPlan: workoutPlan,
        workoutPlanRecord: planRecord,
        progressPercentage: progressPercentage,
        completedWorkouts: completedWorkouts,
        totalWorkouts: totalWorkouts,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> getTodaysWorkout() async {
    if (state.workoutPlanRecord == null ||
        state.workoutPlanRecord!.id == null) {
      return;
    }

    try {
      final todaysWorkouts =
          await _workoutPlanDayRecordService.getTodaysWorkouts(
        state.workoutPlanRecord!.id!,
      );

      emit(state.copyWith(todaysWorkouts: todaysWorkouts));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> refreshProgress() async {
    if (state.workoutPlanRecord == null ||
        state.workoutPlan == null ||
        state.workoutPlanRecord!.id == null ||
        state.workoutPlan!.id == null) {
      return;
    }

    try {
      final progressPercentage =
          await _workoutPlanRecordService.getPlanProgressPercentage(
        state.workoutPlanRecord!.id!,
        state.workoutPlan!.id!,
      );
      final completedWorkouts =
          await _workoutPlanRecordService.getCompletedWorkoutsCount(
        state.workoutPlanRecord!.id!,
      );
      final totalWorkouts =
          await _workoutPlanRecordService.getTotalWorkoutsCount(
        state.workoutPlan!.id!,
      );

      emit(state.copyWith(
        progressPercentage: progressPercentage,
        completedWorkouts: completedWorkouts,
        totalWorkouts: totalWorkouts,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
