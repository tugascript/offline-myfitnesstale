import 'package:equatable/equatable.dart';

import '../../services/dtos/profile_dto.dart';
import '../../services/dtos/system_dto.dart';
import 'common_state.dart';

final class ProfileState extends Equatable {
  final ProfileDto? profile;
  final SystemDto? system;
  final bool isLoading;
  final bool isInitiated;
  final ErrorState? error;

  const ProfileState({
    this.profile,
    this.system,
    required this.isLoading,
    required this.isInitiated,
    this.error,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
      isInitiated: false,
    );
  }

  ProfileState copyWith({
    ProfileDto? profile,
    SystemDto? system,
    bool? isLoading,
    bool? isInitiated,
    ErrorState? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      system: system ?? this.system,
      isLoading: isLoading ?? this.isLoading,
      isInitiated: isInitiated ?? this.isInitiated,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        profile,
        system,
      ];
}
