// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import '../../../data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import '../../../data/repositories/workout_plans/inputs/workout_plan_day_record_input.dart';
import '../../../data/repositories/workout_plans/inputs/workout_plan_record_input.dart';
import '../../../data/repositories/workout_plans/inputs/workout_plan_workout_record_input.dart';
import '../../../data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import '../../../data/repositories/workout_plans/dtos/workout_plan_workout_record_dto.dart';
import '../../../data/repositories/workout_plans/workout_plan_record_repository.dart';
import '../../../data/repositories/workout_plans/workout_plan_repository.dart';
import '../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../data/repositories/workouts/workout_record_repository.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../../utils/result.dart';
import '../../core/view_models/states/common_state.dart';
import './states/workout_plan_record_state.dart';

class WorkoutPlanRecordCubit extends Cubit<WorkoutPlanRecordState> {
  final WorkoutPlanRecordRepository _workoutPlanRecordService;
  final WorkoutPlanRepository _workoutPlanService;

  WorkoutPlanRecordCubit({
    required WorkoutPlanRecordRepository workoutPlanRecordRepository,
    required WorkoutPlanRepository workoutPlanRepository,
    WorkoutRecordRepository? workoutRecordRepository,
  }) : _workoutPlanRecordService = workoutPlanRecordRepository,
       _workoutPlanService = workoutPlanRepository,
       super(WorkoutPlanRecordState.initial());

  final Logger _logger = Logger('WorkoutPlanRecordCubit');
  int _latestRecordRequestId = 0;

  Future<void> getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? progressStatus,
    (DateTime, DateTime)? dateRange,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting workout plan record history');
    final requestId = state.historyRequestId + 1;
    final filtersChanged =
        state.pagination.workoutPlanId != workoutPlanId ||
        state.pagination.progressStatus != progressStatus ||
        state.pagination.dateRange != dateRange;
    final clearStaleRecords = offset == 0 && filtersChanged;

    emit(
      state.copyWith(
        historyRequestId: requestId,
        planRecords: clearStaleRecords ? const [] : null,
        pagination: clearStaleRecords
            ? state.pagination.copyWith(
                workoutPlanId: Nullable(workoutPlanId),
                progressStatus: Nullable(progressStatus),
                dateRange: Nullable(dateRange),
                limit: limit,
                offset: 0,
                total: 0,
              )
            : null,
        isLoading: true,
        error: const Nullable(null),
      ),
    );

    final result = await _workoutPlanRecordService.getWorkoutPlanRecords(
      workoutPlanId: workoutPlanId,
      status: progressStatus,
      dateRange: dateRange ?? state.pagination.dateRange,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.historyRequestId) {
      return;
    }

    if (result.isErr()) {
      emit(
        state.copyWith(
          isLoading: false,
          error: Nullable(
            ErrorState(
              type: result.error.type.name,
              description: result.error.description,
            ),
          ),
        ),
      );
      return;
    }

