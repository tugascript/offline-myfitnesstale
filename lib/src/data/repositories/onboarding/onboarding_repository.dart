// Copyright (C) 2026 afonsobarracha
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

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/constants/equipment_constants.dart';
import '../../models/constants/exercise_constants.dart';
import '../../models/constants/workout_constants.dart';
import '../../models/constants/workout_plan_constants.dart';
import '../../models/equipment_model.dart';
import '../../models/exercise_model.dart';
import '../../models/workout_model.dart';
import '../../models/workout_plan_model.dart';
import '../exercises/dtos/equipment_dto.dart';
import '../exercises/dtos/exercise_dto.dart';
import '../exercises/exercise_repository.dart';
import '../exercises/inputs/exercise_input.dart';
import '../../services/sqlite/database_helper.dart';
import '../../utils/enums.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../../utils/result.dart';
import '../profile/dtos/profile_dto.dart';
import '../profile/dtos/reminders_config_dto.dart';
import '../profile/dtos/system_dto.dart';
import '../workouts/dtos/workout_dto.dart';
import '../profile/profile_repository.dart';
import '../workout_plans/workout_plan_repository.dart';
import '../workouts/workout_repository.dart';

enum OnboardingStage {
  equipments,
  exercises,
  profile,
  system,
  reminders,
  workouts,
  workoutPlan,
  completion,
}

typedef OnboardingStageCallback = FutureOr<void> Function(
  OnboardingStage stage,
);

final class OnboardingRequest {
  final Units units;
  final ThemeType theme;
  final String name;
  final int height;
  final Gender gender;
  final DateTime birthday;
  final bool createWorkouts;
  final bool notificationsOn;

  const OnboardingRequest({
    required this.units,
    required this.theme,
    required this.name,
    required this.height,
    required this.gender,
    required this.birthday,
    required this.createWorkouts,
    required this.notificationsOn,
  });
}

final class OnboardingResult {
  final ProfileDto profile;
  final SystemDto system;
  final RemindersConfigDto remindersConfig;

  const OnboardingResult({
    required this.profile,
    required this.system,
    required this.remindersConfig,
  });
}

class OnboardingRepository {
  final DatabaseHelper _databaseHelper;
  final ExerciseRepository _exerciseService;
  final ProfileRepository _profileService;
  final WorkoutRepository _workoutService;
  final WorkoutPlanRepository _workoutPlanService;
  final OnboardingStageCallback? _afterStage;
  final Logger _logger = Logger('OnboardingRepository');

