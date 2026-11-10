import 'package:equatable/equatable.dart';

import '../../core/dtos/dto.dart';
import '../../profile/dtos/profile_dto.dart';
import '../../profile/dtos/reminders_config_dto.dart';
import '../../profile/dtos/system_dto.dart';

final class OnboardingDto extends Equatable implements Dto {
  final ProfileDto profile;
  final SystemDto system;
  final RemindersConfigDto remindersConfig;

  const OnboardingDto({
    required this.profile,
    required this.system,
    required this.remindersConfig,
  });

  @override
  OnboardingDto copyWith({
    ProfileDto? profile,
    SystemDto? system,
    RemindersConfigDto? remindersConfig,
  }) {
    return OnboardingDto(
      profile: profile ?? this.profile,
      system: system ?? this.system,
      remindersConfig: remindersConfig ?? this.remindersConfig,
    );
  }

  @override
  List<Object?> get props => [profile, system, remindersConfig];
}
