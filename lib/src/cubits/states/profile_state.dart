import 'package:equatable/equatable.dart';

import '../../models/profile_model.dart';
import '../../models/system_model.dart';

final class ProfileState extends Equatable {
  final Profile? profile;
  final System? system;
  final bool isLoading;
  final bool isInitiated;
  final String? error;

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
    Profile? profile,
    System? system,
    bool? isLoading,
    bool? isInitiated,
    String? error,
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
