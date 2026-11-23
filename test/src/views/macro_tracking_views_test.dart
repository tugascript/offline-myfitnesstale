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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/active_workout_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/ui/foods/view_models/food_cubit.dart';
import 'package:myfitnesstale/src/ui/macros/view_models/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/recipes/view_models/recipe_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/weight/view_models/weight_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_record_cubit.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/strength_goals_list_screen.dart';
import 'package:myfitnesstale/src/ui/foods/screens/foods_screen.dart';
import 'package:myfitnesstale/src/ui/home/screens/home_screen.dart';
import 'package:myfitnesstale/src/ui/home/screens/main_navigation_screen.dart';
import 'package:myfitnesstale/src/ui/home/screens/profile/profile_screen.dart';
import 'package:myfitnesstale/src/ui/macros/screens/macro_goals_screen.dart';
import 'package:myfitnesstale/src/ui/macros/screens/macro_tracker_screen.dart';
import 'package:myfitnesstale/src/ui/macros/utils/tacker_scope.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_date_navigator.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_day_widget.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_month_widget.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_scope_selection.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_week_widget.dart';
import 'package:myfitnesstale/src/ui/recipes/screens/recipes_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/current_workout_plan_screen.dart';
import 'package:myfitnesstale/src/ui/home/widgets/active/active_meal_plan_widget.dart';
import 'package:myfitnesstale/src/ui/home/widgets/active/active_plans_carousel.dart';
import 'package:myfitnesstale/src/ui/home/widgets/quick_actions_widget.dart';
import 'package:myfitnesstale/src/data/repositories/foods/food_repository.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/recipe_repository.dart';
import 'package:myfitnesstale/src/data/repositories/macros/macro_tracking_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/weight/weight_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';

class _TestProfileCubit extends ProfileCubit {
  _TestProfileCubit() : super(profileRepository: ProfileRepository.create()) {
    emit(
      ProfileState(
        profile: ProfileDto(
          id: 1,
          name: 'Macro Tester',
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
        isLoading: false,
        isInitiated: true,
      ),
    );
  }
}

class _TestFoodCubit extends FoodCubit {
  _TestFoodCubit() : super(foodRepository: FoodRepository.create());

