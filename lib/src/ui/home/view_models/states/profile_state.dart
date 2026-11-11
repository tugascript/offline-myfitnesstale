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

import 'package:equatable/equatable.dart';

import '../../../../data/repositories/profile/dtos/profile_dto.dart';
import '../../../../data/repositories/profile/dtos/reminders_config_dto.dart';
import '../../../../data/repositories/profile/dtos/system_dto.dart';
import '../../../../utils/nullable.dart';
import '../../../core/view_models/states/common_state.dart';

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
    Nullable<ProfileDto?>? profile,
    Nullable<SystemDto?>? system,
    Nullable<RemindersConfigDto?>? remindersConfig,
    bool? isLoading,
    bool? isInitiated,
    Nullable<ErrorState?>? error,
  }) {
    return ProfileState(
      profile: profile != null ? profile.value : this.profile,
      system: system != null ? system.value : this.system,
      remindersConfig: remindersConfig != null
          ? remindersConfig.value
          : this.remindersConfig,
      isLoading: isLoading ?? this.isLoading,
      isInitiated: isInitiated ?? this.isInitiated,
      error: error != null ? error.value : this.error,
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
