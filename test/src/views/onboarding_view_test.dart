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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myfitnesstale/src/data/repositories/macros/macro_tracking_repository.dart';
import 'package:myfitnesstale/src/data/repositories/onboarding/inputs/onboarding_input.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/time_of_day_value.dart';
import 'package:myfitnesstale/src/data/utils/weekday_time_of_day_value.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/home/screens/home_screen.dart';
import 'package:myfitnesstale/src/ui/home/screens/main_navigation_screen.dart';
import 'package:myfitnesstale/src/ui/home/screens/profile/onboarding_screen.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/macros/view_models/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  testWidgets(
    'bounces back with persistent rollback feedback and preserves form for retry',
    (tester) async {
      final cubit = _OnboardingProfileCubit(
        succeedOnAttempt: 2,
        pendingGates: [Completer<void>(), Completer<void>()],
      );
      addTearDown(cubit.close);

      await _pumpOnboardingRouter(tester, cubit);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Widget Tester',
      );

      final submit = find.byKey(const ValueKey('onboarding-submit'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && widget.enabled,
        ),
        findsOneWidget,
      );

      cubit.pendingGates[0].complete();
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding-error')), findsOneWidget);
      expect(find.textContaining('No data was saved'), findsOneWidget);
      expect(find.text('Widget Tester'), findsOneWidget);
      expect(cubit.attempts, 1);

      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && widget.enabled,
        ),
        findsOneWidget,
      );

      cubit.pendingGates[1].complete();
      await tester.pumpAndSettle();

      expect(cubit.attempts, 2);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && !widget.enabled,
        ),
        findsOneWidget,
      );
      expect(find.text('Welcome back Widget Tester!'), findsOneWidget);
    },
  );

  testWidgets(
    'navigates directly to skeletonized HomeScreen instead of CircularProgressIndicator',
    (tester) async {
      final gate = Completer<void>();
      final cubit = _OnboardingProfileCubit(
        succeedOnAttempt: 1,
        pendingGates: [gate],
      );
      addTearDown(cubit.close);

      await _pumpOnboardingRouter(tester, cubit);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Navigation Tester',
      );
      final submit = find.byKey(const ValueKey('onboarding-submit'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && widget.enabled,
        ),
        findsOneWidget,
      );

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && !widget.enabled,
        ),
        findsOneWidget,
      );
      expect(find.text('Welcome back Navigation Tester!'), findsOneWidget);
    },
  );

  testWidgets(
    'settles on HomeScreen without skeleton loop when post-onboarding active plan and macro goal are empty',
    (tester) async {
      final onboardingGate = Completer<void>();
      final planGate = Completer<void>();
      final macroGate = Completer<void>();
      final cubit = _OnboardingProfileCubit(
        succeedOnAttempt: 1,
        pendingGates: [onboardingGate],
      );
      final workoutPlanRecordCubit = _NoopWorkoutPlanRecordCubit(
        gate: planGate,
        simulateNotFoundLoad: true,
      );
      final macroTrackingCubit = _NoopMacroTrackingCubit(
        gate: macroGate,
        simulateNotFoundLoad: true,
      );
      addTearDown(cubit.close);

      await _pumpOnboardingRouter(
        tester,
        cubit,
        workoutPlanRecordCubit: workoutPlanRecordCubit,
        macroTrackingCubit: macroTrackingCubit,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Empty Home Tester',
      );
      final submit = find.byKey(const ValueKey('onboarding-submit'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && widget.enabled,
        ),
        findsOneWidget,
      );

      onboardingGate.complete();
      await tester.pump();
      await tester.pump();

      expect(workoutPlanRecordCubit.loadCalls, 1);
      expect(macroTrackingCubit.loadCalls, 1);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && widget.enabled,
        ),
        findsOneWidget,
      );

      planGate.complete();
      macroGate.complete();
      await tester.pumpAndSettle();

      expect(workoutPlanRecordCubit.loadCalls, 1);
      expect(macroTrackingCubit.loadCalls, 1);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && !widget.enabled,
        ),
        findsOneWidget,
      );
      expect(find.text('Welcome back Empty Home Tester!'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.text('No Active Workout Plan'),
        ),
        findsOneWidget,
      );
      expect(find.text('No active macro goal'), findsOneWidget);
    },
  );
}