    final page = result.value;
    emit(
      state.copyWith(
        planRecords: offset == 0
            ? page.data
            : [...state.planRecords, ...page.data],
        pagination: state.pagination.copyWith(
          workoutPlanId: Nullable(workoutPlanId),
          progressStatus: Nullable(progressStatus),
          dateRange: dateRange != null ? Nullable(dateRange) : null,
          limit: page.limit,
          offset: page.offset,
          total: page.total,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getLatestWorkoutPlanRecord([int? workoutPlanId]) async {
    _logger.info('Getting latest workout plan record for plan $workoutPlanId');
    final requestId = ++_latestRecordRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanRecordService.getLatestWorkoutPlanRecord(
      workoutPlanId,
    );
    if (isClosed || requestId != _latestRecordRequestId) {
      return;
    }
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get latest workout plan record", error);
      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              latestWorkoutPlanRecord: const Nullable(null),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: error.description,
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    emit(
      state.copyWith(
        latestWorkoutPlanRecord: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

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
        emit(
          state.copyWith(
            currentPlanRecord: state.currentPlanRecord.copyWith(
              currentPlanRecord: const Nullable(null),
              workoutPlan: const Nullable(null),
              todaysWorkouts: [],
            ),
            hasLoadedActivePlan: false,
            isLoading: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: "Something went wrong",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final record = result.value;

    // Fetch the plan details
    final planResult = await _workoutPlanService.getWorkoutPlan(
      record.workoutPlanId,
      planVersion: record.workoutPlanVersion,
    );
    if (planResult.isErr()) {
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: planResult.error.type.name,
              description: "Failed to load workout plan details",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final plan = planResult.value;
    final countsFuture = _loadProgressCounts(record, plan);
    final todaysWorkoutsFuture = _resolveTodaysWorkouts(record, plan);
    final counts = await countsFuture;
    final todaysWorkouts = await todaysWorkoutsFuture;

    emit(
      state.copyWith(
        currentPlanRecord: state.currentPlanRecord.copyWith(
          currentPlanRecord: Nullable(record),
          workoutPlan: Nullable(plan),
          completedWorkouts: counts?.$1,
          totalWorkouts: counts?.$2,
          todaysWorkouts:
              todaysWorkouts ??
              (state.currentPlanRecord.currentPlanRecord?.id == record.id
                  ? state.currentPlanRecord.todaysWorkouts
                  : const []),
        ),
        hasLoadedActivePlan: true,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> startPlanWorkout({
    required int workoutRecordId,
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
          error: Nullable(
            ErrorState(
              type: SingleErrorTypes.invalidInput.name,
              description: 'No active workout plan record set',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final useWeek = week ?? currentPlanRecord.currentWeek;
    final useDay = day ?? currentPlanRecord.currentDay;
    final useWorkoutPosition =
        workoutPosition ?? currentPlanRecord.currentWorkoutPosition;

    final workoutResult = await _workoutPlanRecordService
        .upsertWorkoutPlanWorkoutRecord(
          WorkoutPlanWorkoutRecordInput(
            workoutPlanRecordId: currentPlanRecord.id,
            workoutRecordId: workoutRecordId,
            status: ProgressStatus.inProgress,
            week: useWeek,
            weekDay: useDay,
            workoutPosition: useWorkoutPosition,
          ),
        );
    if (workoutResult.isErr()) {
      final error = workoutResult.error;
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: 'Failed to start workout plan record',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final updatedRecord = workoutResult.value;
    final plan = state.currentPlanRecord.workoutPlan;
    (int, int)? counts;
    List<WorkoutDto>? todaysWorkouts;
    if (plan != null) {
      final countsFuture = _loadProgressCounts(updatedRecord, plan);
      final todaysWorkoutsFuture = _resolveTodaysWorkouts(updatedRecord, plan);
      counts = await countsFuture;
      todaysWorkouts = await todaysWorkoutsFuture;
    }

    emit(
      state.copyWith(
        currentPlanRecord: state.currentPlanRecord.copyWith(
          currentPlanRecord: Nullable(updatedRecord),
          currentWeek: updatedRecord.currentWeek,
          currentDay: updatedRecord.currentDay,
          completedWorkouts: counts?.$1,
          totalWorkouts: counts?.$2,
          todaysWorkouts: todaysWorkouts,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return;
  }

  Future<bool> completePlanWorkout({
    required int workoutPlanRecordId,
    required int workoutRecordId,
    required int week,
    required int day,
    required int workoutPosition,
    DateTime? startedAt,
  }) async {
    var planRecord = state.currentPlanRecord.currentPlanRecord;
    if (planRecord == null || planRecord.id != workoutPlanRecordId) {
      final lookup = await _workoutPlanRecordService.getWorkoutPlanRecord(
        workoutPlanRecordId,
      );
      if (lookup.isErr() ||
          (lookup.value.status != ProgressStatus.inProgress &&
              lookup.value.status != ProgressStatus.skipped)) {
        emit(
          state.copyWith(
            error: Nullable(
              ErrorState(
                type: SingleErrorTypes.invalidInput.name,
                description: 'The selected workout plan is no longer active',
              ),
            ),
          ),
        );
        return false;
      }
      planRecord = lookup.value;
    }

    emit(state.copyWith(isLoading: true));
    final result = await _workoutPlanRecordService
        .upsertWorkoutPlanWorkoutRecord(
          WorkoutPlanWorkoutRecordInput(
            workoutPlanRecordId: planRecord.id,
            workoutRecordId: workoutRecordId,
            week: week,
            weekDay: day,
            workoutPosition: workoutPosition,
            status: ProgressStatus.completed,
            startedAt: startedAt,
          ),
        );
    if (result.isErr()) {
      emit(
        state.copyWith(
          isLoading: false,
          error: Nullable(
            ErrorState(
              type: result.error.type.name,
              description: result.error.description,
            ),
          ),
        ),
      );
      return false;
    }

    final updatedRecord = result.value;
    final plan = state.currentPlanRecord.workoutPlan;
    (int, int)? counts;
    List<WorkoutDto>? todaysWorkouts;
    if (plan != null) {
      final countsFuture = _loadProgressCounts(updatedRecord, plan);
      final todaysWorkoutsFuture = _resolveTodaysWorkouts(updatedRecord, plan);
      counts = await countsFuture;
      todaysWorkouts = await todaysWorkoutsFuture;
    }

    emit(
      state.copyWith(
        isLoading: false,
        error: const Nullable(null),
        currentPlanRecord: state.currentPlanRecord.copyWith(
          currentPlanRecord: Nullable(updatedRecord),
          completedWorkouts: counts?.$1,
          totalWorkouts: counts?.$2,
          todaysWorkouts: todaysWorkouts,
        ),
      ),
    );
    return true;
  }

  Future<bool> skipPlanWorkout({
    required int workoutPlanRecordId,
    required int week,
    required int day,
    required int workoutPosition,
    required int workoutId,
    int? existingWorkoutRecordId,
  }) async {
    _logger.info(
      'Skipping plan workout week=$week day=$day position=$workoutPosition',
    );
    emit(state.copyWith(isLoading: true));
    final result = await _workoutPlanRecordService.skipPlanWorkout(
      workoutPlanRecordId: workoutPlanRecordId,
      week: week,
      day: day,
      workoutPosition: workoutPosition,
      workoutId: workoutId,
      existingWorkoutRecordId: existingWorkoutRecordId,
    );
    return _applySkipResult(result);
  }

  Future<bool> skipPlanDay({
    required int workoutPlanRecordId,
    required int week,
    required int day,
    required List<WorkoutPlanWorkoutDto> planWorkouts,
    List<WorkoutPlanWorkoutRecordDto> existingRecords = const [],
  }) async {
    _logger.info('Skipping plan day week=$week day=$day');
    emit(state.copyWith(isLoading: true));
    final result = await _workoutPlanRecordService.skipPlanDay(
      workoutPlanRecordId: workoutPlanRecordId,
      week: week,
      day: day,
      planWorkouts: planWorkouts,
      existingRecords: existingRecords,
    );
    return _applySkipResult(result);
  }

  Future<bool> skipPlanWeek({
    required int workoutPlanRecordId,
    required int week,
    required Map<int, List<WorkoutPlanWorkoutDto>> workoutsByDay,
    Map<int, List<WorkoutPlanWorkoutRecordDto>> existingRecordsByDay = const {},
  }) async {
    _logger.info('Skipping plan week=$week');
    emit(state.copyWith(isLoading: true));
    final result = await _workoutPlanRecordService.skipPlanWeek(
      workoutPlanRecordId: workoutPlanRecordId,
      week: week,
      workoutsByDay: workoutsByDay,
      existingRecordsByDay: existingRecordsByDay,
    );
    return _applySkipResult(result);
  }

  Future<bool> _applySkipResult(
    Result<WorkoutPlanRecordDto?, ServiceError<SingleErrorTypes>> result,
  ) async {
    if (result.isErr()) {
      emit(
        state.copyWith(
          isLoading: false,
          error: Nullable(
            ErrorState(
              type: result.error.type.name,
              description: result.error.description,
            ),
          ),
        ),
      );
      return false;
    }

    final updatedRecord = result.value;
    if (updatedRecord == null) {
      emit(state.copyWith(isLoading: false, error: const Nullable(null)));
      return true;
    }

    final plan = state.currentPlanRecord.workoutPlan;
    (int, int)? counts;
    List<WorkoutDto>? todaysWorkouts;
    if (plan != null) {
      final countsFuture = _loadProgressCounts(updatedRecord, plan);
      final todaysWorkoutsFuture = _resolveTodaysWorkouts(updatedRecord, plan);
      counts = await countsFuture;
      todaysWorkouts = await todaysWorkoutsFuture;
    }

    emit(
      state.copyWith(
        isLoading: false,
        error: const Nullable(null),
        currentPlanRecord: state.currentPlanRecord.copyWith(
          currentPlanRecord: Nullable(updatedRecord),
          completedWorkouts: counts?.$1,
          totalWorkouts: counts?.$2,
          todaysWorkouts: todaysWorkouts,
        ),
      ),
    );
    return true;
  }

  Future<void> handleDeletedWorkoutPlan(int workoutPlanId) async {
    final current = state.currentPlanRecord;
    final matchesActive =
        current.workoutPlan?.id == workoutPlanId ||
        current.currentPlanRecord?.workoutPlanId == workoutPlanId;
    if (!matchesActive) return;

    emit(
      state.copyWith(
        currentPlanRecord: CurrentWorkoutPlanRecordState.initial(),
        hasLoadedActivePlan: false,
        error: const Nullable(null),
      ),
    );
    await getLatestActivePlanRecord();
  }

  Future<void> getLatestActivePlanRecord() async {
    _logger.info('Getting latest active plan record');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanRecordService.getLatestActivePlanRecord();
    if (isClosed) return;
    if (result.isErr()) {
      final error = result.error;
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              hasLoadedActivePlan: true,
              isLoading: false,
              currentPlanRecord: CurrentWorkoutPlanRecordState.initial(),
              error: const Nullable(null),
            ),
          );
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: 'Failed to get latest active plan record',
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final record = result.value;
    final planResult = await _workoutPlanService.getWorkoutPlan(
      record.workoutPlanId,
      planVersion: record.workoutPlanVersion,
    );
    if (planResult.isErr()) {
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: planResult.error.type.name,
              description: 'Failed to load workout plan details',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final plan = planResult.value;
    final countsFuture = _loadProgressCounts(record, plan);
    final todaysWorkoutsFuture = _resolveTodaysWorkouts(record, plan);
    final counts = await countsFuture;
    final todaysWorkouts = await todaysWorkoutsFuture;

    emit(
      state.copyWith(
        currentPlanRecord: state.currentPlanRecord.copyWith(
          currentPlanRecord: Nullable(record),
          workoutPlan: Nullable(plan),
          completedWorkouts: counts?.$1,
          totalWorkouts: counts?.$2,
          todaysWorkouts:
              todaysWorkouts ??
              (state.currentPlanRecord.currentPlanRecord?.id == record.id
                  ? state.currentPlanRecord.todaysWorkouts
                  : const []),
        ),
        hasLoadedActivePlan: true,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getTodaysWorkout() async {
    _logger.info('Getting today\'s workout');
    final record = state.currentPlanRecord.currentPlanRecord;
    final plan = state.currentPlanRecord.workoutPlan;

    if (record == null || plan == null) {
      return;
    }

    final todaysWorkouts = await _resolveTodaysWorkouts(record, plan);
    if (todaysWorkouts != null) {
      emit(
        state.copyWith(
          currentPlanRecord: state.currentPlanRecord.copyWith(
            todaysWorkouts: todaysWorkouts,
          ),
        ),
      );
    }
  }

  Future<void> refreshProgress() async {
    final record = state.currentPlanRecord.currentPlanRecord;
    final plan = state.currentPlanRecord.workoutPlan;
    if (record == null || plan == null) return;

    final counts = await _loadProgressCounts(record, plan);
    if (counts == null) return;

    emit(
      state.copyWith(
        currentPlanRecord: state.currentPlanRecord.copyWith(
          completedWorkouts: counts.$1,
          totalWorkouts: counts.$2,
        ),
      ),
    );
  }

  Future<List<WorkoutDto>?> _resolveTodaysWorkouts(
    WorkoutPlanRecordDto record,
    WorkoutPlanDto plan,
  ) async {
    try {
      if (record.status != ProgressStatus.inProgress) {
        return const [];
      }

      final daysSinceStart = math.max(
        0,
        DateTime.now().difference(record.startedAt).inDays,
      );
      final calendarWeekNum = (daysSinceStart / 7).floor() + 1;

      if (calendarWeekNum > plan.totalWeeks) {
        _logger.info('Plan completed (time-wise)');
        return null;
      }

      final calendarDayIndex = (daysSinceStart % 7) + 1;
      final startWeek = math.max(calendarWeekNum, record.currentWeek);
      final startDay = calendarWeekNum > record.currentWeek
          ? calendarDayIndex
          : (record.currentWeek > calendarWeekNum
                ? record.currentDay
                : math.max(calendarDayIndex, record.currentDay));

      var weeks = plan.weeks;
      if (weeks == null) {
        final weeksResult = await _workoutPlanService.getWorkoutPlanWeeks(
          plan.id,
          planVersion: record.workoutPlanVersion,
        );
        if (weeksResult.isErr()) return null;
        weeks = weeksResult.value;
      }

      final finishedPositions = <(int, int), Set<int>>{};
      for (final weekRecord in record.weeks) {
        for (final dayRecord in weekRecord.days) {
          for (final workoutRecord in dayRecord.workouts) {
            if (workoutRecord.status == ProgressStatus.completed ||
                workoutRecord.status == ProgressStatus.skipped) {
              finishedPositions
                  .putIfAbsent((weekRecord.week, dayRecord.day), () => <int>{})
                  .add(workoutRecord.position);
            }
          }
        }
      }

      final cachedWeekDays = <int, List<WorkoutPlanDayDto>>{};
      for (var weekNum = startWeek; weekNum <= plan.totalWeeks; weekNum++) {
        final week = weeks
            .where((w) => weekNum >= w.startWeek && weekNum <= w.endWeek)
            .firstOrNull;
        if (week == null) {
          continue;
        }

        var days = week.days;
        if (days.isEmpty && plan.weeks == null) {
          if (cachedWeekDays.containsKey(week.id)) {
            days = cachedWeekDays[week.id]!;
          } else {
            final daysResult = await _workoutPlanService.getWorkoutPlanWeek(
              week.id,
              planVersion: record.workoutPlanVersion,
            );
            if (daysResult.isErr()) return null;
            days = daysResult.value.days;
            cachedWeekDays[week.id] = days;
          }
        }

        final firstDay = weekNum == startWeek ? startDay : 1;
        for (var dayNum = firstDay; dayNum <= 7; dayNum++) {
          final dayDto = days.where((d) => d.day == dayNum).firstOrNull;
          if (dayDto == null || dayDto.isRestDay) {
            continue;
          }
          final planWorkouts = dayDto.planWorkouts;
          if (planWorkouts == null) {
            return null;
          }
          final finished = finishedPositions[(weekNum, dayNum)] ?? const {};
          final remaining = planWorkouts
              .where((pw) => !finished.contains(pw.position))
              .map((pw) => pw.workout)
              .whereType<WorkoutDto>()
              .toList();
          if (remaining.isNotEmpty) {
            return remaining;
          }
        }
      }

      return const [];
    } catch (e) {
      _logger.warning("Error calculating today's workout", e);
      return null;
    }
  }

  Future<(int, int)?> _loadProgressCounts(
    WorkoutPlanRecordDto record,
    WorkoutPlanDto plan,
  ) async {
    try {
      final results = await Future.wait([
        _workoutPlanRecordService.getCompletedWorkoutsCount(record.id),
        _workoutPlanRecordService.getTotalWorkoutsCount(
          plan.id,
          workoutPlanVersion: record.workoutPlanVersion,
        ),
      ]);
      final completedResult = results[0];
      final totalResult = results[1];
      if (completedResult.isErr() || totalResult.isErr()) {
        return null;
      }
      return (completedResult.value, totalResult.value);
    } catch (e) {
      _logger.warning("Failed to refresh progress", e);
      return null;
    }
  }

  Future<void> startWorkoutPlan(int workoutPlanId) async {
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanRecordService.createWorkoutPlanRecord(
      WorkoutPlanRecordInput(workoutPlanId: workoutPlanId),
    );
    if (result.isErr()) {
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: result.error.type.name,
              description: result.error.description,
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    // Load the matching template and progress so cached views do not need
    // to reload when revisited.
    await getLatestActivePlanRecord();
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
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: SingleErrorTypes.invalidInput.name,
              description: 'No active workout plan record set',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final result = await _workoutPlanRecordService.upsertWorkoutPlanDayRecord(
      WorkoutPlanDayRecordInput(
        workoutPlanRecordId: workoutPlanRecordId,
        status: status,
        week: week,
        weekDay: weekDay,
      ),
    );
    if (result.isErr()) {
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: result.error.type.name,
              description: result.error.description,
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final updatedPlanRecord = result.value;
    emit(
      state.copyWith(
        currentPlanRecord: state.currentPlanRecord.copyWith(
          currentPlanRecord: Nullable(updatedPlanRecord),
          currentWeek: updatedPlanRecord.currentWeek,
          currentDay: updatedPlanRecord.currentDay,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}