  @override
  Future<void> getFoods({
    String? search,
    FoodCategory? category,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _TestRecipeCubit extends RecipeCubit {
  _TestRecipeCubit() : super(recipeRepository: RecipeRepository.create());

  @override
  Future<void> getRecipes({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _TestMealPlanCubit extends MealPlanCubit {
  _TestMealPlanCubit() : super(mealPlanRepository: MealPlanRepository.create());

  int getMealPlanCalls = 0;

  @override
  Future<void> getMealPlans({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {}

  @override
  Future<void> getMealPlan(int id, {int? version}) async {
    getMealPlanCalls++;
  }
}

class _TestMealPlanRecordCubit extends MealPlanRecordCubit {
  _TestMealPlanRecordCubit({bool hasLoadedActiveRecord = false})
    : super(mealPlanRecordRepository: MealPlanRecordRepository.create()) {
    if (hasLoadedActiveRecord) {
      emit(state.copyWith(hasLoadedActiveRecord: true));
    }
  }

  int activeRecordCalls = 0;

  @override
  Future<void> getActiveMealPlanRecord() async {
    activeRecordCalls++;
  }
}

class _TestMacroTrackingCubit extends MacroTrackingCubit {
  _TestMacroTrackingCubit({bool hasLoadedActiveGoal = false})
    : super(macroTrackingRepository: MacroTrackingRepository.create()) {
    if (hasLoadedActiveGoal) {
      emit(state.copyWith(hasLoadedActiveGoal: true));
    }
  }

  int activeGoalCalls = 0;
  int dailyLogCalls = 0;
  int rangeLogCalls = 0;

  void beginActiveGoalLoad() {
    emit(state.copyWith(isLoading: true));
  }

  void completeActiveGoalLoad() {
    emit(state.copyWith(isLoading: false, hasLoadedActiveGoal: true));
  }

  @override
  Future<void> getActiveMacroGoal() async {
    activeGoalCalls++;
  }

  @override
  Future<void> getMacroGoals({int limit = 20, int offset = 0}) async {}

  @override
  Future<void> getDailyLog(DateTime date) async {
    dailyLogCalls++;
  }

  @override
  Future<void> getDailyLogsForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    rangeLogCalls++;
  }
}

class _TestExerciseRecordCubit extends ExerciseRecordCubit {
  _TestExerciseRecordCubit()
    : super(exerciseRecordRepository: ExerciseRecordRepository.create());

  @override
  Future<void> getActiveStrengthGoal({int? exerciseId}) async {}

  @override
  Future<void> getStrengthGoals({
    int? exerciseId,
    bool skipInProgress = false,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _TestWorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _TestWorkoutPlanRecordCubit()
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );

  int loadCalls = 0;

  void showPlan() {
    emit(
      state.copyWith(
        currentPlanRecord: state.currentPlanRecord.copyWith(
          workoutPlan: const Nullable(
            WorkoutPlanDto(
              id: 1,
              name: 'A workout plan with a longer title',
              currentVersion: 1,
              totalWeeks: 1,
              totalDays: 7,
              totalWorkouts: 3,
              difficulty: Difficulty.beginner,
              isFavorite: false,
              createdBy: CreatedBy.user,
            ),
          ),
          completedWorkouts: 1,
          totalWorkouts: 3,
        ),
      ),
    );
  }

  @override
  Future<void> getLatestActivePlanRecord() async {
    loadCalls++;
  }
}

void main() {
  Widget buildAppHarness({required Widget child, TextScaler? textScaler}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => child),
        GoRoute(
          path: Routes.workoutPlanList.name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Workout Plan Library')),
          ),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(create: (_) => _TestProfileCubit()),
        BlocProvider<ExerciseCubit>(
          create: (_) =>
              ExerciseCubit(exerciseRepository: ExerciseRepository.create()),
        ),
        BlocProvider<ExerciseRecordCubit>(
          create: (_) => _TestExerciseRecordCubit(),
        ),
        BlocProvider<WeightRecordCubit>(
          create: (_) => WeightRecordCubit(
            weightRecordRepository: WeightRecordRepository.create(),
          ),
        ),
        BlocProvider<WorkoutCubit>(
          create: (_) =>
              WorkoutCubit(workoutRepository: WorkoutRepository.create()),
        ),
        BlocProvider<WorkoutRecordCubit>(
          create: (_) => WorkoutRecordCubit(
            workoutRecordRepository: WorkoutRecordRepository.create(),
          ),
        ),
        BlocProvider<WorkoutPlanCubit>(
          create: (_) => WorkoutPlanCubit(
            workoutPlanRepository: WorkoutPlanRepository.create(),
          ),
        ),
        BlocProvider<WorkoutPlanRecordCubit>(
          create: (_) => _TestWorkoutPlanRecordCubit(),
        ),
        BlocProvider<ActiveWorkoutCubit>(
          create: (_) => ActiveWorkoutCubit(
            workoutRepository: WorkoutRepository.create(),
            workoutRecordRepository: WorkoutRecordRepository.create(),
            workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
          ),
        ),
        BlocProvider<FoodCubit>(create: (_) => _TestFoodCubit()),
        BlocProvider<RecipeCubit>(create: (_) => _TestRecipeCubit()),
        BlocProvider<MacroTrackingCubit>(
          create: (_) => _TestMacroTrackingCubit(),
        ),
        BlocProvider<MealPlanCubit>(create: (_) => _TestMealPlanCubit()),
        BlocProvider<MealPlanRecordCubit>(
          create: (_) => _TestMealPlanRecordCubit(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: textScaler == null
            ? null
            : (context, c) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: c!,
              ),
      ),
    );
  }

  group('Quick Actions Widget', () {
    testWidgets(
      'renders four grouped shortcuts instead of individual actions',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(
            child: Scaffold(
              body: SingleChildScrollView(
                child: QuickActionsWidget(
                  theme: ThemeData(),
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.md),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey('quick-action-category-training')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('quick-action-category-weight')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('quick-action-category-exercises')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('quick-action-category-nutrition')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('quick-action-macro-goals')),
          findsNothing,
        );
      },
    );
  });

  group('Home Page Sections', () {
    for (final scale in [1.0, 2.0]) {
      testWidgets('active plans swipe and indicators work at text $scale', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          buildAppHarness(
            textScaler: TextScaler.linear(scale),
            child: Scaffold(
              body: SingleChildScrollView(
                child: ActivePlansCarousel(
                  theme: ThemeData(),
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final scroll = find.byKey(const ValueKey('active-plans-scroll'));
        final height = tester.getSize(scroll).height;
        final content0 = find.byKey(const ValueKey('active-plans-content-0'));
        final content1 = find.byKey(const ValueKey('active-plans-content-1'));
        expect(tester.getSize(content0), tester.getSize(content1));
        final line = find.byKey(const ValueKey('active-plans-line-0'));
        final selectorWidth = tester.getSize(scroll).width;
        for (final index in [0, 1]) {
          expect(
            tester
                .getSize(find.byKey(ValueKey('active-plans-page-$index')))
                .width,
            selectorWidth / 2,
          );
          expect(
            tester
                .getSize(find.byKey(ValueKey('active-plans-line-$index')))
                .width,
            selectorWidth / 2,
          );
        }
        expect(tester.getTopLeft(line).dx, tester.getTopLeft(scroll).dx);
        expect(
          tester.getSize(line).width,
          greaterThan(tester.getSize(line).height),
        );
        expect(
          tester.getTopLeft(line).dy,
          lessThan(tester.getTopLeft(find.text('Workout')).dy),
        );
        final headingPosition = tester.getTopLeft(find.text('Active plans'));
        expect(find.text('Active Workout Plan'), findsNothing);
        expect(find.text('Active Meal Plan'), findsNothing);
        expect(find.text('Open Tracker'), findsNothing);
        await tester.drag(scroll, const Offset(-260, 0));
        await tester.pumpAndSettle();
        expect(
          find.text('No active meal plan or macro goal').hitTestable(),
          findsOneWidget,
        );
        expect(tester.getSize(scroll).height, height);
        expect(tester.getTopLeft(find.text('Active plans')), headingPosition);
        await tester.tap(find.byKey(const ValueKey('active-plans-page-0')));
        await tester.pumpAndSettle();
        expect(
          find.text('No Active Workout Plan').hitTestable(),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const ValueKey('active-workout-plan-browse')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Workout Plan Library'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('active-plans-page-1')));
        await tester.pumpAndSettle();
        expect(
          find.text('No active meal plan or macro goal').hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        final cubit =
            tester.element(scroll).read<WorkoutPlanRecordCubit>()
                as _TestWorkoutPlanRecordCubit;
        cubit.showPlan();
        await tester.pumpAndSettle();
        expect(tester.getSize(content0), tester.getSize(content1));
        expect(find.text('1 of 3 workouts'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('renders active meal plan widget without a history section', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAppHarness(child: const Scaffold(body: HomeScreen())),
      );
      await tester.pump();

      expect(find.byType(ActiveMealPlanWidget), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('History'), findsNothing);
      expect(find.text('Workout History'), findsNothing);
      expect(find.text('Exercise History'), findsNothing);
      expect(find.text('Weight History'), findsNothing);
      expect(find.text('Plan History'), findsNothing);
    });
  });

  group('Main Navigation View', () {
    testWidgets(
      'current plan tab keeps its cached page without reloading on revisits',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(child: const MainNavigationScreen()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final cubit =
            tester
                    .element(find.byType(MainNavigationScreen))
                    .read<WorkoutPlanRecordCubit>()
                as _TestWorkoutPlanRecordCubit;
        final initialLoads = cubit.loadCalls;
        final navigation = find.byKey(const ValueKey('main-bottom-navigation'));
        await tester.tap(
          find.descendant(of: navigation, matching: find.text('Plan')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('No Active Workout Plan'), findsOneWidget);
        expect(cubit.loadCalls, initialLoads + 1);
        await tester.tap(
          find.descendant(of: navigation, matching: find.text('Home')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(
          find.descendant(of: navigation, matching: find.text('Plan')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(cubit.loadCalls, initialLoads + 1);
      },
    );

    testWidgets('has Macros navigation tab instead of Meals', (tester) async {
      await tester.pumpWidget(
        buildAppHarness(child: const MainNavigationScreen()),
      );
      await tester.pump();

      // Verify bottom nav items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Meals'), findsNothing);
      expect(find.text('Macros'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Activity'), findsNothing);

      // Tap Tracker tab
      await tester.tap(find.text('Macros'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MacroTrackerScreen), findsOneWidget);
    });

    testWidgets('tracker tab fits large text and preserves its scope', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildAppHarness(
          textScaler: const TextScaler.linear(2.0),
          child: const MainNavigationScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(MacroTrackerScreen).hitTestable(), findsNothing);
      await tester.tap(find.text('Macros'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(MacroTrackerScreen).hitTestable(), findsOneWidget);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        2,
      );
      await tester.tap(find.text('Week'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Macros'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        tester
            .widget<MacroTrackerScopeSelection>(
              find.byType(MacroTrackerScopeSelection),
            )
            .scope,
        TrackerScope.week,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'warms up unvisited tabs offscreen in staggered steps after home settles',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(child: const MainNavigationScreen()),
        );
        await tester.pump();

        expect(
          find.byType(CurrentWorkoutPlanScreen, skipOffstage: false),
          findsNothing,
        );
        expect(
          find.byType(MacroTrackerScreen, skipOffstage: false),
          findsNothing,
        );
        expect(find.byType(ProfileScreen, skipOffstage: false), findsNothing);

        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump();
        expect(
          find.byType(CurrentWorkoutPlanScreen, skipOffstage: false),
          findsOneWidget,
        );
        expect(find.byType(CurrentWorkoutPlanScreen), findsNothing);
        expect(
          find.byType(MacroTrackerScreen, skipOffstage: false),
          findsNothing,
        );

        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump();
        expect(
          find.byType(MacroTrackerScreen, skipOffstage: false),
          findsOneWidget,
        );
        expect(find.byType(MacroTrackerScreen), findsNothing);
        expect(find.byType(ProfileScreen, skipOffstage: false), findsNothing);

        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump();
        expect(find.byType(ProfileScreen, skipOffstage: false), findsOneWidget);
        expect(find.byType(ProfileScreen), findsNothing);
      },
    );

    testWidgets(
      'MacroTrackerScreen reuses loaded active macro goal and meal plan record',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(hasLoadedActiveGoal: true);
        final mealPlanRecordCubit = _TestMealPlanRecordCubit(
          hasLoadedActiveRecord: true,
        );
        final mealPlanCubit = _TestMealPlanCubit();
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MacroTrackerScreen(),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          await macroCubit.close();
          await mealPlanRecordCubit.close();
          await mealPlanCubit.close();
        });

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<MacroTrackingCubit>.value(value: macroCubit),
              BlocProvider<MealPlanRecordCubit>.value(
                value: mealPlanRecordCubit,
              ),
              BlocProvider<MealPlanCubit>.value(value: mealPlanCubit),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        expect(macroCubit.activeGoalCalls, 0);
        expect(mealPlanRecordCubit.activeRecordCalls, 0);
        expect(macroCubit.dailyLogCalls, 1);
      },
    );

    testWidgets(
      'MacroTrackerScreen waits for in-flight active goal load before fetching daily log',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit()..beginActiveGoalLoad();
        final mealPlanRecordCubit = _TestMealPlanRecordCubit(
          hasLoadedActiveRecord: true,
        );
        final mealPlanCubit = _TestMealPlanCubit();
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MacroTrackerScreen(),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          await macroCubit.close();
          await mealPlanRecordCubit.close();
          await mealPlanCubit.close();
        });

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<MacroTrackingCubit>.value(value: macroCubit),
              BlocProvider<MealPlanRecordCubit>.value(
                value: mealPlanRecordCubit,
              ),
              BlocProvider<MealPlanCubit>.value(value: mealPlanCubit),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        expect(macroCubit.dailyLogCalls, 0);
        expect(macroCubit.activeGoalCalls, 0);

        macroCubit.completeActiveGoalLoad();
        await tester.pump();

        expect(macroCubit.activeGoalCalls, 0);
        expect(macroCubit.dailyLogCalls, 1);
      },
    );

    testWidgets(
      'MacroTrackerScopeSelection renders underline indicators and responds to tap and swipe',
      (tester) async {
        final theme = ThemeData.light();
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);
        TrackerScope selected = TrackerScope.day;
        var todayTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => MacroTrackerScopeSelection(
                  sizes: sizes,
                  theme: theme,
                  scope: selected,
                  onScopeChanged: (next) => setState(() => selected = next),
                  onGoToToday: () => todayTapped = true,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(SegmentedButton<TrackerScope>), findsNothing);
        expect(
          tester
              .widget<Container>(
                find.byKey(const ValueKey('macro-tracker-scope-indicator')),
              )
              .color,
          theme.colorScheme.primary,
        );
        expect(
          tester
              .widget<Align>(
                find.byKey(
                  const ValueKey('macro-tracker-scope-indicator-align'),
                ),
              )
              .alignment,
          const Alignment(-1, 0),
        );

        await tester.tap(find.text('Month'));
        await tester.pump();
        expect(selected, TrackerScope.month);
        expect(
          tester
              .widget<Align>(
                find.byKey(
                  const ValueKey('macro-tracker-scope-indicator-align'),
                ),
              )
              .alignment,
          const Alignment(1, 0),
        );

        await tester.fling(
          find.byKey(const ValueKey('macro-tracker-scope-selector')),
          const Offset(200, 0),
          500,
        );
        await tester.pump();
        expect(selected, TrackerScope.week);
        expect(
          tester
              .widget<Align>(
                find.byKey(
                  const ValueKey('macro-tracker-scope-indicator-align'),
                ),
              )
              .alignment,
          const Alignment(0, 0),
        );

        await tester.tap(find.byKey(const ValueKey('macro-tracker-today-btn')));
        await tester.pump();
        expect(todayTapped, isTrue);
      },
    );

    testWidgets(
      'MacroTrackerDateNavigator disables chevrons according to canGoPrevious and canGoNext',
      (tester) async {
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);
        var nextCalls = 0;
        var prevCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MacroTrackerDateNavigator(
                sizes: sizes,
                scope: TrackerScope.day,
                selectedDate: DateTime(2026, 11, 24),
                canGoPrevious: true,
                canGoNext: false,
                onPrevious: () => prevCalls++,
                onNext: () => nextCalls++,
                onDatePicked: (_) {},
              ),
            ),
          ),
        );

        final disabledNextBtn = tester.widget<IconButton>(
          find.byKey(const ValueKey('macro-tracker-next-btn')),
        );
        expect(disabledNextBtn.onPressed, isNull);

        await tester.tap(find.byKey(const ValueKey('macro-tracker-next-btn')));
        await tester.tap(find.byKey(const ValueKey('macro-tracker-prev-btn')));
        await tester.pump();
        expect(nextCalls, 0);
        expect(prevCalls, 1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MacroTrackerDateNavigator(
                sizes: sizes,
                scope: TrackerScope.day,
                selectedDate: DateTime(2025, 11, 24),
                canGoPrevious: false,
                canGoNext: true,
                onPrevious: () => prevCalls++,
                onNext: () => nextCalls++,
                onDatePicked: (_) {},
              ),
            ),
          ),
        );

        final disabledPrevBtn = tester.widget<IconButton>(
          find.byKey(const ValueKey('macro-tracker-prev-btn')),
        );
        expect(disabledPrevBtn.onPressed, isNull);

        await tester.tap(find.byKey(const ValueKey('macro-tracker-prev-btn')));
        await tester.tap(find.byKey(const ValueKey('macro-tracker-next-btn')));
        await tester.pump();
        expect(prevCalls, 1);
        expect(nextCalls, 1);
      },
    );

    testWidgets(
      'MacroTrackerDateNavigator clamps initialDate when selectedDate precedes firstDate',
      (tester) async {
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);
        final today = DateUtils.dateOnly(DateTime.now());
        final firstDate = MacroTrackerDateNavigator.defaultFirstDate(today);
        final thirteenMonthsAgo = DateTime(today.year, today.month - 13, 1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MacroTrackerDateNavigator(
                sizes: sizes,
                scope: TrackerScope.month,
                selectedDate: thirteenMonthsAgo,
                firstDate: firstDate,
                lastDate: today,
                canGoPrevious: false,
                canGoNext: true,
                onPrevious: () {},
                onNext: () {},
                onDatePicked: (_) {},
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(const ValueKey('macro-tracker-date-btn')));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final picker = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(picker.initialDate, firstDate);
        expect(picker.firstDate, firstDate);
        expect(picker.lastDate, today);
      },
    );

    testWidgets(
      'MacroTrackerScreen supports horizontal scrolling between Day, Week, and Month',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(hasLoadedActiveGoal: true);
        final mealPlanRecordCubit = _TestMealPlanRecordCubit(
          hasLoadedActiveRecord: true,
        );
        final mealPlanCubit = _TestMealPlanCubit();
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MacroTrackerScreen(),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          await macroCubit.close();
          await mealPlanRecordCubit.close();
          await mealPlanCubit.close();
        });

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<MacroTrackingCubit>.value(value: macroCubit),
              BlocProvider<MealPlanRecordCubit>.value(
                value: mealPlanRecordCubit,
              ),
              BlocProvider<MealPlanCubit>.value(value: mealPlanCubit),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MacroTrackerDayWidget), findsOneWidget);
        expect(macroCubit.rangeLogCalls, 0);

        // Swipe left from Day -> Week
        await tester.drag(
          find.byKey(const ValueKey('macro-tracker-scope-pager')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<MacroTrackerScopeSelection>(
                find.byType(MacroTrackerScopeSelection),
              )
              .scope,
          TrackerScope.week,
        );
        expect(find.byType(MacroTrackerWeekWidget), findsOneWidget);
        expect(macroCubit.rangeLogCalls, 1);

        // Swipe left from Week -> Month
        await tester.drag(
          find.byKey(const ValueKey('macro-tracker-scope-pager')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<MacroTrackerScopeSelection>(
                find.byType(MacroTrackerScopeSelection),
              )
              .scope,
          TrackerScope.month,
        );
        expect(find.byType(MacroTrackerMonthWidget), findsOneWidget);
        expect(macroCubit.rangeLogCalls, 2);
        expect(macroCubit.dailyLogCalls, 1);

        // Jump straight back to Day via tap without an intermediate Week fetch
        await tester.tap(find.text('Day'));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<MacroTrackerScopeSelection>(
                find.byType(MacroTrackerScopeSelection),
              )
              .scope,
          TrackerScope.day,
        );
        expect(find.byType(MacroTrackerDayWidget), findsOneWidget);
        expect(macroCubit.rangeLogCalls, 2);

        // Tap Month from Day: should trigger only one range load (no Week load)
        await tester.tap(find.text('Month'));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<MacroTrackerScopeSelection>(
                find.byType(MacroTrackerScopeSelection),
              )
              .scope,
          TrackerScope.month,
        );
        expect(macroCubit.rangeLogCalls, 3);

        // Tapping a day row in Month returns to Day scope and syncs the PageView
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<MacroTrackerScopeSelection>(
                find.byType(MacroTrackerScopeSelection),
              )
              .scope,
          TrackerScope.day,
        );
        expect(find.byType(MacroTrackerDayWidget), findsOneWidget);
      },
    );

    testWidgets(
      'MacroTrackerScreen disables next chevron when next period is past today',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(child: const MacroTrackerScreen()),
        );
        await tester.pumpAndSettle();

        IconButton nextButton() => tester.widget<IconButton>(
          find.byKey(const ValueKey('macro-tracker-next-btn')),
        );

        // Day scope on today -> next disabled
        expect(nextButton().onPressed, isNull);

        // Step to yesterday -> next enabled
        await tester.tap(find.byKey(const ValueKey('macro-tracker-prev-btn')));
        await tester.pumpAndSettle();
        expect(nextButton().onPressed, isNotNull);

        // Step back to today -> next disabled again
        await tester.tap(find.byKey(const ValueKey('macro-tracker-next-btn')));
        await tester.pumpAndSettle();
        expect(nextButton().onPressed, isNull);

        // Week scope on current week -> next disabled; previous week -> enabled
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();
        expect(nextButton().onPressed, isNull);

        await tester.tap(find.byKey(const ValueKey('macro-tracker-prev-btn')));
        await tester.pumpAndSettle();
        expect(nextButton().onPressed, isNotNull);

        await tester.tap(find.byKey(const ValueKey('macro-tracker-next-btn')));
        await tester.pumpAndSettle();
        expect(nextButton().onPressed, isNull);

        // Month scope on current month -> next disabled; previous month -> enabled
        await tester.tap(find.text('Month'));
        await tester.pumpAndSettle();
        expect(nextButton().onPressed, isNull);

        await tester.tap(find.byKey(const ValueKey('macro-tracker-prev-btn')));
        await tester.pumpAndSettle();
        expect(nextButton().onPressed, isNotNull);

        await tester.tap(find.byKey(const ValueKey('macro-tracker-today-btn')));
        await tester.pumpAndSettle();
        expect(nextButton().onPressed, isNull);
      },
    );

    testWidgets(
      'MacroTrackerScreen aligns previous navigation with one-year picker minimum',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(child: const MacroTrackerScreen()),
        );
        await tester.pumpAndSettle();

        final today = DateUtils.dateOnly(DateTime.now());
        final minDate = MacroTrackerDateNavigator.defaultFirstDate(today);
        final maxMonthSteps =
            (today.year - minDate.year) * 12 + (today.month - minDate.month);

        IconButton prevButton() => tester.widget<IconButton>(
          find.byKey(const ValueKey('macro-tracker-prev-btn')),
        );

        await tester.tap(find.text('Month'));
        await tester.pumpAndSettle();

        for (var i = 0; i < maxMonthSteps; i++) {
          expect(prevButton().onPressed, isNotNull);
          await tester.tap(
            find.byKey(const ValueKey('macro-tracker-prev-btn')),
          );
          await tester.pumpAndSettle();
        }

        // At the earliest month containing minDate, further backward navigation is disabled.
        expect(prevButton().onPressed, isNull);

        // Tapping the date header at the lower bound opens the picker cleanly.
        await tester.tap(find.byKey(const ValueKey('macro-tracker-date-btn')));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final picker = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(picker.initialDate, minDate);
        expect(picker.firstDate, minDate);
        expect(picker.lastDate, today);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Switching to Day scope stays clamped at minDate with previous disabled.
        await tester.tap(find.text('Day'));
        await tester.pumpAndSettle();
        expect(prevButton().onPressed, isNull);
      },
    );

