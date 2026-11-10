// Copyright (C) 2026 afonsobarracha
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

import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/utils/errors.dart';
import 'package:myfitnesstale/src/utils/result.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/onboarding/onboarding_repository.dart';
import 'package:myfitnesstale/src/ui/home/screens/profile/onboarding_screen.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';

void main() {
  testWidgets('shows persistent rollback feedback and retries unchanged form', (
    tester,
  ) async {
    final service = _OnboardingService([_failure, _failure]);
    final cubit = ProfileCubit(
      profileRepository: ProfileRepository.create(),
      onboardingService: service,
    );
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
    expect(service.requests, hasLength(1));

    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(service.requests, hasLength(2));
    expect(service.requests.first.name, 'Widget Tester');
    expect(service.requests.last.name, 'Widget Tester');
  });

  testWidgets('navigates home only after onboarding succeeds', (tester) async {
    final service = _OnboardingService([ok(_success)]);
    final cubit = ProfileCubit(
      profileRepository: ProfileRepository.create(),
      onboardingService: service,
    );
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

typedef OnboardingServiceResult =
    Result<OnboardingResult, ServiceError<OperationErrorTypes>>;

final class _OnboardingService extends OnboardingRepository {
  final List<OnboardingServiceResult> _responses;
  final List<OnboardingRequest> requests = [];

  _OnboardingService(this._responses);

  @override
  Future<OnboardingServiceResult> onboard(OnboardingRequest request) async {
    requests.add(request);
    return _responses.removeAt(0);
  }
}

final _failure = err<OnboardingResult, ServiceError<OperationErrorTypes>>(
  const ServiceError(
    type: OperationErrorTypes.operationFailure,
    description: 'Setup failed. No data was saved. Please try again.',
  ),
);

final _success = OnboardingResult(
  profile: ProfileDto(
    id: 1,
    name: 'Navigation Tester',
    height: 175,
    gender: Gender.other,
    birthdate: DateTime(1990),
  ),
  system: const SystemDto(
    id: 1,
    units: Units.metric,
    theme: ThemeType.system,
    initialSetup: SetUpStatus.completed,
    notificationsOn: false,
  ),
  remindersConfig: const RemindersConfigDto(
    id: 1,
    workoutsOn: false,
    weightRecordsOn: false,
  ),
);