  OnboardingRepository({
    DatabaseHelper? databaseHelper,
    ExerciseRepository? exerciseService,
    ProfileRepository? profileService,
    WorkoutRepository? workoutService,
    WorkoutPlanRepository? workoutPlanService,
    this._afterStage,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper(),
       _exerciseService = exerciseService ?? ExerciseRepository.create(),
       _profileService = profileService ?? ProfileRepository(),
       _workoutService = workoutService ?? WorkoutRepository(),
       _workoutPlanService = workoutPlanService ?? WorkoutPlanRepository();

  Future<Result<OnboardingResult, ServiceError<OperationErrorTypes>>> onboard(
    OnboardingRequest request,
  ) async {
    try {
      final result = await (await _databaseHelper.db).transaction(
        (transaction) => _onboard(transaction, request),
      );
      return ok(result);
    } on _OnboardingFailure catch (error, stackTrace) {
      _logger.warning(
        'Onboarding failed during ${error.stage.name}: ${error.description}',
        error,
        stackTrace,
      );
      return err(
        ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: error.requiresReset
              ? 'Setup could not continue because existing development data is incomplete. Clear app data and try again. This attempt saved no data.'
              : 'Setup failed during ${_stageLabel(error.stage)}. No data was saved. Please try again.',
        ),
      );
    } catch (error, stackTrace) {
      _logger.severe('Onboarding failed unexpectedly', error, stackTrace);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Setup failed. No data was saved. Please try again.',
        ),
      );
    }
  }

  Future<OnboardingResult> _onboard(
    Transaction transaction,
    OnboardingRequest request,
  ) async {
    final existing = await _getCompletedOnboarding(transaction);
    if (existing != null) {
      return existing;
    }

    await _rejectIncompleteState(transaction);

    final equipmentResult = await _exerciseService.createEquipments(
      kEquipmentNames.toList(),
      createdBy: CreatedBy.system,
      transaction: transaction,
    );
    final equipments = _require(equipmentResult, OnboardingStage.equipments);
    await _stageCompleted(OnboardingStage.equipments);

    final equipmentByName = <String, EquipmentDto>{
      for (final equipment in equipments) equipment.name: equipment,
    };
    final exerciseResult = await _exerciseService.createExercises(
      kInitialExercises
          .map(
            (exercise) => ExerciseInput(
              name: exercise.name,
              muscleGroup: exercise.muscleGroup,
              muscles: exercise.muscles,
              equipmentIds: exercise.equipments
                  .map((name) => equipmentByName[name]?.id)
                  .nonNulls
                  .toSet(),
              difficulty: Nullable(exercise.difficulty),
            ),
          )
          .toList(),
      createdBy: CreatedBy.system,
      transaction: transaction,
    );
    final exercises = _require(exerciseResult, OnboardingStage.exercises);
    await _stageCompleted(OnboardingStage.exercises);

    final profileResult = await _profileService.upsertProfile(
      name: request.name,
      height: request.height,
      gender: request.gender,
      birthday: request.birthday,
      transaction: transaction,
    );
    final profile = _require(profileResult, OnboardingStage.profile);
    await _stageCompleted(OnboardingStage.profile);

    final systemResult = await _profileService.upsertSystem(
      theme: request.theme,
      units: request.units,
      profileId: profile.id,
      notificationsOn: request.notificationsOn,
      transaction: transaction,
    );
    _require(systemResult, OnboardingStage.system);
    await _stageCompleted(OnboardingStage.system);

    final remindersResult = await _profileService.upsertRemindersConfig(
      profileId: profile.id,
      workoutsOn: request.notificationsOn,
      weightRecordsOn: request.notificationsOn,
      transaction: transaction,
    );
    final reminders = _require(remindersResult, OnboardingStage.reminders);
    await _stageCompleted(OnboardingStage.reminders);

    if (request.createWorkouts) {
      final workouts = await _createWorkouts(transaction, exercises);
      await _stageCompleted(OnboardingStage.workouts);
      await _createWorkoutPlan(transaction, workouts);
      await _stageCompleted(OnboardingStage.workoutPlan);
    }

    final completionResult = await _profileService.upgradeSystem(
      initialSetup: SetUpStatus.completed,
      transaction: transaction,
    );
    final completedSystem = _require(
      completionResult,
      OnboardingStage.completion,
    );
    await _stageCompleted(OnboardingStage.completion);

    return OnboardingResult(
      profile: profile,
      system: completedSystem,
      remindersConfig: reminders,
    );
  }

  Future<List<WorkoutDto>> _createWorkouts(
    Transaction transaction,
    List<ExerciseDto> exercises,
  ) async {
    final exerciseByName = <String, ExerciseDto>{
      for (final exercise in exercises) exercise.name: exercise,
    };
    final result = await _workoutService.createWorkouts(
      kStandardWorkouts
          .map(
            (workout) => WorkoutRegistrationInput(
              name: workout.name,
              description: workout.description,
              difficulty: workout.difficulty,
              phase: workout.phase,
              sets: workout.sets
                  .map(
                    (set) => WorkoutSetRegistrationInput(
                      setType: set.setType,
                      minSets: set.minSets,
                      maxSets: set.maxSets,
                      recommendedRestSecs: set.recommendedRestSecs,
                      maxRestSecs: set.maxRestSecs,
                      exercises: set.exercises
                          .map(
                            (exercise) => WorkoutSetExerciseRegistrationInput(
                              exercise: exerciseByName[exercise.exerciseName]!,
                              minReps: exercise.minReps,
                              maxReps: exercise.maxReps,
                              difficulty: exercise.difficulty,
                              alternativeExercises: exercise
                                  .exerciseOptionsNames
                                  .map((name) => exerciseByName[name]!)
                                  .toList(),
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
      createdBy: CreatedBy.system,
      transaction: transaction,
    );
    return _require(result, OnboardingStage.workouts);
  }

  Future<void> _createWorkoutPlan(
    Transaction transaction,
    List<WorkoutDto> workouts,
  ) async {
    final workoutByName = <String, WorkoutDto>{
      for (final workout in workouts) workout.name: workout,
    };
    final result = await _workoutPlanService.createWorkoutPlans(
      [
        WorkoutPlanRegistrationInput(
          name: kWorkoutPlanData.name,
          description: kWorkoutPlanData.description,
          difficulty: kWorkoutPlanData.difficulty,
          weeks: kWorkoutPlanData.weeks
              .map(
                (week) => WorkoutPlanWeekRegistrationInput(
                  startWeek: week.startWeek,
                  endWeek: week.endWeek,
                  phase: week.phase,
                  days: week.days
                      .map(
                        (day) => WorkoutPlanDayRegistrationInput(
                          workouts: day.workouts
                              .map(
                                (workout) =>
                                    WorkoutPlanWorkoutRegistrationInput(
                                      workout:
                                          workoutByName[workout.workoutName]!,
                                      timeOfDay: workout.timeOfDay,
                                    ),
                              )
                              .toList(),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      ],
      createdBy: CreatedBy.system,
      transaction: transaction,
    );
    _require(result, OnboardingStage.workoutPlan);
  }

  Future<OnboardingResult?> _getCompletedOnboarding(
    Transaction transaction,
  ) async {
    final systemResult = await _profileService.selectSystem(
      transaction: transaction,
    );
    if (systemResult.isErr()) {
      if (systemResult.error.type == SingleErrorTypes.notFound) {
        return null;
      }
      throw _OnboardingFailure(
        OnboardingStage.system,
        systemResult.error.description,
      );
    }

    if (systemResult.value.initialSetup != SetUpStatus.completed) {
      return null;
    }

    final profileResult = await _profileService.selectProfile(
      transaction: transaction,
    );
    final remindersResult = await _profileService.selectRemindersConfig(
      transaction: transaction,
    );
    if (profileResult.isErr() || remindersResult.isErr()) {
      throw const _OnboardingFailure(
        OnboardingStage.completion,
        'Completed onboarding data is inconsistent',
        requiresReset: true,
      );
    }

    return OnboardingResult(
      profile: profileResult.value,
      system: systemResult.value,
      remindersConfig: remindersResult.value,
    );
  }

  Future<void> _rejectIncompleteState(Transaction transaction) async {
    final profile = await _profileService.selectProfile(
      transaction: transaction,
    );
    final system = await _profileService.selectSystem(transaction: transaction);
    final reminders = await _profileService.selectRemindersConfig(
      transaction: transaction,
    );

    final hasSeedData = await _containsAnyRows(transaction, const [
      Equipment.table,
      Exercise.table,
      Workout.table,
      WorkoutPlan.table,
    ]);

    if (profile.isOk() || system.isOk() || reminders.isOk() || hasSeedData) {
      throw const _OnboardingFailure(
        OnboardingStage.profile,
        'An incomplete development onboarding state already exists. Clear app data and try again.',
        requiresReset: true,
      );
    }
  }

  Future<bool> _containsAnyRows(
    Transaction transaction,
    List<String> tables,
  ) async {
    for (final table in tables) {
      if ((await transaction.query(table, limit: 1)).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  T _require<T, E extends ErrorTypes>(
    Result<T, ServiceError<E>> result,
    OnboardingStage stage,
  ) {
    if (result.isErr()) {
      throw _OnboardingFailure(stage, result.error.description);
    }
    return result.value;
  }

  Future<void> _stageCompleted(OnboardingStage stage) async {
    try {
      await _afterStage?.call(stage);
    } catch (error) {
      throw _OnboardingFailure(stage, error.toString());
    }
  }

  String _stageLabel(OnboardingStage stage) {
    return switch (stage) {
      OnboardingStage.equipments => 'equipment setup',
      OnboardingStage.exercises => 'exercise setup',
      OnboardingStage.profile => 'profile creation',
      OnboardingStage.system => 'settings creation',
      OnboardingStage.reminders => 'reminder setup',
      OnboardingStage.workouts => 'workout setup',
      OnboardingStage.workoutPlan => 'workout-plan setup',
      OnboardingStage.completion => 'setup completion',
    };
  }
}

final class _OnboardingFailure implements Exception {
  final OnboardingStage stage;
  final String description;
  final bool requiresReset;

  const _OnboardingFailure(
    this.stage,
    this.description, {
    this.requiresReset = false,
  });

  @override
  String toString() => 'OnboardingFailure(${stage.name}, $description)';
}
