import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/common/errors.dart';
import 'package:myfitnesstale/src/services/common/result.dart';
import 'package:myfitnesstale/src/services/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/services/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/services/dtos/system_dto.dart';
import 'package:myfitnesstale/src/services/onboarding_service.dart';

void main() {
  test('coordinates loading, failure feedback, stale-error clearing, and retry',
      () async {
    final first = Completer<OnboardingServiceResult>();
    final retry = Completer<OnboardingServiceResult>();
    final service = _OnboardingService([first.future, retry.future]);
    final cubit = ProfileCubit(onboardingService: service);
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
  });

  for (final createWorkouts in [false, true]) {
    test('passes createWorkouts=$createWorkouts to the onboarding service',
        () async {
      final service = _OnboardingService([Future.value(ok(_success))]);
      final cubit = ProfileCubit(onboardingService: service);
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
    });
  }
}

typedef OnboardingServiceResult
    = Result<OnboardingResult, ServiceError<OperationErrorTypes>>;

final class _OnboardingService extends OnboardingService {
  final List<Future<OnboardingServiceResult>> _responses;
  final List<OnboardingRequest> requests = [];

  _OnboardingService(this._responses);

  @override
  Future<OnboardingServiceResult> onboard(OnboardingRequest request) {
    requests.add(request);
    return _responses.removeAt(0);
  }
}

OnboardingServiceResult _failure() => err(const ServiceError(
      type: OperationErrorTypes.operationFailure,
      description: 'Setup failed. No data was saved. Please try again.',
    ));

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

final _success = OnboardingResult(
  profile: _profile,
  system: _system,
  remindersConfig: _reminders,
);
