import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/common/errors.dart';
import '../services/workout_plan_service.dart';
import '../services/workout_plan_record_service.dart';
import 'states/common_state.dart';
import 'states/workout_plan_record_state.dart';

class WorkoutPlanRecordCubit extends Cubit<WorkoutPlanRecordState> {
  final WorkoutPlanRecordService _workoutPlanRecordService =
      WorkoutPlanRecordService();
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();

  WorkoutPlanRecordCubit() : super(WorkoutPlanRecordState.initial());

  final Logger _logger = Logger('WorkoutPlanRecordCubit');

  Future<void> getActivePlanRecord() async {
    _logger.info('Getting active plan record');
    emit(state.copyWith(isLoading: true));

    final result =
        await _workoutPlanRecordService.getCurrentWorkoutPlanRecord();
    if (result.isErr()) {
      final error = result.error;
      _logger.info("No active plan or failed to get it", error);
      // Not strictly an error state if no plan exists, just empty
      if (error.type == SingleErrorTypes.notFound) {
        emit(state.copyWith(
          currentPlanRecord: state.currentPlanRecord.copyWith(
            currentPlanRecord: null,
            workoutPlan: null,
            todaysWorkouts: [],
          ),
          isLoading: false,
        ));
        return;
      }

      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    final record = result.value;

    // Fetch the plan details
    final planResult =
        await _workoutPlanService.getWorkoutPlan(record.workoutPlanId);
    if (planResult.isErr()) {
      emit(state.copyWith(
        error: ErrorState(
          type: planResult.error.type.name,
          description: "Failed to load workout plan details",
        ),
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      currentPlanRecord: state.currentPlanRecord.copyWith(
        currentPlanRecord: record,
        workoutPlan: planResult.value,
      ),
      isLoading: false,
    ));

    // Refresh progress and today's workouts after loading plan
    await refreshProgress();
    await getTodaysWorkout();
  }

  Future<void> getTodaysWorkout() async {
    _logger.info('Getting today\'s workout');
    final record = state.currentPlanRecord.currentPlanRecord;
    final plan = state.currentPlanRecord.workoutPlan;

    if (record == null || plan == null) {
      return;
    }

    try {
      final now = DateTime.now();
      final createdAt = record.createdAt;
      final difference = now.difference(createdAt);

      // Calculate current week (1-based)
      final daysSinceStart = difference.inDays;
      final currentWeekNum = (daysSinceStart / 7).floor() + 1;

      if (currentWeekNum > plan.totalWeeks) {
        _logger.info('Plan completed (time-wise)');
        // Optionally handle finished plan logic
        return;
      }

      // Get weekday (1=Mon, 7=Sun)
      final weekday = now.weekday;

      // Find the corresponding week in the plan
      final weeksResult =
          await _workoutPlanService.getWorkoutPlanWeeks(plan.id);
      if (weeksResult.isErr()) return;

      final weeks = weeksResult.value;

      int? weekId;
      for (final w in weeks) {
        if (currentWeekNum >= w.startWeek && currentWeekNum <= w.endWeek) {
          weekId = w.id;
          break;
        }
      }

      if (weekId == null) {
        emit(state.copyWith(
          currentPlanRecord:
              state.currentPlanRecord.copyWith(todaysWorkouts: []),
        ));
        return;
      }

      // Fetch days for this week
      final daysResult = await _workoutPlanService.getWorkoutPlanWeek(weekId);
      if (daysResult.isErr()) return;

      final weekDto = daysResult.value;
      final todaysDay =
          weekDto.days?.where((d) => d.day == weekday).firstOrNull;

      if (todaysDay == null) {
        emit(state.copyWith(
          currentPlanRecord:
              state.currentPlanRecord.copyWith(todaysWorkouts: []),
        ));
        return;
      }

      if (todaysDay.planWorkouts != null) {
        final workouts = todaysDay.planWorkouts!
            .map((pw) => pw.workout)
            .where((w) => w != null)
            .map((w) => w!)
            .toList();

        emit(state.copyWith(
          currentPlanRecord:
              state.currentPlanRecord.copyWith(todaysWorkouts: workouts),
        ));
      }
    } catch (e) {
      _logger.warning("Error calculating today's workout", e);
    }
  }

  Future<void> refreshProgress() async {
    final record = state.currentPlanRecord.currentPlanRecord;
    final plan = state.currentPlanRecord.workoutPlan;
    if (record == null || plan == null) return;

    try {
      final completed =
          await _workoutPlanRecordService.getCompletedWorkoutsCount(record.id);
      final total =
          await _workoutPlanRecordService.getTotalWorkoutsCount(plan.id);

      emit(state.copyWith(
        currentPlanRecord: state.currentPlanRecord.copyWith(
          completedWorkouts: completed,
          totalWorkouts: total,
        ),
      ));
    } catch (e) {
      _logger.warning("Failed to refresh progress", e);
    }
  }
}
