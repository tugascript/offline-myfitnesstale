import 'package:equatable/equatable.dart';

import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'common_state.dart';

final class ProfileState extends Equatable {
  final ProfileDto? profile;
  final SystemDto? system;
  final RemindersConfigDto? remindersConfig;
  final bool isLoading;
  final bool isInitiated;
  final ErrorState? error;

  const ProfileState({
    this.profile,
    this.system,
    this.remindersConfig,
    required this.isLoading,
    required this.isInitiated,
    this.error,
  });

  factory ProfileState.initial() {
    return const ProfileState(isLoading: false, isInitiated: false);
  }

  ProfileState copyWith({
    ProfileDto? profile,
    SystemDto? system,
    RemindersConfigDto? remindersConfig,
    bool? isLoading,
    bool? isRemindersLoading,
    bool? isInitiated,
    ErrorState? error,
    bool clearError = false,
    ErrorState? remindersError,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      system: system ?? this.system,
      remindersConfig: remindersConfig ?? this.remindersConfig,
      isLoading: isLoading ?? this.isLoading,
      isInitiated: isInitiated ?? this.isInitiated,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    profile,
    system,
    remindersConfig,
    isInitiated,
  ];
}
