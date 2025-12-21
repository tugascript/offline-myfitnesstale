import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/workout_set_exercise_record_model.dart';
import '../models/workout_set_record_model.dart';
import '../models/workout_record_model.dart';
import '../services/workout_record_service.dart';
import '../services/workout_set_exercise_record_service.dart';
import '../services/workout_set_record_service.dart';
import '../services/current_workout_plan_record_service.dart';
import '../services/workout_plan_service.dart';
import '../services/workout_plan_record_service.dart';
import '../services/workout_plan_day_record_service.dart';
import '../services/workout_plan_week_record_service.dart';
import '../services/workout_plan_workout_record_service.dart';
import '../services/workout_set_service.dart';
import '../services/workout_set_exercise_service.dart';
import '../services/workout_set_exercise_option_service.dart';
import '../services/exercise_service.dart';
import '../models/exercise_model.dart';
import '../models/workout_set_exercise_model.dart';
import '../models/workout_set_exercise_option_model.dart';
import '../models/workout_set_model.dart';
import 'states/active_workout_state.dart';
import 'states/workout_set_state.dart';

class ActiveWorkoutCubit extends Cubit<ActiveWorkoutState> {
  final WorkoutRecordService _workoutRecordService = WorkoutRecordService();
  final WorkoutSetRecordService _workoutSetRecordService =
      WorkoutSetRecordService();
  final WorkoutSetExerciseRecordService _workoutSetExerciseRecordService =
      WorkoutSetExerciseRecordService();
  final WorkoutSetService _workoutSetService = WorkoutSetService();
  final WorkoutSetExerciseService _workoutSetExerciseService =
      WorkoutSetExerciseService();
  final WorkoutSetExerciseOptionService _workoutSetExerciseOptionService =
      WorkoutSetExerciseOptionService();
  final ExerciseService _exerciseService = ExerciseService();

  Timer? _restTimer;

  ActiveWorkoutCubit() : super(ActiveWorkoutState.initial());

  @override
  Future<void> close() {
    _restTimer?.cancel();
    return super.close();
  }

  Future<void> startWorkout(int workoutId) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load workout sets
      final workoutSets = await _workoutSetService.getWorkoutSets(workoutId);
      if (workoutSets.isEmpty) {
        emit(state.copyWith(
          error: 'Workout has no sets configured',
          isLoading: false,
        ));
        return;
      }

      // Calculate totals
      int totalSets = 0;
      int totalReps = 0;
      int totalRestSecs = 0;

      for (final set in workoutSets) {
        totalSets += set.minSets;
        totalRestSecs += set.recommendedRestSecs * set.minSets;
        // Estimate reps (will be updated as exercises are completed)
        totalReps += set.minSets * 10; // Default estimate
      }

      final int startedAt = DateTime.now().millisecondsSinceEpoch;

      // Create workout record
      final workoutRecord = await _workoutRecordService.createWorkoutRecord(
        workoutId: workoutId,
        totalSets: totalSets,
        totalReps: totalReps,
        totalRestSecs: totalRestSecs,
        startedAt: startedAt,
        weight: 0.0, // Will be updated
        reps: 0, // Will be updated
      );

      // Load full workout sets with exercises
      final List<WorkoutSet> workoutSetsList =
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

      final List<WorkoutSetWithExercises> workoutSetsWithExercises =
          workoutSetsList.map((workoutSet) {
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
      }).toList();

