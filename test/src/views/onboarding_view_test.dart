import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/common/errors.dart';
import 'package:myfitnesstale/src/services/common/result.dart';
import 'package:myfitnesstale/src/services/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/services/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/services/dtos/system_dto.dart';
import 'package:myfitnesstale/src/services/onboarding_service.dart';
import 'package:myfitnesstale/src/views/onboarding_view.dart';

void main() {
  testWidgets('shows persistent rollback feedback and retries unchanged form',
      (tester) async {
    final service = _OnboardingService([
      _failure,
      _failure,
    ]);
    final cubit = ProfileCubit(onboardingService: service);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<ProfileCubit>.value(
        value: cubit,
        child: const MaterialApp(home: OnboardingView()),
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
    final cubit = ProfileCubit(onboardingService: service);
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: OnboardingView.routeName,
      routes: [
        GoRoute(
          path: OnboardingView.routeName,
          builder: (context, state) => const OnboardingView(),
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

typedef OnboardingServiceResult
    = Result<OnboardingResult, ServiceError<OperationErrorTypes>>;

final class _OnboardingService extends OnboardingService {
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
