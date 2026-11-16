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

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/time_of_day_value.dart';
import 'package:myfitnesstale/src/data/utils/weekday_time_of_day_value.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/reminders_settings_config.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/settings_config.dart';
import 'package:myfitnesstale/src/ui/core/widgets/layout/sharp_switch.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _ProfileCubit extends ProfileCubit {
  _ProfileCubit({
    bool workoutsOn = false,
    TimeOfDayValue? workoutsReminderTime,
    bool weightRecordsOn = false,
    WeekdayTimeOfDayValue? weightRecordsReminderTime,
    bool macroTrackingOn = false,
    TimeOfDayValue? macroTrackingReminderTime,
  }) : super(profileRepository: ProfileRepository.create()) {
    emit(
      ProfileState(
        profile: ProfileDto(
          id: 1,
          name: 'Tester',
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
        remindersConfig: RemindersConfigDto(
          id: 1,
          workoutsOn: workoutsOn,
          workoutsReminderTime:
              workoutsReminderTime ?? const TimeOfDayValue(hour: 8, minute: 0),
          weightRecordsOn: weightRecordsOn,
          weightRecordsReminderTime:
              weightRecordsReminderTime ??
              WeekdayTimeOfDayValue.defaultReminder,
          macroTrackingOn: macroTrackingOn,
          macroTrackingReminderTime:
              macroTrackingReminderTime ??
              const TimeOfDayValue(hour: 8, minute: 0),
        ),
        isLoading: false,
        isInitiated: true,
      ),
    );
  }

  bool? updatedWorkoutsOn;
  TimeOfDayValue? updatedWorkoutsReminderTime;
  bool? updatedWeightRecordsOn;
  WeekdayTimeOfDayValue? updatedWeightRecordsReminderTime;
  bool? updatedMacroTrackingOn;
  TimeOfDayValue? updatedMacroTrackingReminderTime;

  @override
  Future<void> updateRemindersConfig({
    bool? workoutsOn,
    TimeOfDayValue? workoutsReminderTime,
    bool? weightRecordsOn,
    WeekdayTimeOfDayValue? weightRecordsReminderTime,
    bool? macroTrackingOn,
    TimeOfDayValue? macroTrackingReminderTime,
  }) async {
    updatedWorkoutsOn = workoutsOn;
    updatedWorkoutsReminderTime = workoutsReminderTime;
    updatedWeightRecordsOn = weightRecordsOn;
    updatedWeightRecordsReminderTime = weightRecordsReminderTime;
    updatedMacroTrackingOn = macroTrackingOn;
    updatedMacroTrackingReminderTime = macroTrackingReminderTime;
    emit(
      state.copyWith(
        remindersConfig: Nullable(
          state.remindersConfig!.copyWith(
            workoutsOn: workoutsOn,
            workoutsReminderTime: workoutsReminderTime,
            weightRecordsOn: weightRecordsOn,
            weightRecordsReminderTime: weightRecordsReminderTime,
            macroTrackingOn: macroTrackingOn,
            macroTrackingReminderTime: macroTrackingReminderTime,
          ),
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const permissionsChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Future<int> Function() requestStatus;
  late int permissionRequests;

  setUp(() {
    permissionRequests = 0;
    requestStatus = () async => 1;
    messenger.setMockMethodCallHandler(permissionsChannel, (call) async {
      expect(call.method, 'requestPermissions');
      expect(call.arguments, [17]);
      permissionRequests++;
      return <int, int>{17: await requestStatus()};
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(permissionsChannel, null));

  Widget buildSubject(
    _ProfileCubit cubit, {
    ScreenSize screenSize = ScreenSize.md,
  }) {
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);
    return BlocProvider<ProfileCubit>.value(
      value: cubit,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(sizes.viewPadding),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return SettingsConfig(
                    profileId: state.profile!.id,
                    sizes: sizes,
                    system: state.system!,
                    remindersConfig: state.remindersConfig!,
                    isLoading: state.isLoading,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'renders all reminder toggles, time fields, and weight day selector',
    (tester) async {
      final cubit = _ProfileCubit(
        workoutsOn: true,
        workoutsReminderTime: const TimeOfDayValue(hour: 7, minute: 30),
        weightRecordsOn: true,
        weightRecordsReminderTime: const WeekdayTimeOfDayValue(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: TimeOfDayValue(hour: 9, minute: 15),
        ),
        macroTrackingOn: true,
        macroTrackingReminderTime: const TimeOfDayValue(hour: 20, minute: 45),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('profile-reminders-settings')),
        findsOneWidget,
      );
      expect(find.text(' Reminders'), findsOneWidget);

      expect(find.text('Workouts'), findsOneWidget);
      expect(find.byKey(const ValueKey('reminder-workouts')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('reminder-workouts-time')),
        findsOneWidget,
      );
      expect(find.text('07:30'), findsOneWidget);

      expect(find.text('Weight Records'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('reminder-weight-records')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('reminder-weight-records-day')),
        findsOneWidget,
      );
      expect(find.text('Wed'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('reminder-weight-records-time')),
        findsOneWidget,
      );
      expect(find.text('09:15'), findsOneWidget);

      expect(find.text('Macro Tracking'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('reminder-macro-tracking')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('reminder-macro-tracking-time')),
        findsOneWidget,
      );
      expect(find.text('20:45'), findsOneWidget);
    },
  );

  testWidgets(
    'toggling switches updates workouts, weight records, and macro tracking',
    (tester) async {
      final cubit = _ProfileCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('reminder-workouts')));
      await tester.pumpAndSettle();
      expect(cubit.updatedWorkoutsOn, isTrue);

      await tester.tap(find.byKey(const ValueKey('reminder-weight-records')));
      await tester.pumpAndSettle();
      expect(cubit.updatedWeightRecordsOn, isTrue);

      await tester.tap(find.byKey(const ValueKey('reminder-macro-tracking')));
      await tester.pumpAndSettle();
      expect(cubit.updatedMacroTrackingOn, isTrue);
    },
  );

  for (final key in [
    'reminder-workouts',
    'reminder-macro-tracking',
    'reminder-weight-records',
  ]) {
    testWidgets('$key stays off when notification permission is denied', (
      tester,
    ) async {
      requestStatus = () async => 0;
      final cubit = _ProfileCubit();
      addTearDown(cubit.close);
      await tester.pumpWidget(buildSubject(cubit));
      final toggle = find.byKey(ValueKey(key));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(permissionRequests, 1);
      expect(tester.widget<SharpSwitch>(toggle).value, isFalse);
      expect(cubit.updatedWorkoutsOn, isNull);
      expect(cubit.updatedMacroTrackingOn, isNull);
      expect(cubit.updatedWeightRecordsOn, isNull);
      expect(
        find.text(
          'Please enable notifications in settings before enabling reminders.',
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('turning reminders off does not request permission', (
    tester,
  ) async {
    final cubit = _ProfileCubit(
      workoutsOn: true,
      macroTrackingOn: true,
      weightRecordsOn: true,
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(buildSubject(cubit));
    for (final key in [
      'reminder-workouts',
      'reminder-macro-tracking',
      'reminder-weight-records',
    ]) {
      final toggle = find.byKey(ValueKey(key));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(tester.widget<SharpSwitch>(toggle).value, isFalse);
    }
    expect(permissionRequests, 0);
  });

  testWidgets(
    'pending permission disables all reminders and survives disposal',
    (tester) async {
      final gate = Completer<int>();
      requestStatus = () => gate.future;
      final cubit = _ProfileCubit();
      addTearDown(cubit.close);
      await tester.pumpWidget(buildSubject(cubit));
      await tester.tap(find.byKey(const ValueKey('reminder-workouts')));
      await tester.pump();
      for (final key in [
        'reminder-workouts',
        'reminder-macro-tracking',
        'reminder-weight-records',
      ]) {
        expect(
          tester.widget<SharpSwitch>(find.byKey(ValueKey(key))).enabled,
          isFalse,
        );
      }
      expect(permissionRequests, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      gate.complete(1);
      await tester.pumpAndSettle();
      expect(cubit.updatedWorkoutsOn, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disabled when toggles are off', (tester) async {
    final cubit = _ProfileCubit(
      workoutsOn: false,
      weightRecordsOn: false,
      macroTrackingOn: false,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('reminder-workouts-time')));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('reminder-weight-records-day')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Fri'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('reminder-macro-tracking-time')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);
  });

  testWidgets('changing weight records day preserves hour and minute', (
    tester,
  ) async {
    final cubit = _ProfileCubit(
      weightRecordsOn: true,
      weightRecordsReminderTime: const WeekdayTimeOfDayValue(
        dayOfWeek: DayOfWeek.monday,
        timeOfDay: TimeOfDayValue(hour: 9, minute: 15),
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('reminder-weight-records-day')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fri').last);
    await tester.pumpAndSettle();

    final updated = cubit.updatedWeightRecordsReminderTime;
    expect(updated, isNotNull);
    expect(updated!.dayOfWeek, DayOfWeek.friday);
    expect(updated.hour, 9);
    expect(updated.minute, 15);
  });

  testWidgets(
    'picking time updates workouts, weight records (keeping weekday), and macro tracking',
    (tester) async {
      final cubit = _ProfileCubit(
        workoutsOn: true,
        workoutsReminderTime: const TimeOfDayValue(hour: 8, minute: 0),
        weightRecordsOn: true,
        weightRecordsReminderTime: const WeekdayTimeOfDayValue(
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: TimeOfDayValue(hour: 8, minute: 0),
        ),
        macroTrackingOn: true,
        macroTrackingReminderTime: const TimeOfDayValue(hour: 8, minute: 0),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pumpAndSettle();

      // Workouts time
      await tester.tap(find.byKey(const ValueKey('reminder-workouts-time')));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(cubit.updatedWorkoutsReminderTime?.hour, 8);
      expect(cubit.updatedWorkoutsReminderTime?.minute, 0);

      // Weight records time keeps Friday
      await tester.tap(
        find.byKey(const ValueKey('reminder-weight-records-time')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        cubit.updatedWeightRecordsReminderTime?.dayOfWeek,
        DayOfWeek.friday,
      );

      // Macro tracking time
      await tester.tap(
        find.byKey(const ValueKey('reminder-macro-tracking-time')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(cubit.updatedMacroTrackingReminderTime?.hour, 8);
      expect(cubit.updatedMacroTrackingReminderTime?.minute, 0);
    },
  );

  testWidgets('renders without overflow on narrow xs screen', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final cubit = _ProfileCubit(
      workoutsOn: true,
      weightRecordsOn: true,
      weightRecordsReminderTime: const WeekdayTimeOfDayValue(
        dayOfWeek: DayOfWeek.wednesday,
        timeOfDay: TimeOfDayValue(hour: 8, minute: 0),
      ),
      macroTrackingOn: true,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, screenSize: ScreenSize.xs));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(RemindersSettingsConfig), findsOneWidget);
  });
}