    testWidgets(
      'MacroTrackerWeekWidget disables days outside the allowed history range',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(hasLoadedActiveGoal: true);
        addTearDown(macroCubit.close);
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);
        final theme = ThemeData.light();
        final today = DateUtils.dateOnly(DateTime.now());
        final minDate = MacroTrackerDateNavigator.defaultFirstDate(today);
        DateTime? pickedDate;

        Future<void> pumpWeek(DateTime date) async {
          await tester.pumpWidget(
            BlocProvider<MacroTrackingCubit>.value(
              value: macroCubit,
              child: MaterialApp(
                theme: theme,
                home: Scaffold(
                  body: MacroTrackerWeekWidget(
                    sizes: sizes,
                    theme: theme,
                    selectedDate: date,
                    onSelectDate: (d) => pickedDate = d,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        // Current week: today is selectable; any remaining days after today are disabled.
        await pumpWeek(today);
        final currentWeekTiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();
        final todayIndex = today.weekday - 1;
        expect(currentWeekTiles[todayIndex].enabled, isTrue);
        expect(currentWeekTiles[todayIndex].onTap, isNotNull);

        for (var i = todayIndex + 1; i < currentWeekTiles.length; i++) {
          expect(currentWeekTiles[i].enabled, isFalse);
          expect(currentWeekTiles[i].onTap, isNull);
          expect(currentWeekTiles[i].trailing, isNull);
        }

        await tester.tap(find.byType(ListTile).at(todayIndex));
        await tester.pump();
        expect(pickedDate, today);

        // Next week: all visible days are after today and cannot be selected.
        pickedDate = null;
        await pumpWeek(DateTime(today.year, today.month, today.day + 7));
        final futureWeekTiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();
        expect(futureWeekTiles, isNotEmpty);
        for (final tile in futureWeekTiles) {
          expect(tile.enabled, isFalse);
          expect(tile.onTap, isNull);
          expect(tile.trailing, isNull);
        }

        await tester.tap(find.byType(ListTile).first);
        await tester.pump();
        expect(pickedDate, isNull);

        // Week entirely before minDate: all visible days are disabled.
        pickedDate = null;
        await pumpWeek(DateTime(minDate.year, minDate.month, minDate.day - 7));
        final expiredWeekTiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();
        expect(expiredWeekTiles, isNotEmpty);
        for (final tile in expiredWeekTiles) {
          expect(tile.enabled, isFalse);
          expect(tile.onTap, isNull);
          expect(tile.trailing, isNull);
        }

        await tester.tap(find.byType(ListTile).first);
        await tester.pump();
        expect(pickedDate, isNull);
      },
    );

    testWidgets(
      'MacroTrackerMonthWidget disables days outside the allowed history range',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(hasLoadedActiveGoal: true);
        addTearDown(macroCubit.close);
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);
        final theme = ThemeData.light();
        final today = DateUtils.dateOnly(DateTime.now());
        final minDate = MacroTrackerDateNavigator.defaultFirstDate(today);
        DateTime? pickedDate;

        Future<void> pumpMonth(DateTime date) async {
          await tester.pumpWidget(
            BlocProvider<MacroTrackingCubit>.value(
              value: macroCubit,
              child: MaterialApp(
                theme: theme,
                home: Scaffold(
                  body: MacroTrackerMonthWidget(
                    sizes: sizes,
                    theme: theme,
                    selectedDate: date,
                    onSelectDate: (d) => pickedDate = d,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        // Current month: day 1 is selectable.
        await pumpMonth(today);
        final firstDayTile = tester.widget<ListTile>(
          find.byType(ListTile).first,
        );
        expect(firstDayTile.enabled, isTrue);
        expect(firstDayTile.onTap, isNotNull);
        await tester.tap(find.byType(ListTile).first);
        await tester.pump();
        expect(pickedDate, DateTime(today.year, today.month, 1));

        // Next month: all visible days are after today and cannot be selected.
        pickedDate = null;
        await pumpMonth(DateTime(today.year, today.month + 1, 1));
        final futureMonthTiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();
        expect(futureMonthTiles, isNotEmpty);
        for (final tile in futureMonthTiles) {
          expect(tile.enabled, isFalse);
          expect(tile.onTap, isNull);
        }

        await tester.tap(find.byType(ListTile).first);
        await tester.pump();
        expect(pickedDate, isNull);

        // Month before minDate: all visible days are disabled.
        pickedDate = null;
        await pumpMonth(DateTime(minDate.year, minDate.month - 1, 1));
        final expiredMonthTiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();
        expect(expiredMonthTiles, isNotEmpty);
        for (final tile in expiredMonthTiles) {
          expect(tile.enabled, isFalse);
          expect(tile.onTap, isNull);
        }

        await tester.tap(find.byType(ListTile).first);
        await tester.pump();
        expect(pickedDate, isNull);
      },
    );
  });

  group('Responsive Narrow and Scaled Layouts', () {
    testWidgets('MacroTrackerScreen renders narrow screen with large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildAppHarness(
          textScaler: const TextScaler.linear(2.0),
          child: const MacroTrackerScreen(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Macro Tracker'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FoodsScreen renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildAppHarness(child: const FoodsScreen()));
      await tester.pump();

      expect(find.textContaining('Foods'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RecipesScreen renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildAppHarness(child: const RecipesScreen()));
      await tester.pump();

      expect(find.textContaining('Recipes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StrengthGoalsListScreen renders narrow screen', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildAppHarness(child: const StrengthGoalsListScreen()),
      );
      await tester.pump();

      expect(find.textContaining('Strength Goals'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MacroGoalsScreen renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildAppHarness(child: const MacroGoalsScreen()));
      await tester.pump();

      expect(find.textContaining('Macro Goals'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
