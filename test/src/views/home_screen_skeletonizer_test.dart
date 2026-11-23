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
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myfitnesstale/src/data/repositories/macros/macro_tracking_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/time_of_day_value.dart';
import 'package:myfitnesstale/src/data/utils/weekday_time_of_day_value.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/screens/loading_screen.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/themes/theme_generator.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/core/widgets/base_carousel.dart';
import 'package:myfitnesstale/src/ui/home/screens/home_screen.dart';
import 'package:myfitnesstale/src/ui/home/screens/main_navigation_screen.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/macros/screens/macro_tracker_screen.dart';
import 'package:myfitnesstale/src/ui/macros/view_models/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/current_workout_plan_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets(
    'shows skeletonized HomeScreen on initial app load and reveals content once profile and active plans load',
    (tester) async {
      final profileGate = Completer<void>();
      final planGate = Completer<void>();
      final macroGate = Completer<void>();
      final profileCubit = _TestProfileCubit(
        gate: profileGate,
        withProfile: true,
      );
      final workoutPlanCubit = _TestWorkoutPlanRecordCubit(gate: planGate);
      final macroCubit = _TestMacroTrackingCubit(gate: macroGate);
      final mealPlanCubit = _TestMealPlanRecordCubit();

      await _pumpMainApp(
        tester,
        profileCubit: profileCubit..loadInitialData(),
        workoutPlanCubit: workoutPlanCubit,
        macroCubit: macroCubit,
        mealPlanCubit: mealPlanCubit,
      );

      // Initial load: HomeScreen is visible with Skeletonizer enabled, no LoadingScreen/spinner
      expect(find.byType(LoadingScreen), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Skeletonizer && w.enabled && w.ignorePointers,
        ),
        findsOneWidget,
      );

      // Tapping another bottom nav tab while loading stays on HomeScreen
      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        0,
      );

      // Complete profile load -> active plan & macro loads begin -> HomeScreen remains skeletonized
      profileGate.complete();
      await tester.pump();
      await tester.pump();
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
        findsOneWidget,
      );

      // Complete active plan and macro loads -> Skeletonizer disables and reveals content
      planGate.complete();
      macroGate.complete();
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && !w.enabled,
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Welcome back Home Tester!'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.text('Strength Foundation'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'redirects from skeletonized HomeScreen to onboarding when initial load finds no profile',
    (tester) async {
      final profileGate = Completer<void>();
      final profileCubit = _TestProfileCubit(
        gate: profileGate,
        withProfile: false,
      );
      final workoutPlanCubit = _TestWorkoutPlanRecordCubit();
      final macroCubit = _TestMacroTrackingCubit();
      final mealPlanCubit = _TestMealPlanRecordCubit();

      await _pumpMainApp(
        tester,
        profileCubit: profileCubit..loadInitialData(),
        workoutPlanCubit: workoutPlanCubit,
        macroCubit: macroCubit,
        mealPlanCubit: mealPlanCubit,
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
        findsOneWidget,
      );

      profileGate.complete();
      await tester.pumpAndSettle();

      expect(find.text('Onboarding destination'), findsOneWidget);
    },
  );

  testWidgets(
    'settles cleanly without re-triggering loads when active plan and macro goal return notFound',
    (tester) async {
      final profileGate = Completer<void>();
      final planGate = Completer<void>();
      final macroGate = Completer<void>();
      final profileCubit = _TestProfileCubit(
        gate: profileGate,
        withProfile: true,
      );
      final workoutPlanCubit = _TestWorkoutPlanRecordCubit(
        gate: planGate,
        returnActivePlan: false,
        markLoaded: true,
      );
      final macroCubit = _TestMacroTrackingCubit(
        gate: macroGate,
        markLoaded: true,
      );
      final mealPlanCubit = _TestMealPlanRecordCubit();

      await _pumpMainApp(
        tester,
        profileCubit: profileCubit..loadInitialData(),
        workoutPlanCubit: workoutPlanCubit,
        macroCubit: macroCubit,
        mealPlanCubit: mealPlanCubit,
      );

      profileGate.complete();
      await tester.pump();
      await tester.pump();

      expect(workoutPlanCubit.loadCalls, 1);
      expect(macroCubit.loadCalls, 1);
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
        findsOneWidget,
      );

      planGate.complete();
      macroGate.complete();
      await tester.pumpAndSettle();

      expect(workoutPlanCubit.loadCalls, 1);
      expect(macroCubit.loadCalls, 1);
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && !w.enabled,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.text('No Active Workout Plan'),
        ),
        findsOneWidget,
      );
      expect(find.text('No active meal plan or macro goal'), findsOneWidget);
    },
  );

  testWidgets(
    'does not loop Skeletonizer when null loads finish without setting hasLoaded flags',
    (tester) async {
      final profileGate = Completer<void>();
      final planGate = Completer<void>();
      final macroGate = Completer<void>();
      final profileCubit = _TestProfileCubit(
        gate: profileGate,
        withProfile: true,
      );
      final workoutPlanCubit = _TestWorkoutPlanRecordCubit(
        gate: planGate,
        returnActivePlan: false,
        markLoaded: false,
      );
      final macroCubit = _TestMacroTrackingCubit(
        gate: macroGate,
        markLoaded: false,
      );
      final mealPlanCubit = _TestMealPlanRecordCubit();

      await _pumpMainApp(
        tester,
        profileCubit: profileCubit..loadInitialData(),
        workoutPlanCubit: workoutPlanCubit,
        macroCubit: macroCubit,
        mealPlanCubit: mealPlanCubit,
      );

      profileGate.complete();
      await tester.pump();
      await tester.pump();

      planGate.complete();
      macroGate.complete();
      await tester.pumpAndSettle();

      expect(workoutPlanCubit.loadCalls, 1);
      expect(macroCubit.loadCalls, lessThanOrEqualTo(2));
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && !w.enabled,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.text('No Active Workout Plan'),
        ),
        findsOneWidget,
      );
      expect(find.text('No active meal plan or macro goal'), findsOneWidget);
    },
  );

  testWidgets(
    'renders without vertical overflow at 411.4x891.4 phone size during and after skeleton load',
    (tester) async {
      for (final scale in [0.85, 0.9, 1.0, 1.1, 1.15, 1.2, 1.3, 1.5, 2.0]) {
        tester.view.physicalSize = const Size(1080, 2340);
        tester.view.devicePixelRatio = 2.625;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final profileGate = Completer<void>();
        final planGate = Completer<void>();
        final macroGate = Completer<void>();
        final profileCubit = _TestProfileCubit(
          gate: profileGate,
          withProfile: true,
        );
        final workoutPlanCubit = _TestWorkoutPlanRecordCubit(
          gate: planGate,
          returnActivePlan: false,
          markLoaded: true,
        );
        final macroCubit = _TestMacroTrackingCubit(
          gate: macroGate,
          markLoaded: true,
        );
        final mealPlanCubit = _TestMealPlanRecordCubit();

        await _pumpMainApp(
          tester,
          profileCubit: profileCubit..loadInitialData(),
          workoutPlanCubit: workoutPlanCubit,
          macroCubit: macroCubit,
          mealPlanCubit: mealPlanCubit,
          theme: ThemeGenerator.defaultTheme,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'initial skeleton overflowed at scale $scale',
        );

        profileGate.complete();
        await tester.pump();
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'post-profile skeleton overflowed at scale $scale',
        );

        planGate.complete();
        macroGate.complete();
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'pre-font loaded overflowed at scale $scale',
        );
        await tester.runAsync(() => GoogleFonts.pendingFonts());
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'post-font loaded overflowed at scale $scale',
        );
      }
    },
  );

  testWidgets(
    'BaseCarousel with stretch resizes cleanly without RenderFlex overflow when child content grows or systemFonts notifies',
    (tester) async {
      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);
      final growChild = ValueNotifier<bool>(false);
      addTearDown(growChild.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 361.8,
                child: BaseCarousel(
                  sizes: sizes,
                  keyPrefix: 'resize-carousel',
                  labels: const ['First', 'Second'],
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(sizes.padding),
                      child: const Column(
                        children: [
                          SizedBox(height: 134.5, child: Text('First card')),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: growChild,
                      builder: (context, grown, _) {
                        return Padding(
                          padding: EdgeInsets.all(sizes.padding),
                          child: Column(
                            children: [
                              SizedBox(
                                height: grown ? 180.0 : 134.5,
                                child: const Text('Second card'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final content0 = find.byKey(const ValueKey('resize-carousel-content-0'));
      final content1 = find.byKey(const ValueKey('resize-carousel-content-1'));
      final initialHeight = tester.getSize(content0).height;
      expect(tester.getSize(content1).height, initialHeight);

      growChild.value = true;
      PaintingBinding.instance.handleSystemMessage(<String, Object?>{
        'type': 'fontsChange',
      });
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(content0).height, greaterThan(initialHeight));
      expect(tester.getSize(content0), tester.getSize(content1));
    },
  );

  testWidgets('loads active meal plan record on cold launch', (tester) async {
    final profileGate = Completer<void>()..complete();
    final profileCubit = _TestProfileCubit(
      gate: profileGate,
      withProfile: true,
    );
    final workoutPlanCubit = _TestWorkoutPlanRecordCubit(
      returnActivePlan: false,
    );
    final macroCubit = _TestMacroTrackingCubit();
    final mealPlanCubit = _TestMealPlanRecordCubit();

    await _pumpMainApp(
      tester,
      profileCubit: profileCubit..loadInitialData(),
      workoutPlanCubit: workoutPlanCubit,
      macroCubit: macroCubit,
      mealPlanCubit: mealPlanCubit,
    );
    await tester.pumpAndSettle();

    expect(mealPlanCubit.loadCalls, 1);
  });

  testWidgets(
    'shows startup error with retry instead of masking profile load failure',
    (tester) async {
      final profileGate = Completer<void>()..complete();
      final profileCubit = _TestProfileCubit(
        gate: profileGate,
        withProfile: true,
        failFirstLoad: true,
      );
      final workoutPlanCubit = _TestWorkoutPlanRecordCubit();
      final macroCubit = _TestMacroTrackingCubit();
      final mealPlanCubit = _TestMealPlanRecordCubit();

      await _pumpMainApp(
        tester,
        profileCubit: profileCubit..loadInitialData(),
        workoutPlanCubit: workoutPlanCubit,
        macroCubit: macroCubit,
        mealPlanCubit: mealPlanCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byKey(const ValueKey('home-startup-error-card')),
        findsOneWidget,
      );
      expect(find.text('Failed to load profile'), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
        findsNothing,
      );

      await tester.tap(find.text('RETRY'));
      await tester.pumpAndSettle();

      expect(profileCubit.loadCalls, 2);
      expect(
        find.byKey(const ValueKey('home-startup-error-card')),
        findsNothing,
      );
      expect(find.text('Welcome back Home Tester!'), findsOneWidget);
    },
  );

  testWidgets(
    'shows retry card when active meal plan load fails and retries cleanly',
    (tester) async {
      final profileGate = Completer<void>()..complete();
      final profileCubit = _TestProfileCubit(
        gate: profileGate,
        withProfile: true,
      );
      final workoutPlanCubit = _TestWorkoutPlanRecordCubit();
      final macroCubit = _TestMacroTrackingCubit();
      final mealPlanCubit = _TestMealPlanRecordCubit(failFirstLoad: true);

      await _pumpMainApp(
        tester,
        profileCubit: profileCubit..loadInitialData(),
        workoutPlanCubit: workoutPlanCubit,
        macroCubit: macroCubit,
        mealPlanCubit: mealPlanCubit,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('home-active-load-error-card')),
        findsOneWidget,
      );
      expect(find.text('Failed to load meal plan'), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);

      await tester.tap(find.text('RETRY'));
      await tester.pumpAndSettle();

      expect(mealPlanCubit.loadCalls, 2);
      expect(
        find.byKey(const ValueKey('home-active-load-error-card')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'defers tab warm-up until home active data loads complete so skeleton does not flicker',
    (tester) async {
      final profileGate = Completer<void>()..complete();
      final planGate = Completer<void>();
      final macroGate = Completer<void>();
      final profileCubit = _TestProfileCubit(
        gate: profileGate,
        withProfile: true,
      );
      final workoutPlanCubit = _TestWorkoutPlanRecordCubit(gate: planGate);
      final macroCubit = _TestMacroTrackingCubit(gate: macroGate);
      final mealPlanCubit = _TestMealPlanRecordCubit();

      await _pumpMainApp(
        tester,
        profileCubit: profileCubit..loadInitialData(),
        workoutPlanCubit: workoutPlanCubit,
        macroCubit: macroCubit,
        mealPlanCubit: mealPlanCubit,
      );
      await tester.pump();

      // Advance past initial warm-up delay while HomeScreen loads are still in flight.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();

      expect(
        find.byType(CurrentWorkoutPlanScreen, skipOffstage: false),
        findsNothing,
      );
      expect(
        find.byType(MacroTrackerScreen, skipOffstage: false),
        findsNothing,
      );
      expect(macroCubit.dailyLogCalls, 0);
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled,
          ),
        ),
        findsOneWidget,
      );

      // Complete home active loads -> next warm-up step mounts tabs cleanly.
      planGate.complete();
      macroGate.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();
      expect(
        find.byType(CurrentWorkoutPlanScreen, skipOffstage: false),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();
      expect(
        find.byType(MacroTrackerScreen, skipOffstage: false),
        findsOneWidget,
      );
      expect(macroCubit.dailyLogCalls, 1);

      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && !w.enabled,
          ),
        ),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpMainApp(
  WidgetTester tester, {
  required ProfileCubit profileCubit,
  required WorkoutPlanRecordCubit workoutPlanCubit,
  required MacroTrackingCubit macroCubit,
  required MealPlanRecordCubit mealPlanCubit,
  ThemeData? theme,
}) async {
  final router = GoRouter(
    initialLocation: Routes.home.name,
    routes: [
      GoRoute(
        path: Routes.home.name,
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: Routes.onboarding.name,
        builder: (context, state) =>
            const Scaffold(body: Text('Onboarding destination')),
      ),
    ],
  );
  final mealPlanListCubit = MealPlanCubit(
    mealPlanRepository: MealPlanRepository.create(),
  );
  addTearDown(() async {
    router.dispose();
    await profileCubit.close();
    await workoutPlanCubit.close();
    await macroCubit.close();
    await mealPlanListCubit.close();
    await mealPlanCubit.close();
  });

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<WorkoutPlanRecordCubit>.value(value: workoutPlanCubit),
        BlocProvider<MacroTrackingCubit>.value(value: macroCubit),
        BlocProvider<MealPlanCubit>.value(value: mealPlanListCubit),
        BlocProvider<MealPlanRecordCubit>.value(value: mealPlanCubit),
      ],
      child: MaterialApp.router(routerConfig: router, theme: theme),
    ),
  );
  await tester.pump();
}

final class _TestProfileCubit extends ProfileCubit {
  final Completer<void> gate;
  final bool withProfile;
  final bool failFirstLoad;
  int loadCalls = 0;

  _TestProfileCubit({
    required this.gate,
    required this.withProfile,
    this.failFirstLoad = false,
  }) : super(profileRepository: ProfileRepository.create());

  @override
  Future<void> loadInitialData() async {
    loadCalls++;
    emit(state.copyWith(isLoading: true));
    await gate.future;
    if (failFirstLoad && loadCalls == 1) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to load profile',
            ),
          ),
          isLoading: false,
          isInitiated: false,
        ),
      );
      return;
    }
    if (!withProfile) {
      emit(
        state.copyWith(
          isInitiated: true,
          isLoading: false,
          error: const Nullable(null),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        profile: Nullable(
          ProfileDto(
            id: 1,
            name: 'Home Tester',
            height: 178,
            gender: Gender.other,
            birthdate: DateTime(1992),
          ),
        ),
        system: const Nullable(
          SystemDto(
            id: 1,
            units: Units.metric,
            theme: ThemeType.system,
            initialSetup: SetUpStatus.completed,
            notificationsOn: false,
          ),
        ),
        remindersConfig: Nullable(
          RemindersConfigDto(
            id: 1,
            workoutsOn: false,
            workoutsReminderTime: TimeOfDayValue.defaultReminder,
            weightRecordsOn: false,
            weightRecordsReminderTime: WeekdayTimeOfDayValue.defaultReminder,
            macroTrackingOn: false,
            macroTrackingReminderTime: TimeOfDayValue.defaultReminder,
          ),
        ),
        isInitiated: true,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}

final class _TestWorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  final Completer<void>? gate;
  final bool returnActivePlan;
  final bool markLoaded;
  int loadCalls = 0;

  _TestWorkoutPlanRecordCubit({
    this.gate,
    this.returnActivePlan = true,
    this.markLoaded = true,
  }) : super(
         workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
         workoutPlanRepository: WorkoutPlanRepository.create(),
         workoutRecordRepository: WorkoutRecordRepository.create(),
       );

  @override
  Future<void> getLatestActivePlanRecord() async {
    loadCalls++;
    emit(state.copyWith(isLoading: true));
    await gate?.future;
    if (!returnActivePlan) {
      emit(
        state.copyWith(
          isLoading: false,
          hasLoadedActivePlan: markLoaded ? true : null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasLoadedActivePlan: markLoaded ? true : null,
        isLoading: false,
        currentPlanRecord: state.currentPlanRecord.copyWith(
          currentPlanRecord: Nullable(
            WorkoutPlanRecordDto(
              id: 1,
              workoutPlanId: 1,
              workoutPlanVersion: 1,
              status: ProgressStatus.inProgress,
              startedAt: DateTime(2026, 1, 1),
              currentWeek: 1,
              currentDay: 1,
              currentWorkoutPosition: 1,
            ),
          ),
          workoutPlan: const Nullable(
            WorkoutPlanDto(
              id: 1,
              name: 'Strength Foundation',
              currentVersion: 1,
              totalWeeks: 4,
              totalDays: 12,
              totalWorkouts: 12,
              difficulty: Difficulty.beginner,
              isFavorite: false,
              createdBy: CreatedBy.user,
            ),
          ),
          completedWorkouts: 3,
          totalWorkouts: 12,
        ),
      ),
    );
  }
}

final class _TestMacroTrackingCubit extends MacroTrackingCubit {
  final Completer<void>? gate;
  final bool markLoaded;
  int loadCalls = 0;
  int dailyLogCalls = 0;

  _TestMacroTrackingCubit({this.gate, this.markLoaded = true})
    : super(macroTrackingRepository: MacroTrackingRepository.create());

  @override
  Future<void> getActiveMacroGoal() async {
    loadCalls++;
    emit(state.copyWith(isLoading: true));
    await gate?.future;
    emit(
      state.copyWith(
        isLoading: false,
        hasLoadedActiveGoal: markLoaded ? true : null,
      ),
    );
  }

  @override
  Future<void> getDailyLog(DateTime date) async {
    dailyLogCalls++;
  }
}

final class _TestMealPlanRecordCubit extends MealPlanRecordCubit {
  final bool failFirstLoad;
  int loadCalls = 0;

  _TestMealPlanRecordCubit({this.failFirstLoad = false})
    : super(mealPlanRecordRepository: MealPlanRecordRepository.create());

  @override
  Future<void> getActiveMealPlanRecord() async {
    loadCalls++;
    if (failFirstLoad && loadCalls == 1) {
      emit(
        state.copyWith(
          isLoading: false,
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to load meal plan',
            ),
          ),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        hasLoadedActiveRecord: true,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}
