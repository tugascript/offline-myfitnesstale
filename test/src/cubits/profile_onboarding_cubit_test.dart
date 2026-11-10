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

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/data/models/sqlite/system_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/onboarding/onboarding_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/services/sqlite/dao.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/utils/errors.dart';
import 'package:myfitnesstale/src/utils/result.dart';

void main() {
  test(
    'coordinates loading, failure feedback, stale-error clearing, and retry',
    () async {
      final first = Completer<OnboardingServiceResult>();
      final retry = Completer<OnboardingServiceResult>();
      final service = _OnboardingService([first.future, retry.future]);
      final cubit = ProfileCubit(
        profileRepository: ProfileRepository.create(),
        onboardingService: service,
      );
      addTearDown(cubit.close);

      final firstCall = cubit.onboardProfile(
        units: Units.metric,
        theme: ThemeType.system,
        name: 'Retry Tester',
        height: 175,
        gender: Gender.other,
        birthday: DateTime(1990),
        createWorkouts: false,
        notificationsOn: false,
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.error, isNull);

      first.complete(_failure());
      await firstCall;
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.profile, isNull);
      expect(cubit.state.error?.description, contains('No data was saved'));

      final retryCall = cubit.onboardProfile(
        units: Units.metric,
        theme: ThemeType.system,
        name: 'Retry Tester',
        height: 175,
        gender: Gender.other,
        birthday: DateTime(1990),
        createWorkouts: false,
        notificationsOn: false,
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.error, isNull);

      retry.complete(ok(_success));
      await retryCall;
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isInitiated, isTrue);
      expect(cubit.state.profile, _profile);
      expect(cubit.state.system?.initialSetup, SetUpStatus.completed);
      expect(cubit.state.remindersConfig, _reminders);
      expect(cubit.state.error, isNull);
    },
  );

  for (final createWorkouts in [false, true]) {
    test(
      'passes createWorkouts=$createWorkouts to the onboarding service',
      () async {
        final service = _OnboardingService([Future.value(ok(_success))]);
        final cubit = ProfileCubit(
          profileRepository: ProfileRepository.create(),
          onboardingService: service,
        );
        addTearDown(cubit.close);

        await cubit.onboardProfile(
          units: Units.imperial,
          theme: ThemeType.dark,
          name: 'Choice Tester',
          height: 180,
          gender: Gender.male,
          birthday: DateTime(1985),
          createWorkouts: createWorkouts,
          notificationsOn: true,
        );

        expect(service.requests, hasLength(1));
        expect(service.requests.single.createWorkouts, createWorkouts);
        expect(service.requests.single.notificationsOn, isTrue);
      },
    );
  }
}

typedef OnboardingServiceResult =
    Result<OnboardingDto, ServiceError<OperationErrorTypes>>;

final class _OnboardingService extends OnboardingRepository {
  final List<Future<OnboardingServiceResult>> _responses;
  final List<OnboardingInput> requests = [];

  _OnboardingService(this._responses)
    : super(
        exerciseService: ExerciseRepository.create(),
        profileService: ProfileRepository.create(),
        workoutService: WorkoutRepository.create(),
        workoutPlanService: WorkoutPlanRepository.create(),
        systemDao: Dao<System>(
          databaseHelper: DatabaseHelper(),
          tableName: System.table,
          fromMap: System.fromMap,
        ),
      );

  @override
  Future<OnboardingServiceResult> onboard(OnboardingInput input) {
    requests.add(input);
    return _responses.removeAt(0);
  }
}

OnboardingServiceResult _failure() => err(
  const ServiceError(
    type: OperationErrorTypes.operationFailure,
    description: 'Setup failed. No data was saved. Please try again.',
  ),
);

final _profile = ProfileDto(
  id: 1,
  name: 'Retry Tester',
  height: 175,
  gender: Gender.other,
  birthdate: DateTime(1990),
);

const _system = SystemDto(
  id: 1,
  units: Units.metric,
  theme: ThemeType.system,
  initialSetup: SetUpStatus.completed,
  notificationsOn: false,
);

const _reminders = RemindersConfigDto(
  id: 1,
  workoutsOn: false,
  weightRecordsOn: false,
);

final _success = OnboardingDto(
  profile: _profile,
  system: _system,
  remindersConfig: _reminders,
);
