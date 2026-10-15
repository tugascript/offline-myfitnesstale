import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/cubits/active_workout_cubit.dart';
import 'package:myfitnesstale/src/cubits/entitlement_cubit.dart';
import 'package:myfitnesstale/src/cubits/exercise_cubit.dart';
import 'package:myfitnesstale/src/cubits/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/cubits/food_cubit.dart';
import 'package:myfitnesstale/src/cubits/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/cubits/meal_plan_cubit.dart';
import 'package:myfitnesstale/src/cubits/meal_plan_record_cubit.dart';
import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/cubits/recipe_cubit.dart';
import 'package:myfitnesstale/src/cubits/states/profile_state.dart';
import 'package:myfitnesstale/src/cubits/weight_record_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_record_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/services/dtos/system_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/views/exercises/strength_goals_view.dart';
import 'package:myfitnesstale/src/views/foods/foods_view.dart';
import 'package:myfitnesstale/src/views/home/home_view.dart';
import 'package:myfitnesstale/src/views/home/main_navigation_view.dart';
import 'package:myfitnesstale/src/views/macro_goals/macro_goals_view.dart';
import 'package:myfitnesstale/src/views/macros/macro_tracker_view.dart';
import 'package:myfitnesstale/src/views/recipes/recipes_view.dart';
import 'package:myfitnesstale/src/views/workout_plans/workout_plan_list_view.dart';
import 'package:myfitnesstale/src/widgets/dashboard/active/active_meal_plan_widget.dart';
import 'package:myfitnesstale/src/widgets/dashboard/active/active_plans_carousel.dart';
import 'package:myfitnesstale/src/widgets/dashboard/progress_section.dart';
import 'package:myfitnesstale/src/widgets/dashboard/quick_actions_widget.dart';

class _TestProfileCubit extends ProfileCubit {
  _TestProfileCubit() {
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
  @override
  Future<void> getRecipes({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _TestMealPlanCubit extends MealPlanCubit {
  @override
  Future<void> getMealPlans({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _TestMealPlanRecordCubit extends MealPlanRecordCubit {
  @override
  Future<void> getActiveMealPlanRecord() async {}
}

class _TestMacroTrackingCubit extends MacroTrackingCubit {
  @override
  Future<void> getActiveMacroGoal() async {}

  @override
  Future<void> getMacroGoals({int limit = 20, int offset = 0}) async {}

  @override
  Future<void> getDailyLog(DateTime date) async {}

  @override
  Future<void> getDailyLogsForRange({
    required DateTime start,
    required DateTime end,
  }) async {}
}

class _TestExerciseRecordCubit extends ExerciseRecordCubit {
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
  int loadCalls = 0;

  void showPlan() {
    emit(
      state.copyWith(
        currentPlanRecord: state.currentPlanRecord.copyWith(
          workoutPlan: const WorkoutPlanDto(
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
          path: WorkoutPlanListView.routeName,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Workout Plan Library')),
          ),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(create: (_) => _TestProfileCubit()),
        BlocProvider<EntitlementCubit>(create: (_) => EntitlementCubit()),
        BlocProvider<ExerciseCubit>(create: (_) => ExerciseCubit()),
        BlocProvider<ExerciseRecordCubit>(
          create: (_) => _TestExerciseRecordCubit(),
        ),
        BlocProvider<WeightRecordCubit>(create: (_) => WeightRecordCubit()),
        BlocProvider<WorkoutCubit>(create: (_) => WorkoutCubit()),
        BlocProvider<WorkoutRecordCubit>(create: (_) => WorkoutRecordCubit()),
        BlocProvider<WorkoutPlanCubit>(create: (_) => WorkoutPlanCubit()),
        BlocProvider<WorkoutPlanRecordCubit>(
          create: (_) => _TestWorkoutPlanRecordCubit(),
        ),
        BlocProvider<ActiveWorkoutCubit>(create: (_) => ActiveWorkoutCubit()),
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
        final cards = find.descendant(of: scroll, matching: find.byType(Card));
        expect(cards, findsNWidgets(2));
        expect(tester.getSize(cards.at(0)), tester.getSize(cards.at(1)));
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
        expect(tester.getSize(cards.at(0)), tester.getSize(cards.at(1)));
        expect(find.text('1 of 3 workouts'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('renders active meal plan widget and progress section', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAppHarness(child: const Scaffold(body: HomeView())),
      );
      await tester.pump();

      expect(find.byType(ActiveMealPlanWidget), findsOneWidget);
      expect(find.byType(ProgressSection), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Workout History'), findsOneWidget);
      expect(find.text('Exercise History'), findsOneWidget);
      expect(find.text('Weight History'), findsOneWidget);
      expect(find.text('Plan History'), findsOneWidget);
    });
  });

  group('Main Navigation View', () {
    testWidgets(
      'current plan tab keeps its cached page without reloading on revisits',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(child: const MainNavigationView()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final cubit =
            tester
                    .element(find.byType(MainNavigationView))
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
        buildAppHarness(child: const MainNavigationView()),
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

      expect(find.byType(MacroTrackerView), findsOneWidget);
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
          child: const MainNavigationView(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(MacroTrackerView), findsNothing);
      await tester.tap(find.text('Macros'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(MacroTrackerView).hitTestable(), findsOneWidget);
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
            .widget<SegmentedButton<TrackerScope>>(
              find.byType(SegmentedButton<TrackerScope>),
            )
            .selected,
        {TrackerScope.week},
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Responsive Narrow and Scaled Layouts', () {
    testWidgets('MacroTrackerView renders narrow screen with large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildAppHarness(
          textScaler: const TextScaler.linear(2.0),
          child: const MacroTrackerView(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Macro Tracker'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FoodsView renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildAppHarness(child: const FoodsView()));
      await tester.pump();

      expect(find.textContaining('Foods'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RecipesView renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildAppHarness(child: const RecipesView()));
      await tester.pump();

      expect(find.textContaining('Recipes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StrengthGoalsView renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildAppHarness(child: const StrengthGoalsView()),
      );
      await tester.pump();

      expect(find.textContaining('Strength Goals'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MacroGoalsView renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildAppHarness(child: const MacroGoalsView()));
      await tester.pump();

      expect(find.textContaining('Macro Goals'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