Future<void> _pumpOnboardingRouter(
  WidgetTester tester,
  ProfileCubit profileCubit, {
  _NoopWorkoutPlanRecordCubit? workoutPlanRecordCubit,
  _NoopMacroTrackingCubit? macroTrackingCubit,
}) async {
  final resolvedWorkoutCubit =
      workoutPlanRecordCubit ?? _NoopWorkoutPlanRecordCubit();
  final resolvedMacroCubit = macroTrackingCubit ?? _NoopMacroTrackingCubit();
  final router = GoRouter(
    initialLocation: Routes.onboarding.name,
    routes: [
      GoRoute(
        path: Routes.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.home.name,
        builder: (context, state) => const MainNavigationScreen(),
      ),
    ],
  );
  addTearDown(() async {
    router.dispose();
    await resolvedWorkoutCubit.close();
    await resolvedMacroCubit.close();
  });

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<WorkoutPlanRecordCubit>.value(value: resolvedWorkoutCubit),
        BlocProvider<MacroTrackingCubit>.value(value: resolvedMacroCubit),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
}

final class _NoopWorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  final Completer<void>? gate;
  final bool simulateNotFoundLoad;
  int loadCalls = 0;

  _NoopWorkoutPlanRecordCubit({this.gate, this.simulateNotFoundLoad = false})
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );

  @override
  Future<void> getLatestActivePlanRecord() async {
    loadCalls++;
    if (!simulateNotFoundLoad) {
      return;
    }
    emit(state.copyWith(isLoading: true));
    await gate?.future;
    emit(state.copyWith(isLoading: false, hasLoadedActivePlan: true));
  }
}

final class _NoopMacroTrackingCubit extends MacroTrackingCubit {
  final Completer<void>? gate;
  final bool simulateNotFoundLoad;
  int loadCalls = 0;

  _NoopMacroTrackingCubit({this.gate, this.simulateNotFoundLoad = false})
    : super(macroTrackingRepository: MacroTrackingRepository.create());

  @override
  Future<void> getActiveMacroGoal() async {
    loadCalls++;
    if (!simulateNotFoundLoad) {
      return;
    }
    emit(state.copyWith(isLoading: true, isLoadingActiveGoal: true));
    await gate?.future;
    emit(
      state.copyWith(
        isLoading: false,
        isLoadingActiveGoal: false,
        hasLoadedActiveGoal: true,
      ),
    );
  }

  @override
  Future<void> getDailyLog(DateTime date) async {}
}

final class _OnboardingProfileCubit extends ProfileCubit {
  final int succeedOnAttempt;
  final List<Completer<void>> pendingGates;
  int attempts = 0;

  _OnboardingProfileCubit({
    required this.succeedOnAttempt,
    this.pendingGates = const [],
  }) : super(profileRepository: ProfileRepository.create());

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

    final attemptIndex = attempts;
    attempts++;
    final draft = OnboardingInput(
      units: units,
      theme: theme,
      name: name,
      height: height,
      gender: gender,
      birthday: birthday,
      createWorkouts: createWorkouts,
      notificationsOn: notificationsOn,
    );
    emit(
      state.copyWith(
        isLoading: true,
        error: const Nullable(null),
        onboardingDraft: Nullable(draft),
      ),
    );

    if (attemptIndex < pendingGates.length) {
      await pendingGates[attemptIndex].future;
    }

    if (attempts < succeedOnAttempt) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Setup failed. No data was saved. Please try again.',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        profile: Nullable(
          ProfileDto(
            id: 1,
            name: name,
            height: height,
            gender: gender,
            birthdate: birthday,
          ),
        ),
        system: Nullable(
          SystemDto(
            id: 1,
            units: units,
            theme: theme,
            initialSetup: SetUpStatus.completed,
            notificationsOn: notificationsOn,
          ),
        ),
        remindersConfig: Nullable(
          RemindersConfigDto(
            id: 1,
            workoutsOn: notificationsOn,
            workoutsReminderTime: TimeOfDayValue.defaultReminder,
            weightRecordsOn: notificationsOn,
            weightRecordsReminderTime: WeekdayTimeOfDayValue.defaultReminder,
            macroTrackingOn: notificationsOn,
            macroTrackingReminderTime: TimeOfDayValue.defaultReminder,
          ),
        ),
        onboardingDraft: const Nullable(null),
        isLoading: false,
        isInitiated: true,
        error: const Nullable(null),
      ),
    );
  }
}
