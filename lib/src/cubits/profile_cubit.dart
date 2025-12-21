import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/enums.dart';
import '../models/profile_model.dart';
import '../models/system_model.dart';
import '../services/data_init_service.dart';
import '../services/profile_service.dart';
import '../services/system_service.dart';
import 'states/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService = ProfileService();
  final SystemService _systemService = SystemService();
  final DataInitService _dataInitService = DataInitService();
  final Logger _logger = Logger("ProfileCubit");

  ProfileCubit() : super(ProfileState.initial());

  Future<void> loadInitialData() async {
    _logger.info("Loading initial data");
    // Prevent multiple simultaneous calls
    if (state.isLoading) {
      _logger.info("Already loading, skipping");
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      _logger.info("Loading initial data");
      final Profile? profile = await _profileService.selectLatest();
      final System? system =
          profile != null ? await _systemService.selectLatest() : null;
      emit(state.copyWith(
        profile: profile,
        system: system,
        isInitiated: true,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      _logger.severe("Error loading initial data", e);
      emit(state.copyWith(
        error: e.toString(),
        isInitiated: true,
        isLoading: false,
      ));
    }
  }

  Future<void> onboardProfile({
    required Units units,
    required ThemeType theme,
    required String name,
    required int height,
    required Gender gender,
    required bool preLoadWorkouts,
  }) async {
    _logger.info("Onboarding profile");
    if (state.isLoading ||
        !state.isInitiated ||
        state.profile != null ||
        state.system != null) {
      _logger.info("Loading, or profile is already onboarded");
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      _logger.info("Onboarding profile");
      final Profile profile = await _profileService.upsertProfile(
        name: name,
        height: height,
        gender: gender,
      );
      final System system = await _systemService.upsertSystem(
        profileId: profile.id!,
        theme: theme,
        units: units,
      );
      await _dataInitService.loadDefaultData(withWorkouts: preLoadWorkouts);
      emit(state.copyWith(
        profile: profile,
        system: system,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      _logger.severe("Error onboarding profile", e);
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> loadSystem() async {
    try {
      final System? system = await _systemService.selectLatest();
      emit(state.copyWith(system: system, error: null));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
      ));
    }
  }

  Future<void> createProfile({
    required String name,
    required int height,
    required Gender gender,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Profile profile = await _profileService.upsertProfile(
        name: name,
        height: height,
        gender: gender,
      );
      emit(state.copyWith(
        profile: profile,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateProfile({
    String? name,
    int? height,
    Gender? gender,
  }) async {
    if (state.profile == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      final Profile profile = await _profileService.updateProfile(
        name: name,
        height: height,
        gender: gender,
      );
      emit(state.copyWith(
        profile: profile,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> createSystem({
    required Units units,
    required ThemeType theme,
  }) async {
    if (state.profile == null || state.profile?.id == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      final System system = await _systemService.upsertSystem(
        profileId: state.profile!.id!,
        units: units,
        theme: theme,
      );
      emit(state.copyWith(
        isLoading: false,
        system: system,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateSystem({
    Units? units,
    ThemeType? theme,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      System? system = state.system;

      // If no system exists, create one with default values
      if (system == null && state.profile != null) {
        system = await _systemService.upsertSystem(
          profileId: state.profile!.id!,
          units: units ?? Units.metric,
          theme: theme ?? ThemeType.system,
        );
      } else if (system != null) {
        // Update existing system
        system = await _systemService.upgradeSystem(
          units: units,
          theme: theme,
        );
      } else {
        throw Exception('Cannot update system: no profile found');
      }

      emit(state.copyWith(
        isLoading: false,
        system: system,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}
