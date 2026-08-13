import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/dtos/system_dto.dart';
import '../services/onboarding_service.dart';
import '../services/profile_service.dart';
import 'states/common_state.dart';
import 'states/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService = ProfileService();
  final OnboardingService _onboardingService;

  final Logger _logger = Logger("Profile Cubit");

  ProfileCubit({OnboardingService? onboardingService})
      : _onboardingService = onboardingService ?? OnboardingService(),
        super(ProfileState.initial());

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

    _logger.info("Selecting reminders config");
    final remindersConfigResult = await _profileService.selectRemindersConfig();
    if (remindersConfigResult.isErr()) {
      final error = remindersConfigResult.error;
      _logger.warning("Failed to load reminders config", error);
      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.notFound.name,
              description: 'Reminders config not found',
            ),
            isInitiated: true,
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: SingleErrorTypes.operationFailure.name,
              description: 'Failed to load reminders config',
            ),
            isLoading: false,
            isInitiated: false,
          ));
          return;
      }
    }

    if (systemResult.value.initialSetup != SetUpStatus.completed) {
      _logger.warning('Existing onboarding data is incomplete');
      emit(state.copyWith(
        error: ErrorState(
          type: SingleErrorTypes.operationFailure.name,
          description:
              'Existing development setup is incomplete. Clear app data and try again.',
        ),
        isInitiated: true,
        isLoading: false,
      ));
      return;
    }

    _logger.info("Loading initial data completed");
    emit(state.copyWith(
      profile: profileResult.value,
      system: systemResult.value,
      remindersConfig: remindersConfigResult.value,
      isInitiated: true,
      isLoading: false,
      clearError: true,
    ));
  }

  Future<void> getRemindersConfig() async {
    _logger.info("Getting reminders config");
    emit(state.copyWith(isRemindersLoading: true));

    final result = await _profileService.selectRemindersConfig();
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get reminders config", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            remindersConfig: null,
            isRemindersLoading: false,
          ));
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            remindersError: ErrorState(
              type: error.type.name,
              description: "Failed to get reminders config",
            ),
            isRemindersLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      remindersConfig: result.value,
      isRemindersLoading: false,
      remindersError: null,
    ));
  }

  Future<void> upsertRemindersConfig({
    required int profileId,
    required bool workoutsOn,
    required bool weightRecordsOn,
  }) async {
    _logger.info("Upserting reminders config for profile $profileId");
    emit(state.copyWith(isRemindersLoading: true));

    final result = await _profileService.upsertRemindersConfig(
      profileId: profileId,
      workoutsOn: workoutsOn,
      weightRecordsOn: weightRecordsOn,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to upsert reminders config", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            remindersError: ErrorState(
              type: error.type.name,
              description: "Failed to upsert reminders config",
            ),
            isRemindersLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      remindersConfig: result.value,
      isRemindersLoading: false,
      remindersError: null,
    ));
  }

  Future<void> updateRemindersConfig({
    bool? workoutsOn,
    bool? weightRecordsOn,
  }) async {
    _logger.info("Updating reminders config");
    emit(state.copyWith(isRemindersLoading: true));

    final result = await _profileService.updateRemindersConfig(
      workoutsOn: workoutsOn,
      weightRecordsOn: weightRecordsOn,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update reminders config", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            remindersError: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isRemindersLoading: false,
          ));
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            remindersError: ErrorState(
              type: error.type.name,
              description: "Failed to update reminders config",
            ),
            isRemindersLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      remindersConfig: result.value,
      isRemindersLoading: false,
      remindersError: null,
    ));
  }

  void changeSystem(
      {required ThemeType theme,
      required Units units,
      required bool notificationsOn}) {
    emit(state.copyWith(
      system: state.system?.copyWith(
            theme: theme,
            units: units,
            notificationsOn: notificationsOn,
          ) ??
          SystemDto(
            id: 0,
            initialSetup: SetUpStatus.notStarted,
            theme: theme,
            units: units,
            notificationsOn: notificationsOn,
          ),
    ));
  }

  Future<void> onboardProfile({
    required Units units,
    required ThemeType theme,
    required String name,
    required int height,
    required Gender gender,
    required DateTime birthday,
    required bool createWorkouts,
    required bool notificationsOn,
  }) async {
    _logger.info("Onboarding profile");
    if (state.isLoading || state.profile != null) {
      _logger.info("Loading, or profile is already onboarded");
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _onboardingService.onboard(
      OnboardingRequest(
        units: units,
        theme: theme,
        name: name,
        height: height,
        gender: gender,
        birthday: birthday,
        createWorkouts: createWorkouts,
        notificationsOn: notificationsOn,
      ),
    );

    if (result.isErr()) {
      _logger.severe("Failed to onboard profile", result.error);
      emit(state.copyWith(
        error: ErrorState(
          type: result.error.type.name,
          description: result.error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    final onboarding = result.value;
    _logger.info("Onboarding profile completed");
    emit(state.copyWith(
      profile: onboarding.profile,
      system: onboarding.system,
      remindersConfig: onboarding.remindersConfig,
      isLoading: false,
      isInitiated: true,
      clearError: true,
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
    required bool notificationsOn,
  }) async {
    _logger.info("Creating system");
    if (state.isLoading) {
      _logger.info("Already loading, skipping");
      return;
    }
    if (state.profile == null) {
      _logger.info("Profile not found, skipping");
      return;
    }

    emit(state.copyWith(isLoading: true));
    final systemResult = await _profileService.upsertSystem(
      profileId: state.profile!.id,
      theme: theme,
      units: units,
      notificationsOn: notificationsOn,
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
