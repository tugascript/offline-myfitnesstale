import 'package:equatable/equatable.dart';

import '../../../utils/enums.dart';

final class OnboardingInput extends Equatable {
  final Units units;
  final ThemeType theme;
  final String name;
  final int height;
  final Gender gender;
  final DateTime birthday;
  final bool createWorkouts;
  final bool notificationsOn;

  const OnboardingInput({
    required this.units,
    required this.theme,
    required this.name,
    required this.height,
    required this.gender,
    required this.birthday,
    required this.createWorkouts,
    required this.notificationsOn,
  });

  @override
  List<Object?> get props => [
    units,
    theme,
    name,
    height,
    gender,
    birthday,
    createWorkouts,
    notificationsOn,
  ];
}
