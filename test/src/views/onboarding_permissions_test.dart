import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myfitnesstale/src/data/repositories/onboarding/onboarding_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/layout/sharp_switch_title.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/onboarding_form.dart';
import 'package:myfitnesstale/src/utils/errors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late ProfileCubit cubit;
  late Future<int> Function() requestStatus;
  late int requests;

  setUp(() {
    requests = 0;
    requestStatus = () async => 1;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'requestPermissions');
      expect(call.arguments, [17]); // Notification permission only.
      requests++;
      return <int, int>{17: await requestStatus()};
    });
    cubit = ProfileCubit(profileRepository: ProfileRepository.create());
  });

  tearDown(() async {
    await cubit.close();
    messenger.setMockMethodCallHandler(channel, null);
  });

  for (final status in [0, 1, 2, 4]) {
    test(
      'repository maps notification status $status to a typed result',
      () async {
        requestStatus = () async => status;
        final result = await OnboardingRepository.create()
            .requestNotificationPermission();
        expect(result.isOk(), isTrue);
        expect(result.value, status == 1);
        expect(requests, 1);
      },
    );
  }

  test(
    'repository catches platform failure and Cubit permits a clean retry',
    () async {
      requestStatus = () async => throw PlatformException(code: 'unavailable');
      final result = await OnboardingRepository.create()
          .requestNotificationPermission();
      expect(result.isErr(), isTrue);
      expect(result.error.type, OperationErrorTypes.operationFailure);

      expect(await cubit.requestNotificationPermission(), isFalse);
      expect(cubit.state.error?.description, contains('Please try again'));
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.profile, isNull);

      requestStatus = () async => 1;
      expect(await cubit.requestNotificationPermission(), isTrue);
      expect(cubit.state.error, isNull);
      expect(cubit.state.system, isNull);
    },
  );

  Widget subject() => BlocProvider.value(
    value: cubit,
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: OnboardingForm(
            sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.md),
            initialUnits: Units.metric,
            initialThemeMode: ThemeType.system,
            initialName: 'Tester',
            initialHeight: 175,
            initialGender: Gender.other,
            initialBirthday: DateTime(1990),
            initialPreLoadWorkouts: false,
            initialNotificationsOn: false,
            onSubmit: ({
              required units,
              required theme,
              required name,
              required height,
              required gender,
              required birthday,
              required preLoadWorkouts,
              required notificationsOn,
            }) {},
            submitButtonLabel: 'Submit',
            isLoading: false,
          ),
        ),
      ),
    ),
  );

  final notificationSwitch = find.widgetWithText(
    SharpSwitchTitle,
    'Allow Notifications',
  );

  testWidgets(
    'granted permission enables the switch; disabling does not request again',
    (tester) async {
      await tester.pumpWidget(subject());
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();
      expect(tester.widget<SharpSwitchTitle>(notificationSwitch).value, isTrue);
      expect(requests, 1);

      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();
      expect(
        tester.widget<SharpSwitchTitle>(notificationSwitch).value,
        isFalse,
      );
      expect(requests, 1);
    },
  );

  testWidgets(
    'denial keeps the switch off and explains how to enable permission',
    (tester) async {
      requestStatus = () async => 0;
      await tester.pumpWidget(subject());
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();
      expect(
        tester.widget<SharpSwitchTitle>(notificationSwitch).value,
        isFalse,
      );
      expect(
        find.text(
          'Permission denied. Please enable notifications in settings.',
        ),
        findsOneWidget,
      );
      expect(cubit.state.error, isNull);
    },
  );

  testWidgets(
    'pending request disables repeat taps and is safe after form disposal',
    (tester) async {
      final gate = Completer<int>();
      requestStatus = () => gate.future;
      await tester.pumpWidget(subject());
      await tester.tap(notificationSwitch);
      await tester.pump();
      expect(
        tester.widget<SharpSwitchTitle>(notificationSwitch).enabled,
        isFalse,
      );
      expect(requests, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      gate.complete(1);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
