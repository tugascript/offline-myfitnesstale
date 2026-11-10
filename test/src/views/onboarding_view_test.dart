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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/home/screens/profile/onboarding_screen.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';

void main() {
  testWidgets('shows persistent rollback feedback and retries unchanged form', (
    tester,
  ) async {
    final cubit = _OnboardingProfileCubit(succeedOnAttempt: 100);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<ProfileCubit>.value(
        value: cubit,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Widget Tester',
    );

    final submit = find.text('Create & get started');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('onboarding-error')), findsOneWidget);
    expect(find.textContaining('No data was saved'), findsOneWidget);
    expect(find.text('Widget Tester'), findsOneWidget);
    expect(cubit.attempts, 1);

    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(cubit.attempts, 2);
    expect(find.text('Widget Tester'), findsOneWidget);
  });

  testWidgets('navigates home only after onboarding succeeds', (tester) async {
    final cubit = _OnboardingProfileCubit(succeedOnAttempt: 1);
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: Routes.onboarding.name,
      routes: [
        GoRoute(
          path: Routes.onboarding.name,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Text('Home destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<ProfileCubit>.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Navigation Tester',
    );
    final submit = find.text('Create & get started');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Home destination'), findsOneWidget);
  });
}

final class _OnboardingProfileCubit extends ProfileCubit {
  final int succeedOnAttempt;
  int attempts = 0;

  _OnboardingProfileCubit({required this.succeedOnAttempt})
    : super(profileRepository: ProfileRepository.create());

  @override
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
    if (state.isLoading || state.profile != null) {
      return;
    }

    attempts++;
    emit(state.copyWith(isLoading: true, clearError: true));

    if (attempts < succeedOnAttempt) {
      emit(
        state.copyWith(
          error: const ErrorState(
            type: 'operationFailure',
            description: 'Setup failed. No data was saved. Please try again.',
          ),
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        profile: ProfileDto(
          id: 1,
          name: name,
          height: height,
          gender: gender,
          birthdate: birthday,
        ),
        system: SystemDto(
          id: 1,
          units: units,
          theme: theme,
          initialSetup: SetUpStatus.completed,
          notificationsOn: notificationsOn,
        ),
        remindersConfig: RemindersConfigDto(
          id: 1,
          workoutsOn: notificationsOn,
          weightRecordsOn: notificationsOn,
        ),
        isLoading: false,
        isInitiated: true,
        clearError: true,
      ),
    );
  }
}