      emit(state.copyWith(
        workoutRecord: workoutRecord,
        workoutSets: workoutSetsWithExercises,
        currentSetIndex: 0,
        currentExerciseIndex: 0,
        startedAt: startedAt,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> logExerciseSet({
    required int workoutSetExerciseId,
    required int exerciseId,
    required int reps,
    required double weightKg,
    int? difficulty,
    String? difficultyType,
  }) async {
    if (state.workoutRecord == null || !state.hasCurrentSet) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final currentSet = state.currentSet!;
      final workoutSetId = currentSet.workoutSet.id!;
      final workoutSetRecord = state.completedSetRecords[workoutSetId]?.last;

      if (workoutSetRecord == null) {
        // Create new set record
        final int startedAt = DateTime.now().millisecondsSinceEpoch;
        final setNumber =
            (state.completedSetRecords[workoutSetId]?.length ?? 0) + 1;
        final totalRestSecs = currentSet.workoutSet.recommendedRestSecs;

        final newSetRecord =
            await _workoutSetRecordService.createWorkoutSetRecord(
          workoutSetId: workoutSetId,
          workoutProgressId: state.workoutRecord!.id!,
          setNumber: setNumber,
          totalRestSecs: totalRestSecs,
          startedAt: startedAt,
        );

        // Update state with new set record
        final updatedSetRecords = Map<int, List<WorkoutSetRecord>>.from(
          state.completedSetRecords,
        );
        updatedSetRecords[workoutSetId] = [
          ...(updatedSetRecords[workoutSetId] ?? []),
          newSetRecord,
        ];

        // Create exercise record
        final exerciseRecord = await _workoutSetExerciseRecordService
            .createWorkoutSetExerciseRecord(
          workoutSetExerciseId: workoutSetExerciseId,
          workoutSetProgressId: newSetRecord.id!,
          exerciseId: exerciseId,
          reps: reps,
          weightGrams: (weightKg * 1000).round(),
          difficulty: difficulty,
          difficultyType: difficultyType,
        );

        final updatedExerciseRecords =
            Map<int, List<WorkoutSetExerciseRecord>>.from(
          state.completedExerciseRecords,
        );
        updatedExerciseRecords[newSetRecord.id!] = [
          ...(updatedExerciseRecords[newSetRecord.id!] ?? []),
          exerciseRecord,
        ];

        emit(state.copyWith(
          completedSetRecords: updatedSetRecords,
          completedExerciseRecords: updatedExerciseRecords,
          isLoading: false,
        ));
      } else {
        // Add exercise record to existing set
        final exerciseRecord = await _workoutSetExerciseRecordService
            .createWorkoutSetExerciseRecord(
          workoutSetExerciseId: workoutSetExerciseId,
          workoutSetProgressId: workoutSetRecord.id!,
          exerciseId: exerciseId,
          reps: reps,
          weightGrams: (weightKg * 1000).round(),
          difficulty: difficulty,
          difficultyType: difficultyType,
        );

        final updatedExerciseRecords =
            Map<int, List<WorkoutSetExerciseRecord>>.from(
          state.completedExerciseRecords,
        );
        updatedExerciseRecords[workoutSetRecord.id!] = [
          ...(updatedExerciseRecords[workoutSetRecord.id!] ?? []),
          exerciseRecord,
        ];

        emit(state.copyWith(
          completedExerciseRecords: updatedExerciseRecords,
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

  Future<void> completeSet(int workoutSetId) async {
    if (state.workoutRecord == null) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final setRecords = state.completedSetRecords[workoutSetId];
      if (setRecords != null && setRecords.isNotEmpty) {
        final lastRecord = setRecords.last;
        if (lastRecord.completedAt == null) {
          await _workoutSetRecordService.completeWorkoutSetRecord(
            lastRecord.id!,
          );

          // Update state
          final updatedSetRecords = Map<int, List<WorkoutSetRecord>>.from(
            state.completedSetRecords,
          );
          final index = updatedSetRecords[workoutSetId]!.length - 1;
          updatedSetRecords[workoutSetId]![index] = lastRecord.copyWith(
            completedAt: DateTime.now().millisecondsSinceEpoch,
          );

          emit(state.copyWith(
            completedSetRecords: updatedSetRecords,
            isLoading: false,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  void nextExercise() {
    if (!state.hasCurrentSet) return;

    final currentSet = state.currentSet!;
    if (state.currentExerciseIndex < currentSet.exercises.length - 1) {
      emit(state.copyWith(
        currentExerciseIndex: state.currentExerciseIndex + 1,
      ));
    } else {
      // Move to next set
      if (state.currentSetIndex < state.workoutSets.length - 1) {
        emit(state.copyWith(
          currentSetIndex: state.currentSetIndex + 1,
          currentExerciseIndex: 0,
        ));
      }
    }
  }

  void previousExercise() {
    if (state.currentExerciseIndex > 0) {
      emit(state.copyWith(
        currentExerciseIndex: state.currentExerciseIndex - 1,
      ));
    } else if (state.currentSetIndex > 0) {
      final previousSet = state.workoutSets[state.currentSetIndex - 1];
      emit(state.copyWith(
        currentSetIndex: state.currentSetIndex - 1,
        currentExerciseIndex: previousSet.exercises.length - 1,
      ));
    }
  }

  void startRest(int seconds) {
    _restTimer?.cancel();
    emit(state.copyWith(
      isResting: true,
      restTimerSeconds: seconds,
    ));

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentSeconds = state.restTimerSeconds ?? 0;
      if (currentSeconds <= 1) {
        timer.cancel();
        emit(state.copyWith(
          isResting: false,
          restTimerSeconds: null,
        ));
      } else {
        emit(state.copyWith(restTimerSeconds: currentSeconds - 1));
      }
    });
  }

  void stopRest() {
    _restTimer?.cancel();
    emit(state.copyWith(
      isResting: false,
      restTimerSeconds: null,
    ));
  }

  Future<void> completeWorkout() async {
    if (state.workoutRecord == null) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      await _workoutRecordService.completeWorkoutRecord(
        state.workoutRecord!.id!,
      );

      final updatedRecord = await _workoutRecordService.getWorkoutRecord(
        state.workoutRecord!.id!,
      );

      // Integrate with workout plan tracking if active plan exists
      await _trackWorkoutPlanCompletion(updatedRecord);

      emit(state.copyWith(
        workoutRecord: updatedRecord,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _trackWorkoutPlanCompletion(WorkoutRecord? workoutRecord) async {
    if (workoutRecord == null || workoutRecord.id == null) {
      return;
    }

    try {
      final currentPlanService = CurrentWorkoutPlanRecordService();
      final currentPlan =
          await currentPlanService.getCurrentWorkoutPlanRecord();
      if (currentPlan == null) {
        return; // No active plan
      }

      final workoutPlanService = WorkoutPlanService();
      final planWorkoutService = WorkoutPlanWorkoutRecordService();
      final planRecordService = WorkoutPlanRecordService();

      // Get active plan record
      final planRecord = await planRecordService.getActivePlanRecord(
        currentPlan.workoutPlanId,
      );
      if (planRecord == null || planRecord.id == null) {
        return;
      }

      // Find the workout plan workout that matches this workout
      final allPlanWorkouts = await workoutPlanService.getWorkoutPlanWorkouts(
        workoutPlanId: currentPlan.workoutPlanId,
      );
      final planWorkouts = allPlanWorkouts
          .where((pw) => pw.workoutId == workoutRecord.workoutId)
          .toList();

      if (planWorkouts.isEmpty) {
        return; // Workout not part of plan
      }

      // Get today's day record
      final dayRecordService = WorkoutPlanDayRecordService();
      final todayDayRecord =
          await dayRecordService.getTodaysWorkoutPlanDayRecord(
        planRecord.id!,
      );

      if (todayDayRecord == null || todayDayRecord.id == null) {
        return; // No day record for today
      }

      // Get week record
      final weekRecordService = WorkoutPlanWeekRecordService();
      final weekRecords = await weekRecordService.getWorkoutPlanWeekRecords(
        workoutPlanRecordId: planRecord.id!,
      );
      if (weekRecords.isEmpty) {
        return;
      }
      final weekRecord = weekRecords.first;

      // Create workout plan workout record for each matching plan workout
      for (final planWorkout in planWorkouts) {
        // Check if record already exists
        final existing =
            await planWorkoutService.getWorkoutRecordForPlanWorkout(
          planRecord.id!,
          planWorkout.id!,
        );

        if (existing == null) {
          await planWorkoutService.createWorkoutPlanWorkoutRecord(
            workoutPlanRecordId: planRecord.id!,
            workoutPlanWeekRecordId: weekRecord.id!,
            workoutPlanDayRecordId: todayDayRecord.id!,
            workoutPlanWorkoutId: planWorkout.id!,
            workoutRecordId: workoutRecord.id!,
          );
        }
      }
    } catch (e) {
      // Silently fail - don't interrupt workout completion
      print('Error tracking workout plan completion: $e');
    }
  }

  Future<void> cancelWorkout() async {
    _restTimer?.cancel();
    emit(ActiveWorkoutState.initial());
  }
}
