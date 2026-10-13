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
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/views/exercises/strength_goals_view.dart';
import 'package:myfitnesstale/src/views/foods/foods_view.dart';
import 'package:myfitnesstale/src/views/home/home_view.dart';
import 'package:myfitnesstale/src/views/home/main_navigation_view.dart';
import 'package:myfitnesstale/src/views/macro_goals/macro_goals_view.dart';
import 'package:myfitnesstale/src/views/macros/macro_tracker_view.dart';
import 'package:myfitnesstale/src/views/meal_plans/meal_plan_list_view.dart';
import 'package:myfitnesstale/src/views/recipes/recipes_view.dart';
import 'package:myfitnesstale/src/widgets/dashboard/active_meal_plan_widget.dart';
import 'package:myfitnesstale/src/widgets/dashboard/progress_section.dart';
import 'package:myfitnesstale/src/widgets/dashboard/quick_actions_widget.dart';

class _TestProfileCubit extends ProfileCubit {
  _TestProfileCubit() {
    emit(ProfileState(
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
    ));
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
  @override
  Future<void> getLatestActivePlanRecord() async {}
}

void main() {
  Widget buildAppHarness({
    required Widget child,
    TextScaler? textScaler,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(create: (_) => _TestProfileCubit()),
        BlocProvider<EntitlementCubit>(create: (_) => EntitlementCubit()),
        BlocProvider<ExerciseCubit>(create: (_) => ExerciseCubit()),
        BlocProvider<ExerciseRecordCubit>(
            create: (_) => _TestExerciseRecordCubit()),
        BlocProvider<WeightRecordCubit>(create: (_) => WeightRecordCubit()),
        BlocProvider<WorkoutCubit>(create: (_) => WorkoutCubit()),
        BlocProvider<WorkoutRecordCubit>(create: (_) => WorkoutRecordCubit()),
        BlocProvider<WorkoutPlanCubit>(create: (_) => WorkoutPlanCubit()),
        BlocProvider<WorkoutPlanRecordCubit>(
            create: (_) => _TestWorkoutPlanRecordCubit()),
        BlocProvider<ActiveWorkoutCubit>(create: (_) => ActiveWorkoutCubit()),
        BlocProvider<FoodCubit>(create: (_) => _TestFoodCubit()),
        BlocProvider<RecipeCubit>(create: (_) => _TestRecipeCubit()),
        BlocProvider<MacroTrackingCubit>(
            create: (_) => _TestMacroTrackingCubit()),
        BlocProvider<MealPlanCubit>(create: (_) => _TestMealPlanCubit()),
        BlocProvider<MealPlanRecordCubit>(
            create: (_) => _TestMealPlanRecordCubit()),
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
    testWidgets('renders all quick action buttons including macro items',
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

      expect(find.byKey(const ValueKey('quick-action-strength-goals')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('quick-action-food')), findsOneWidget);
      expect(find.byKey(const ValueKey('quick-action-recipe')), findsOneWidget);
      expect(find.byKey(const ValueKey('quick-action-macro-goals')),
          findsOneWidget);
    });
  });

  group('Home Page Sections', () {
    testWidgets('renders active meal plan widget and progress section',
        (tester) async {
      await tester.pumpWidget(
        buildAppHarness(
          child: const Scaffold(
            body: HomeView(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ActiveMealPlanWidget), findsOneWidget);
      expect(find.byType(ProgressSection), findsOneWidget);
      expect(find.text('Progress & Activity'), findsOneWidget);
      expect(find.text('Workout History'), findsOneWidget);
      expect(find.text('Exercise Progress'), findsOneWidget);
      expect(find.text('Weight History'), findsOneWidget);
      expect(find.text('Plan History'), findsOneWidget);
    });
  });

  group('Main Navigation View', () {
    testWidgets('has Meals navigation tab instead of Activity', (tester) async {
      await tester.pumpWidget(
        buildAppHarness(
          child: const MainNavigationView(),
        ),
      );
      await tester.pump();

      // Verify bottom nav items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Plans'), findsOneWidget);
      expect(find.text('Meals'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Activity'), findsNothing);

      // Tap Meals tab
      await tester.tap(find.text('Meals'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MealPlanListView), findsOneWidget);
    });
  });

  group('Responsive Narrow and Scaled Layouts', () {
    testWidgets('MacroTrackerView renders narrow screen with large text',
        (tester) async {
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

      await tester.pumpWidget(
        buildAppHarness(
          child: const FoodsView(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Foods'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RecipesView renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildAppHarness(
          child: const RecipesView(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Recipes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StrengthGoalsView renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildAppHarness(
          child: const StrengthGoalsView(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Strength Goals'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MacroGoalsView renders narrow screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildAppHarness(
          child: const MacroGoalsView(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Macro Goals'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
