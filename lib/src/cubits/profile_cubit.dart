import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/constants/equipment_constants.dart';
import '../models/constants/exercise_constants.dart';
import '../models/constants/workout_constants.dart';
import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/dtos/equipment_dto.dart';
import '../services/dtos/exercise_dto.dart';
import '../services/exercise_service.dart';
import '../services/profile_service.dart';
import '../services/workout_service.dart';
import 'states/common_state.dart';
import 'states/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService = ProfileService();
  final ExerciseService _exerciseService = ExerciseService();
  final WorkoutService _workoutService = WorkoutService();

  final Logger _logger = Logger("Profile Cubit");

  ProfileCubit() : super(ProfileState.initial());

  Future<void> loadInitialData() async {
    _logger.info("Loading initial data");
    // Prevent multiple simultaneous calls
    if (state.isLoading) {
      _logger.info("Already loading, skipping");
      return;
    }

    emit(state.copyWith(isLoading: true));

    _logger.info("Loading initial data");
    _logger.info("Selecting profile");
    final profileResult = await _profileService.selectProfile();
    if (profileResult.isErr()) {
      final error = profileResult.error;
      _logger.warning("Failed to load profile", error);
      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            isInitiated: true,
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.operationFailure.name,
              description: 'Failed to load profile',
            ),
            isLoading: false,
            isInitiated: false,
          ));
          return;
      }
    }

    _logger.info("Selecting system");
    final systemResult = await _profileService.selectSystem();
    if (systemResult.isErr()) {
      final error = systemResult.error;
      _logger.warning("Failed to load system", error);
      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.notFound.name,
              description: 'System not found',
            ),
            isInitiated: true,
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.operationFailure.name,
              description: 'Failed to load system',
            ),
            isLoading: false,
            isInitiated: false,
          ));
          return;
      }
    }

    _logger.info("Loading initial data completed");
    emit(state.copyWith(
      profile: profileResult.value,
      system: systemResult.value,
      isInitiated: true,
      isLoading: false,
      error: null,
    ));
  }

  Future<void> onboardProfile({
    required Units units,
    required ThemeType theme,
    required String name,
    required int height,
    required Gender gender,
    required DateTime birthday,
  }) async {
    _logger.info("Onboarding profile");
    if (state.isLoading || state.profile != null || state.system != null) {
      _logger.info("Loading, or profile is already onboarded");
      return;
    }

    emit(state.copyWith(isLoading: true));
    _logger.info("Onboarding profile");
    _logger.info("Creating profile");
    final profileResult = await _profileService.upsertProfile(
      name: name,
      height: height,
      gender: gender,
      birthday: birthday,
    );

    if (profileResult.isErr()) {
      _logger.severe("Failed to create profile", profileResult.error);
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description: 'Failed to create profile',
        ),
        isLoading: false,
      ));
      return;
    }

    _logger.info("Profile created successfully");
    _logger.info("Creating system");
    final systemResult = await _profileService.upsertSystem(
      theme: theme,
      units: units,
    );

    if (systemResult.isErr()) {
      _logger.severe("Failed to create system", systemResult.error);
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description: 'Failed to create system',
        ),
        isLoading: false,
      ));
      return;
    }

    final equipmentCount = await _exerciseService.countEquipments();
    if (equipmentCount.isErr()) {
      _logger.severe("Failed to count equipments", equipmentCount.error);
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description: 'Failed to count equipments',
        ),
        isLoading: false,
      ));
    }
    if (equipmentCount.value >= kEquipmentNames.length) {
      _logger.info("Equipments already created");
      emit(state.copyWith(
        profile: profileResult.value,
        system: systemResult.value,
        isLoading: false,
        isInitiated: true,
        error: null,
      ));
      return;
    }

    _logger.info("Creating equipments");
    final equipmentResult = await _exerciseService.createEquipments(
      kEquipmentNames,
      createdBy: CreatedBy.system,
    );
    if (equipmentResult.isErr()) {
      _logger.severe("Failed to create equipments", equipmentResult.error);
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description: 'Failed to create equipments',
        ),
        isLoading: false,
      ));
    }

    _logger.info("Equipments created successfully");
    final Map<String, EquipmentDto> equipmentsMap = equipmentResult.value.fold(
      <String, EquipmentDto>{},
      (map, equipment) {
        map[equipment.name] = equipment;
        return map;
      },
    );

    _logger.info("Creating exercises");
    final exerciseResult = await _exerciseService.createExercises(
      kInitialExercises
          .map(
            (e) => ExerciseInput(
              name: e.name,
              muscleGroup: e.muscleGroup,
              muscles: e.muscles,
              equipments: e.equipments
                  .map(
                    (e) => equipmentsMap[e],
                  )
                  .nonNulls
                  .toList(),
            ),
          )
          .toList(),
      createdBy: CreatedBy.system,
    );
    if (exerciseResult.isErr()) {
      _logger.severe("Failed to create exercises", exerciseResult.error);
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description: 'Failed to create exercises',
        ),
        isLoading: false,
      ));
    }

    _logger.info("Exercises created successfully");
    final Map<String, ExerciseDto> exerciseNameToDto =
        exerciseResult.value.fold(
      <String, ExerciseDto>{},
      (map, exercise) {
        map[exercise.name] = exercise;
        return map;
      },
    );

    _logger.info("Creating workouts");
    final workoutResult = await _workoutService.createWorkouts(
      kStandardWorkouts
          .map(
            (e) => WorkoutRegistrationInput(
              name: e.name,
              description: e.description,
              difficulty: e.difficulty,
              phase: e.phase,
              sets: e.sets
                  .map(
                    (s) => WorkoutSetRegistrationInput(
                      setType: s.setType,
                      minSets: s.minSets,
                      maxSets: s.maxSets,
                      recommendedRestSecs: s.recommendedRestSecs,
                      maxRestSecs: s.maxRestSecs,
                      exercises: s.exercises
                          .map(
                            (ex) => WorkoutSetExerciseRegistrationInput(
                              exercise: exerciseNameToDto[ex.exerciseName]!,
                              minReps: ex.minReps,
                              maxReps: ex.maxReps,
                              difficulty: ex.difficulty,
                              alternativeExercises: ex.exerciseOptionsNames
                                  .map((eon) => exerciseNameToDto[eon]!)
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
    );
    if (workoutResult.isErr()) {
      _logger.severe("Failed to create workouts", workoutResult.error);
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description: 'Failed to create workouts',
        ),
        isLoading: false,
      ));
    }

    _logger.info("Workouts created successfully");
    emit(state.copyWith(
      profile: profileResult.value,
      system: systemResult.value,
      isLoading: false,
      isInitiated: true,
      error: null,
    ));
  }

  Future<void> loadSystem() async {
    _logger.info("Loading system");
    if (state.isLoading || state.system != null) {
      _logger.info("Already loading, or system is already loaded");
      return;
    }

    emit(state.copyWith(isLoading: true));
    final systemResult = await _profileService.selectSystem();
    if (systemResult.isErr()) {
      final error = systemResult.error;
      _logger.warning("Failed to load system", error);
      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          _logger.info("System not found");
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.notFound.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          _logger.severe("Failed to load system", systemResult.error);
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.operationFailure.name,
              description: 'Failed to load system',
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("System loaded successfully");
    emit(state.copyWith(
      system: systemResult.value,
      isLoading: false,
      error: null,
    ));
  }

  Future<void> updateProfile({
    String? name,
    int? height,
    Gender? gender,
  }) async {
    _logger.info("Updating profile...");
    if (state.profile == null) {
      _logger.info("No profile loaded, skipping");
      return;
    }

    emit(state.copyWith(isLoading: true));
    final result = await _profileService.updateProfile(
      name: name,
      height: height,
      gender: gender,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update profile", error);
      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          _logger.info("Profile not found");
          emit(state.copyWith(isLoading: false, error: null));
          return;
        case SingleErrorTypes.operationFailure:
          _logger.severe("Failed to update profile", result.error);
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.operationFailure.name,
              description: 'Failed to update profile',
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("Profile updated successfully");
    emit(state.copyWith(
      profile: result.value,
      isLoading: false,
      error: null,
    ));
  }

  Future<void> updateSystem({
    Units? units,
    ThemeType? theme,
  }) async {
    _logger.info("Updating system...");
    if (state.system == null) {
      _logger.info("No system loaded, skipping");
      return;
    }

    emit(state.copyWith(isLoading: true));
    final result = await _profileService.upgradeSystem(
      units: units,
      theme: theme,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update system", error);
      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          _logger.info("System not found");
          emit(state.copyWith(isLoading: false, error: null));
          return;
        case SingleErrorTypes.operationFailure:
          _logger.severe("Failed to update system", result.error);
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.operationFailure.name,
              description: 'Failed to update system',
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("System updated successfully");
    emit(state.copyWith(
      system: result.value,
      isLoading: false,
      error: null,
    ));
  }

  Future<void> createProfile({
    required String name,
    required int height,
    required Gender gender,
  }) async {
    _logger.info("Creating profile");
    // Use a default birthday (25 years ago) if not provided
    final defaultBirthday =
        DateTime.now().subtract(const Duration(days: 365 * 25));
    await upsertProfile(
      name: name,
      height: height,
      gender: gender,
      birthday: defaultBirthday,
    );
  }

  Future<void> upsertProfile({
    required String name,
    required int height,
    required Gender gender,
    required DateTime birthday,
  }) async {
    _logger.info("Upserting profile...");
    if (state.isLoading) {
      _logger.info("Already loading, skipping");
      return;
    }

    emit(state.copyWith(isLoading: true));
    final profileResult = await _profileService.upsertProfile(
      name: name,
      height: height,
      gender: gender,
      birthday: birthday,
    );

    if (profileResult.isErr()) {
      _logger.severe("Failed to upsert profile", profileResult.error);
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description: 'Failed to create profile',
        ),
        isLoading: false,
      ));
      return;
    }

    _logger.info("Profile upserted successfully");
    emit(state.copyWith(
      profile: profileResult.value,
      isLoading: false,
      error: null,
    ));
  }

  Future<void> createSystem({
    required Units units,
    required ThemeType theme,
  }) async {
    _logger.info("Creating system");
    if (state.isLoading) {
      _logger.info("Already loading, skipping");
      return;
    }

    emit(state.copyWith(isLoading: true));
    final systemResult = await _profileService.upsertSystem(
      theme: theme,
      units: units,
    );

    if (systemResult.isErr()) {
      _logger.severe("Failed to create system", systemResult.error);
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description: 'Failed to create system',
        ),
        isLoading: false,
      ));
      return;
    }

    _logger.info("System created successfully");
    emit(state.copyWith(
      system: systemResult.value,
      isLoading: false,
      error: null,
    ));
  }
}
