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
import 'package:myfitnesstale/src/data/models/sqlite/workout_model.dart';
import 'package:myfitnesstale/src/data/repositories/onboarding/onboarding_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();

  setUpAll(testDatabase.initialize);
  tearDown(testDatabase.clearOnboardingTables);
  tearDownAll(testDatabase.destroy);

  test(
    'coordinates loading, failure feedback, stale-error clearing, and retry',
    () async {
      final gate = Completer<void>();
      var attempts = 0;
      final service = OnboardingRepository.create(
        afterStage: (stage) async {
          if (stage != OnboardingStage.equipments) {
            return;
          }
          attempts++;
          if (attempts == 1) {
            await gate.future;
            throw StateError('Injected failure');
          }
        },
      );
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

      gate.complete();
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

      await retryCall;
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isInitiated, isTrue);
      expect(cubit.state.profile?.name, 'Retry Tester');
      expect(cubit.state.system?.initialSetup, SetUpStatus.completed);
      expect(cubit.state.remindersConfig, isNotNull);
      expect(cubit.state.error, isNull);
    },
  );

  for (final createWorkouts in [false, true]) {
    test(
      'passes createWorkouts=$createWorkouts to the onboarding service',
      () async {
        final cubit = ProfileCubit(
          profileRepository: ProfileRepository.create(),
          onboardingService: OnboardingRepository.create(),
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

        expect(cubit.state.profile?.name, 'Choice Tester');
        expect(cubit.state.system?.notificationsOn, isTrue);
        expect(cubit.state.remindersConfig?.workoutsOn, isTrue);

        final workoutCount =
            Sqflite.firstIntValue(
              await (await testDatabase.db).rawQuery(
                'SELECT COUNT(*) FROM ${Workout.table}',
              ),
            ) ??
            0;
        expect(workoutCount, createWorkouts ? 16 : 0);
      },
    );
  }
}
