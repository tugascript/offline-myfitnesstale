import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/workout_plan_record_service.dart';
import '../services/workout_plan_service.dart';
import 'states/common_state.dart';
import 'states/workout_plan_record_state.dart';

class WorkoutPlanRecordCubit extends Cubit<WorkoutPlanRecordState> {
  final WorkoutPlanRecordService _workoutPlanRecordService =
      WorkoutPlanRecordService();
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();

  WorkoutPlanRecordCubit() : super(WorkoutPlanRecordState.initial());

  final Logger _logger = Logger('WorkoutPlanRecordCubit');

  Future<void> getOrCreateActivePlanRecord(int workoutPlanId) async {
    _logger.info('Getting active plan record');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanRecordService
        .getOrCreateCurrentWorkoutPlanRecord(workoutPlanId);
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
          description: "Something went wrong",
        ),
        isLoading: false,
      ));
      return;
    }

    final record = result.value;

    // Fetch the plan details
    final planResult = await _workoutPlanService.getWorkoutPlan(
      record.workoutPlanId,
      planVersion: record.workoutPlanVersion,
    );
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

  Future<void> startPlanWorkout({
    int? week,
    int? day,
    int? workoutPosition,
  }) async {
    _logger.info('Starting plan workout');
    emit(state.copyWith(isLoading: true));

    final currentPlanRecord = state.currentPlanRecord.currentPlanRecord;
    if (currentPlanRecord == null) {
      emit(
        state.copyWith(
          error: ErrorState(
              type: SingleErrorTypes.invalidInput.name,
              description: 'No active workout plan record set'),
          isLoading: false,
        ),
      );
      return;
    }

    final useWeek = week ?? currentPlanRecord.currentWeek;
    final useDay = day ?? currentPlanRecord.currentDay;
    final useWorkoutPosition =
        workoutPosition ?? currentPlanRecord.currentWorkoutPosition;

    final dayResult =
        await _workoutPlanRecordService.upsertWorkoutPlanDayRecord(
      workoutPlanRecordId: currentPlanRecord.id,
      status: ProgressStatus.inProgress,
      week: useWeek,
      weekDay: useDay,
    );
    if (dayResult.isErr()) {
      final error = dayResult.error;
      switch (error.type) {
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: 'Failed to start workout plan record',
            ),
            isLoading: false,
          ));
          break;
        default:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: 'Unknown error occurred',
            ),
            isLoading: false,
          ));
      }
      return;
    }

    final workoutResult =
        await _workoutPlanRecordService.upsertWorkoutPlanWorkoutRecord(
      workoutPlanRecordId: currentPlanRecord.id,
      status: ProgressStatus.inProgress,
      week: useWeek,
      weekDay: useDay,
      workoutPosition: useWorkoutPosition,
    );
    if (workoutResult.isErr()) {
      final error = workoutResult.error;
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: 'Failed to start workout plan record',
        ),
        isLoading: false,
      ));
      return;
    }

    final updatedRecord = workoutResult.value;
    emit(state.copyWith(
      currentPlanRecord: state.currentPlanRecord.copyWith(
        currentPlanRecord: updatedRecord,
      ),
      isLoading: false,
    ));
    return;
  }

  Future<void> getLatestActivePlanRecord() async {
    _logger.info('Getting latest active plan record');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanRecordService.getLatestActivePlanRecord();
    if (result.isErr()) {
      final error = result.error;
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              isLoading: false,
              currentPlanRecord: CurrentWorkoutPlanRecordState.initial(),
            ),
          );
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: 'Failed to get latest active plan record',
            ),
          ));
          return;
      }
    }

    final record = result.value;
    final planResult = await _workoutPlanService.getWorkoutPlan(
      record.workoutPlanId,
      planVersion: record.workoutPlanVersion,
    );
    if (planResult.isErr()) {
      emit(state.copyWith(
        error: ErrorState(
          type: planResult.error.type.name,
          description: 'Failed to load workout plan details',
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
      final startedAt = record.startedAt;
      final difference = now.difference(startedAt);

      // Calculate current week (1-based)
      final daysSinceStart = difference.inDays;
      final currentWeekNum = (daysSinceStart / 7).floor() + 1;

      if (currentWeekNum > plan.totalWeeks) {
        _logger.info('Plan completed (time-wise)');
        // Optionally handle finished plan logic
        return;
      }

      // Get weekday (1=Mon, 7=Sun)
      final relativeDayIndex = (daysSinceStart % 7) + 1;

      // Find the corresponding week in the plan
      final weeksResult = await _workoutPlanService.getWorkoutPlanWeeks(
        plan.id,
        planVersion: record.workoutPlanVersion,
      );
      if (weeksResult.isErr()) return;

      final weeks = weeksResult.value;
      final week = weeks
          .where(
            (w) => currentWeekNum >= w.startWeek && currentWeekNum <= w.endWeek,
          )
          .firstOrNull;
      if (week == null) {
        emit(state.copyWith(
          currentPlanRecord:
              state.currentPlanRecord.copyWith(todaysWorkouts: []),
        ));
        return;
      }

      var todaysDay =
          week.days.where((d) => d.day == relativeDayIndex).firstOrNull;
      if (todaysDay == null) {
        final daysResult = await _workoutPlanService.getWorkoutPlanWeek(
          week.id,
          planVersion: record.workoutPlanVersion,
        );
        if (daysResult.isErr()) return;
        todaysDay = daysResult.value.days
            .where((d) => d.day == relativeDayIndex)
            .firstOrNull;
      }

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
      final total = await _workoutPlanRecordService.getTotalWorkoutsCount(
        plan.id,
        workoutPlanVersion: record.workoutPlanVersion,
      );

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

  Future<void> startWorkoutPlan(int workoutPlanId) async {
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanRecordService.createWorkoutPlanRecord(
      workoutPlanId: workoutPlanId,
    );
    if (result.isErr()) {
      emit(state.copyWith(
        error: ErrorState(
          type: result.error.type.name,
          description: result.error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      currentPlanRecord: state.currentPlanRecord.copyWith(
        currentPlanRecord: result.value,
      ),
      isLoading: false,
    ));
  }

  Future<void> addOrGetWorkoutPlanDayRecord({
    required ProgressStatus status,
    int? week,
    int? weekDay,
  }) async {
    _logger.info('Adding or getting workout plan day record');
    emit(state.copyWith(isLoading: true));

    final workoutPlanRecordId = state.currentPlanRecord.currentPlanRecord?.id;
    if (workoutPlanRecordId == null) {
      _logger.info('No active workout plan record set');
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.invalidInput.name,
          description: 'No active workout plan record set',
        ),
        isLoading: false,
      ));
      return;
    }

    final result = await _workoutPlanRecordService.upsertWorkoutPlanDayRecord(
      workoutPlanRecordId: workoutPlanRecordId,
      status: status,
      week: week,
      weekDay: weekDay,
    );
    if (result.isErr()) {
      emit(state.copyWith(
        error: ErrorState(
          type: result.error.type.name,
          description: result.error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    final updatedPlanRecord = result.value;
    emit(state.copyWith(
      currentPlanRecord: state.currentPlanRecord.copyWith(
        currentPlanRecord: updatedPlanRecord,
        currentWeek: updatedPlanRecord.currentWeek,
        currentDay: updatedPlanRecord.currentDay,
      ),
      isLoading: false,
    ));
  }
}
