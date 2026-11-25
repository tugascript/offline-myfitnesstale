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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/active_workout_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/ui/foods/view_models/food_cubit.dart';
import 'package:myfitnesstale/src/ui/macros/view_models/macro_tracking_cubit.dart';
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
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
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
import 'package:myfitnesstale/src/ui/macros/utils/tracker_body_states.dart';
import 'package:myfitnesstale/src/ui/macros/view_models/states/macro_tracking_state.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/goals/macro_goal_form_modal.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_date_navigator.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_day_widget.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_month_widget.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_placeholder.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_scope_selection.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/tracker/macro_tracker_week_widget.dart';
import 'package:myfitnesstale/src/ui/recipes/screens/recipes_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/current_workout_plan_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/workout_plan_detail_screen.dart';
import 'package:myfitnesstale/src/ui/home/widgets/active/active_macro_goal_widget.dart';
import 'package:myfitnesstale/src/ui/home/widgets/active/active_plans_carousel.dart';
import 'package:myfitnesstale/src/ui/home/widgets/quick_actions_widget.dart';
import 'package:myfitnesstale/src/data/repositories/foods/food_repository.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/recipe_repository.dart';
import 'package:myfitnesstale/src/data/repositories/macros/dtos/macro_tracking_dto.dart';
import 'package:myfitnesstale/src/data/repositories/macros/inputs/week_macro_goal_input.dart';
import 'package:myfitnesstale/src/data/repositories/macros/macro_tracking_repository.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
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

const _sampleActiveMacroGoal = MacroGoalDto(
  id: 1,
  name: 'Daily Target',
  targetCalories: 2000,
  targetProtein: 150,
  targetCarbs: 215,
  targetFat: 60,
  targetWaterIntakeMl: 2500,
  isActive: true,
  phase: WeightGoalPhase.maintain,
);

class _TestMacroTrackingCubit extends MacroTrackingCubit {
  _TestMacroTrackingCubit({
    bool hasLoadedActiveGoal = false,
    MacroGoalDto? activeGoal,
    this.activeGoalCompleter,
    this.updateStateOnDailyLog = false,
    this.returnActiveGoalOnLoad = true,
    this.emitOnActiveGoalCall = false,
  }) : super(macroTrackingRepository: MacroTrackingRepository.create()) {
    if (hasLoadedActiveGoal || activeGoal != null) {
      emit(
        state.copyWith(
          hasLoadedActiveGoal: hasLoadedActiveGoal ? true : null,
          activeGoal: activeGoal != null ? Nullable(activeGoal) : null,
        ),
      );
    }
  }

  final Completer<void>? activeGoalCompleter;
  final bool updateStateOnDailyLog;
  final bool returnActiveGoalOnLoad;
  final bool emitOnActiveGoalCall;
  int activeGoalCalls = 0;
  int dailyLogCalls = 0;
  int rangeLogCalls = 0;
  DateTime? lastDailyLogDate;
  DateTime? lastWaterDate;
  final List<WeekMacroGoalInput> createdGoals = [];

  void beginActiveGoalLoad() {
    emit(state.copyWith(isLoading: true, isLoadingActiveGoal: true));
  }

  void completeActiveGoalLoad({bool? withGoal}) {
    final shouldSetGoal = withGoal ?? returnActiveGoalOnLoad;
    emit(
      state.copyWith(
        activeGoal: shouldSetGoal
            ? const Nullable(_sampleActiveMacroGoal)
            : const Nullable(null),
        isLoading: false,
        isLoadingActiveGoal: false,
        hasLoadedActiveGoal: true,
        error: const Nullable(null),
      ),
    );
  }

  void failActiveGoalLoad([String message = 'Goal failed']) {
    emit(
      state.copyWith(
        isLoading: false,
        isLoadingActiveGoal: false,
        hasLoadedActiveGoal: false,
        error: Nullable(
          ErrorState(type: 'operationFailure', description: message),
        ),
      ),
    );
  }

  void seedDailyLog(DateTime date, DailyNutritionLogDto log) {
    emit(state.copyWith(selectedDate: date, selectedDailyLog: Nullable(log)));
  }

  @override
  Future<void> getActiveMacroGoal() async {
    activeGoalCalls++;
    final completer = activeGoalCompleter;
    if (completer != null) {
      emit(state.copyWith(isLoading: true, isLoadingActiveGoal: true));
      await completer.future;
      if (!isClosed) {
        emit(
          state.copyWith(
            activeGoal: returnActiveGoalOnLoad
                ? const Nullable(_sampleActiveMacroGoal)
                : const Nullable(null),
            isLoading: false,
            isLoadingActiveGoal: false,
            hasLoadedActiveGoal: true,
            error: const Nullable(null),
          ),
        );
      }
      return;
    }
    if (emitOnActiveGoalCall && !isClosed) {
      emit(
        state.copyWith(
          activeGoal: returnActiveGoalOnLoad
              ? const Nullable(_sampleActiveMacroGoal)
              : const Nullable(null),
          isLoading: false,
          isLoadingActiveGoal: false,
          hasLoadedActiveGoal: true,
          error: const Nullable(null),
        ),
      );
    }
  }

  String? createGoalError;
  String? updateGoalError;
  String? completeGoalError;
  String? dailyLogError;

  @override
  Future<MacroGoalSaveStatus> createMacroGoal(WeekMacroGoalInput input) async {
    if (createGoalError != null) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            error: Nullable(
              ErrorState(
                type: 'operationFailure',
                description: createGoalError!,
              ),
            ),
          ),
        );
      }
      return MacroGoalSaveStatus.failed;
    }
    createdGoals.add(input);
    if (!isClosed) {
      emit(
        state.copyWith(
          activeGoal: Nullable(
            MacroGoalDto(
              id: createdGoals.length,
              name: input.name ?? 'Daily Target',
              targetCalories: input.targetCalories,
              targetProtein: input.targetProtein,
              targetCarbs: input.targetCarbs,
              targetFat: input.targetFat,
              targetWaterIntakeMl: input.targetWaterIntakeMl.value,
              goalType: input.goalType,
              isActive: input.isActive,
              phase: input.phase,
            ),
          ),
          hasLoadedActiveGoal: true,
          isLoadingActiveGoal: false,
          isLoading: false,
          error: const Nullable(null),
        ),
      );
    }
    return MacroGoalSaveStatus.saved;
  }

  @override
  Future<MacroGoalSaveStatus> updateMacroGoal(
    int id,
    WeekMacroGoalInput input,
  ) async {
    if (updateGoalError != null) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            error: Nullable(
              ErrorState(
                type: 'operationFailure',
                description: updateGoalError!,
              ),
            ),
          ),
        );
      }
      return MacroGoalSaveStatus.failed;
    }
    return MacroGoalSaveStatus.saved;
  }

  @override
  Future<bool> completeMacroGoal(int id) async {
    if (completeGoalError != null) {
      if (!isClosed) {
        // Mirrors real cubit: starts loading without clearing prior error.
        emit(state.copyWith(isLoading: true));
        emit(
          state.copyWith(
            isLoading: false,
            error: Nullable(
              ErrorState(
                type: 'operationFailure',
                description: completeGoalError!,
              ),
            ),
          ),
        );
      }
      return false;
    }
    return true;
  }

  @override
  Future<void> getMacroGoals({int limit = 20, int offset = 0}) async {
    if (!isClosed) {
      emit(state.copyWith(hasLoadedGoalHistory: true));
    }
  }

  @override
  Future<void> getDailyLog(DateTime date) async {
    dailyLogCalls++;
    lastDailyLogDate = date;
    if (dailyLogError != null && !isClosed) {
      // Mirrors real cubit: starts loading without clearing prior error.
      emit(state.copyWith(isLoading: true));
      emit(
        state.copyWith(
          isLoading: false,
          error: Nullable(
            ErrorState(type: 'operationFailure', description: dailyLogError!),
          ),
        ),
      );
      return;
    }
    if (updateStateOnDailyLog && !isClosed) {
      emit(
        state.copyWith(
          selectedDate: date,
          selectedDailyLog: Nullable(
            DailyNutritionLogDto(
              id: date.day,
              date: date.year * 10000 + date.month * 100 + date.day,
              waterIntakeMl: 0,
              totalCalories: 0,
              totalProtein: 0,
              totalCarbs: 0,
              totalFat: 0,
              totalFiber: 0,
            ),
          ),
          isLoading: false,
          error: const Nullable(null),
        ),
      );
    }
  }

  @override
  Future<void> getDailyLogsForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    rangeLogCalls++;
  }

  int waterUpdateCalls = 0;
  int? lastWaterIntakeMl;

  @override
  Future<bool> updateWaterIntake(int waterIntakeMl, {DateTime? date}) async {
    waterUpdateCalls++;
    lastWaterIntakeMl = waterIntakeMl;
    lastWaterDate = date ?? state.selectedDate;
    return true;
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

class _TestWorkoutPlanCubit extends WorkoutPlanCubit {
  _TestWorkoutPlanCubit({WorkoutPlanDto? selectedWorkoutPlan})
    : super(workoutPlanRepository: WorkoutPlanRepository.create()) {
    if (selectedWorkoutPlan != null) {
      emit(state.copyWith(selectedWorkoutPlan: Nullable(selectedWorkoutPlan)));
    }
  }

  @override
  Future<void> getWorkoutPlan(int id, {bool isRefresh = false}) async {}

  @override
  Future<bool> deleteWorkoutPlan(int id) async {
    if (!isClosed) {
      emit(
        state.copyWith(
          selectedWorkoutPlan: state.selectedWorkoutPlan?.id == id
              ? const Nullable(null)
              : null,
          isLoading: false,
          error: const Nullable(null),
        ),
      );
    }
    return true;
  }
}

class _TestWorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _TestWorkoutPlanRecordCubit({this.clearOnLoad = false, this.loadCompleter})
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );

  final bool clearOnLoad;
  final Completer<void>? loadCompleter;
  int loadCalls = 0;

  void showPlan({bool inProgress = false}) {
    emit(
      state.copyWith(
        hasLoadedActivePlan: true,
        currentPlanRecord: state.currentPlanRecord.copyWith(
          currentPlanRecord: inProgress
              ? Nullable(
                  WorkoutPlanRecordDto(
                    id: 1,
                    workoutPlanId: 1,
                    workoutPlanVersion: 1,
                    status: ProgressStatus.inProgress,
                    currentWeek: 1,
                    currentDay: 1,
                    currentWorkoutPosition: 1,
                    startedAt: DateTime(2026, 11, 20),
                  ),
                )
              : null,
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

  void invalidateActivePlan() {
    emit(state.copyWith(hasLoadedActivePlan: false));
  }

  @override
  Future<void> getLatestActivePlanRecord() async {
    loadCalls++;
    final completer = loadCompleter;
    if (completer != null) {
      await completer.future;
    }
    if (!isClosed) {
      emit(
        state.copyWith(
          hasLoadedActivePlan: true,
          isLoading: false,
          currentPlanRecord: clearOnLoad
              ? state.currentPlanRecord.copyWith(
                  currentPlanRecord: const Nullable(null),
                  workoutPlan: const Nullable(null),
                  todaysWorkouts: const [],
                  completedWorkouts: 0,
                  totalWorkouts: 0,
                )
              : null,
        ),
      );
    }
  }
}

void main() {
  Widget buildAppHarness({
    required Widget child,
    TextScaler? textScaler,
    MacroTrackingCubit? macroCubit,
    MacroGoalDto? activeMacroGoal,
  }) {
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
        if (macroCubit != null)
          BlocProvider<MacroTrackingCubit>.value(value: macroCubit)
        else
          BlocProvider<MacroTrackingCubit>(
            create: (_) => _TestMacroTrackingCubit(
              hasLoadedActiveGoal: activeMacroGoal != null,
              activeGoal: activeMacroGoal,
            ),
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
        expect(find.text('Active Macro Goal'), findsNothing);
        expect(find.text('Open Tracker'), findsNothing);
        await tester.drag(scroll, const Offset(-260, 0));
        await tester.pumpAndSettle();
        expect(find.text('No active macro goal').hitTestable(), findsOneWidget);
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
        expect(find.text('No active macro goal').hitTestable(), findsOneWidget);
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
    testWidgets('renders active macro goal widget without a history section', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAppHarness(child: const Scaffold(body: HomeScreen())),
      );
      await tester.pump();

      expect(find.byType(ActiveMacroGoalWidget), findsOneWidget);
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
        expect(cubit.loadCalls, initialLoads);
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
        expect(cubit.loadCalls, initialLoads);
      },
    );

    testWidgets('has Macros navigation tab instead of Meals', (tester) async {
      await tester.pumpWidget(
        buildAppHarness(child: const MainNavigationScreen()),
      );
      await tester.pump();

      // Verify bottom nav items
      final bottomNav = find.byType(BottomNavigationBar);
      final macrosTab = find.descendant(
        of: bottomNav,
        matching: find.text('Macros'),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Meals'), findsNothing);
      expect(macrosTab, findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Activity'), findsNothing);

      // Tap Tracker tab
      await tester.tap(macrosTab);
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
          activeMacroGoal: _sampleActiveMacroGoal,
          child: const MainNavigationScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final macrosTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Macros'),
      );
      expect(find.byType(MacroTrackerScreen).hitTestable(), findsNothing);
      await tester.tap(macrosTab);
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
      await tester.tap(macrosTab);
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

    testWidgets('MacroTrackerScreen reuses loaded active macro goal', (
      tester,
    ) async {
      final macroCubit = _TestMacroTrackingCubit(
        hasLoadedActiveGoal: true,
        activeGoal: _sampleActiveMacroGoal,
      );
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
      });

      await tester.pumpWidget(
        BlocProvider<MacroTrackingCubit>.value(
          value: macroCubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      expect(macroCubit.activeGoalCalls, 0);
      expect(macroCubit.dailyLogCalls, 1);
    });

    testWidgets(
      'MacroTrackerScreen waits for in-flight active goal load before fetching daily log',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit()..beginActiveGoalLoad();
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
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
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
      'MacroTrackerScreen awaits its own active macro goal load before fetching daily log',
      (tester) async {
        final activeGoalCompleter = Completer<void>();
        final macroCubit = _TestMacroTrackingCubit(
          activeGoalCompleter: activeGoalCompleter,
        );
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
          if (!activeGoalCompleter.isCompleted) {
            activeGoalCompleter.complete();
          }
          router.dispose();
          await macroCubit.close();
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        expect(macroCubit.activeGoalCalls, 1);
        expect(macroCubit.dailyLogCalls, 0);

        activeGoalCompleter.complete();
        await tester.pump();

        expect(macroCubit.activeGoalCalls, 1);
        expect(macroCubit.dailyLogCalls, 1);
      },
    );

    testWidgets(
      'MacroTrackerScreen activation reconciles daily log and range',
      (tester) async {
        final today = DateUtils.dateOnly(DateTime.now());
        final yesterday = DateTime(today.year, today.month, today.day - 1);

        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
          updateStateOnDailyLog: true,
        );
        final isVisible = ValueNotifier<bool>(false);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, _) =>
                    MacroTrackerScreen(isVisible: visible),
              ),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          isVisible.dispose();
          await macroCubit.close();
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        // Offscreen warm-up defers diary queries while hidden.
        expect(macroCubit.dailyLogCalls, 0);

        // Simulate another tracker route changing the shared cubit's date to yesterday.
        macroCubit.seedDailyLog(
          yesterday,
          DailyNutritionLogDto(
            id: 99,
            date:
                yesterday.year * 10000 + yesterday.month * 100 + yesterday.day,
            waterIntakeMl: 750,
            totalCalories: 500,
            totalProtein: 30,
            totalCarbs: 50,
            totalFat: 15,
            totalFiber: 5,
          ),
        );
        await tester.pump();

        // Activating the warmed-up Macros tab reconciles today's diary.
        isVisible.value = true;
        await tester.pumpAndSettle();

        expect(macroCubit.dailyLogCalls, 1);
        expect(DateUtils.isSameDay(macroCubit.lastDailyLogDate, today), isTrue);
        expect(
          DateUtils.isSameDay(macroCubit.state.selectedDate, today),
          isTrue,
        );

        // Switch to Week scope, deactivate, mutate shared date, then reactivate -> reconciles range too.
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();
        final rangeCallsBeforeDeactivate = macroCubit.rangeLogCalls;
        expect(rangeCallsBeforeDeactivate, 1);

        isVisible.value = false;
        await tester.pump();
        macroCubit.seedDailyLog(
          yesterday,
          DailyNutritionLogDto(
            id: 98,
            date:
                yesterday.year * 10000 + yesterday.month * 100 + yesterday.day,
            waterIntakeMl: 500,
            totalCalories: 300,
            totalProtein: 20,
            totalCarbs: 30,
            totalFat: 10,
            totalFiber: 3,
          ),
        );
        isVisible.value = true;
        await tester.pumpAndSettle();

        expect(macroCubit.dailyLogCalls, 2);
        expect(DateUtils.isSameDay(macroCubit.lastDailyLogDate, today), isTrue);
        expect(macroCubit.rangeLogCalls, rangeCallsBeforeDeactivate + 1);
      },
    );

    testWidgets(
      'MacroTrackerScreen serializes date and scope changes behind in-flight active goal load',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          activeGoal: _sampleActiveMacroGoal,
        )..beginActiveGoalLoad();
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
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        // Trigger date and scope changes while the initial active-goal load is still running.
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pump();
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();

        // Log queries must stay blocked until the in-flight active-goal request finishes.
        expect(macroCubit.activeGoalCalls, 0);
        expect(macroCubit.dailyLogCalls, 0);
        expect(macroCubit.rangeLogCalls, 0);

        // If the active-goal request fails, neither log query runs and the error is preserved.
        macroCubit.failActiveGoalLoad('Failed to load macro goal');
        await tester.pump();

        expect(macroCubit.activeGoalCalls, 0);
        expect(macroCubit.dailyLogCalls, 0);
        expect(macroCubit.rangeLogCalls, 0);
        expect(
          macroCubit.state.error?.description,
          'Failed to load macro goal',
        );

        // Once the active goal subsequently loads, deferred log and range queries reconcile.
        macroCubit.completeActiveGoalLoad();
        await tester.pump();

        expect(macroCubit.dailyLogCalls, 1);
        expect(macroCubit.rangeLogCalls, 1);
        final today = DateUtils.dateOnly(DateTime.now());
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        expect(
          DateUtils.isSameDay(macroCubit.lastDailyLogDate, yesterday),
          isTrue,
        );
      },
    );

    testWidgets(
      'MacroTrackerScreen food-logging FAB exposes Log Food accessible tooltip',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
        );
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
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        final fab = tester.widget<FloatingActionButton>(
          find.byKey(const ValueKey('macro-tracker-log-food-fab')),
        );
        expect(fab.tooltip, 'Log Food');
        expect(find.byTooltip('Log Food'), findsOneWidget);
      },
    );

    testWidgets(
      'MacroTrackerDayWidget disables water controls until loaded log matches selectedDate',
      (tester) async {
        final today = DateTime(2026, 11, 24);
        final yesterday = DateTime(2026, 11, 23);
        final macroCubit = _TestMacroTrackingCubit(hasLoadedActiveGoal: true);
        final theme = ThemeData.light();
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);
        addTearDown(() async {
          await macroCubit.close();
        });

        // Seed yesterday's log while displaying today.
        macroCubit.seedDailyLog(
          yesterday,
          const DailyNutritionLogDto(
            id: 1,
            date: 20261123,
            waterIntakeMl: 1250,
            totalCalories: 900,
            totalProtein: 70,
            totalCarbs: 90,
            totalFat: 25,
            totalFiber: 10,
          ),
        );

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp(
              home: Scaffold(
                body: MacroTrackerDayWidget(
                  theme: theme,
                  sizes: sizes,
                  selectedDate: today,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final waterCard = find.ancestor(
          of: find.byIcon(Icons.water_drop),
          matching: find.byType(Card),
        );
        final removeBtnFinder = find.descendant(
          of: waterCard,
          matching: find.ancestor(
            of: find.byIcon(Icons.remove),
            matching: find.byType(IconButton),
          ),
        );
        final addBtnFinder = find.descendant(
          of: waterCard,
          matching: find.ancestor(
            of: find.byIcon(Icons.add),
            matching: find.byType(IconButton),
          ),
        );
        expect(tester.widget<IconButton>(removeBtnFinder).onPressed, isNull);
        expect(tester.widget<IconButton>(addBtnFinder).onPressed, isNull);
        expect(find.text('Water: 0 / 2500 ml'), findsOneWidget);

        await tester.tap(addBtnFinder);
        await tester.tap(removeBtnFinder);
        await tester.pump();
        expect(macroCubit.waterUpdateCalls, 0);

        // Once today's log loads, controls enable and apply adjustments to today's intake.
        macroCubit.seedDailyLog(
          today,
          const DailyNutritionLogDto(
            id: 2,
            date: 20261124,
            waterIntakeMl: 500,
            totalCalories: 0,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0,
            totalFiber: 0,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.widget<IconButton>(removeBtnFinder).onPressed, isNotNull);
        expect(tester.widget<IconButton>(addBtnFinder).onPressed, isNotNull);
        expect(find.text('Water: 500 / 2500 ml'), findsOneWidget);

        await tester.tap(addBtnFinder);
        await tester.pump();
        expect(macroCubit.waterUpdateCalls, 1);
        expect(macroCubit.lastWaterIntakeMl, 750);
        expect(DateUtils.isSameDay(macroCubit.lastWaterDate, today), isTrue);
      },
    );

    testWidgets(
      'MacroTrackerScreen rebases untouched Today across midnight while preserving custom date',
      (tester) async {
        var fakeNow = DateTime(2026, 11, 24, 23, 55);
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
          updateStateOnDailyLog: true,
        );
        final isVisible = ValueNotifier<bool>(false);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, _) =>
                    MacroTrackerScreen(isVisible: visible, now: () => fakeNow),
              ),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          isVisible.dispose();
          await macroCubit.close();
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        // Offscreen warm-up before midnight defers diary queries until visible.
        expect(macroCubit.dailyLogCalls, 0);

        // Cross midnight and activate the warmed-up Macros tab -> untouched Today rebases to Nov 25.
        fakeNow = DateTime(2026, 11, 25, 0, 5);
        isVisible.value = true;
        await tester.pumpAndSettle();

        expect(macroCubit.dailyLogCalls, 1);
        expect(
          DateUtils.isSameDay(
            macroCubit.lastDailyLogDate,
            DateTime(2026, 11, 25),
          ),
          isTrue,
        );

        // Explicitly select yesterday (Nov 24), deactivate, cross midnight to Nov 26, and reactivate -> preserves Nov 24.
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
        expect(macroCubit.dailyLogCalls, 2);
        expect(
          DateUtils.isSameDay(
            macroCubit.lastDailyLogDate,
            DateTime(2026, 11, 24),
          ),
          isTrue,
        );

        isVisible.value = false;
        await tester.pump();
        fakeNow = DateTime(2026, 11, 26, 8, 0);
        isVisible.value = true;
        await tester.pumpAndSettle();

        // Still on custom date Nov 24 (log already matches Nov 24, so no rebased fetch to Nov 26).
        expect(macroCubit.dailyLogCalls, 2);
        expect(
          DateUtils.isSameDay(
            macroCubit.state.selectedDate,
            DateTime(2026, 11, 24),
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      'MacroTrackerScreen offscreen warm-up does not overwrite a visible route selected diary date',
      (tester) async {
        final today = DateUtils.dateOnly(DateTime.now());
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
          updateStateOnDailyLog: true,
        );
        macroCubit.seedDailyLog(
          yesterday,
          DailyNutritionLogDto(
            id: 55,
            date:
                yesterday.year * 10000 + yesterday.month * 100 + yesterday.day,
            waterIntakeMl: 1000,
            totalCalories: 700,
            totalProtein: 50,
            totalCarbs: 70,
            totalFat: 20,
            totalFiber: 8,
          ),
        );
        final isVisible = ValueNotifier<bool>(false);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, _) =>
                    MacroTrackerScreen(isVisible: visible),
              ),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          isVisible.dispose();
          await macroCubit.close();
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        // Hidden tab must not overwrite the visible route's yesterday diary.
        expect(macroCubit.dailyLogCalls, 0);
        expect(
          DateUtils.isSameDay(macroCubit.state.selectedDate, yesterday),
          isTrue,
        );

        // Once the tab becomes visible, it reconciles to today.
        isVisible.value = true;
        await tester.pumpAndSettle();

        expect(macroCubit.dailyLogCalls, 1);
        expect(DateUtils.isSameDay(macroCubit.lastDailyLogDate, today), isTrue);
        expect(
          DateUtils.isSameDay(macroCubit.state.selectedDate, today),
          isTrue,
        );
      },
    );

    testWidgets(
      'MacroTrackerScreen hidden tab does not request diary on failed active-goal recovery while log is null',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit()..failActiveGoalLoad();
        final isVisible = ValueNotifier<bool>(false);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, _) =>
                    MacroTrackerScreen(isVisible: visible),
              ),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          isVisible.dispose();
          await macroCubit.close();
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();
        expect(macroCubit.dailyLogCalls, 0);

        // Active goal recovers while hidden and selectedDailyLog is still null
        // (e.g., a visible /macro-tracker route is loading yesterday).
        macroCubit.completeActiveGoalLoad();
        await tester.pumpAndSettle();

        expect(macroCubit.dailyLogCalls, 0);

        // Once the hidden tab becomes visible, it loads its diary.
        isVisible.value = true;
        await tester.pumpAndSettle();
        expect(macroCubit.dailyLogCalls, 1);
      },
    );

    testWidgets(
      'CurrentWorkoutPlanScreen revalidates on activation after offscreen warm-up when active plan cache is invalidated',
      (tester) async {
        final recordCubit = _TestWorkoutPlanRecordCubit(clearOnLoad: true)
          ..showPlan(inProgress: true);
        final isVisible = ValueNotifier<bool>(false);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, _) =>
                    CurrentWorkoutPlanScreen(isVisible: visible),
              ),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          isVisible.dispose();
          await recordCubit.close();
        });

        await tester.pumpWidget(
          BlocProvider<WorkoutPlanRecordCubit>.value(
            value: recordCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();
        expect(recordCubit.loadCalls, 0);

        // Invalidate cache (e.g., active plan was deleted while Plan tab was offscreen).
        recordCubit.invalidateActivePlan();
        await tester.pump();

        // First visible visit must refresh instead of displaying the stale deleted plan.
        isVisible.value = true;
        await tester.pumpAndSettle();

        expect(recordCubit.loadCalls, 1);
        expect(find.text('A workout plan with a longer title'), findsNothing);
      },
    );

    testWidgets(
      'MacroTrackerScreen skips pending period and range continuations if tab hides while awaiting active goal',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          activeGoal: _sampleActiveMacroGoal,
          updateStateOnDailyLog: true,
        )..beginActiveGoalLoad();
        final isVisible = ValueNotifier<bool>(true);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, _) =>
                    MacroTrackerScreen(isVisible: visible),
              ),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          isVisible.dispose();
          await macroCubit.close();
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        // Trigger a date change (_loadPeriodData) while active goal is in flight.
        await tester.tap(find.byKey(const ValueKey('macro-tracker-prev-btn')));
        await tester.pump();
        expect(macroCubit.dailyLogCalls, 0);

        // Leave the Macros tab before the active goal finishes loading.
        isVisible.value = false;
        await tester.pump();

        macroCubit.completeActiveGoalLoad();
        await tester.pumpAndSettle();

        expect(macroCubit.dailyLogCalls, 0);
        expect(macroCubit.rangeLogCalls, 0);

        // Return to the Macros tab -> reconciles the deferred daily log load.
        isVisible.value = true;
        await tester.pumpAndSettle();
        expect(macroCubit.dailyLogCalls, 1);
        expect(macroCubit.rangeLogCalls, 0);

        // Trigger a scope change to Week (_loadRangeForCurrentScope) while a new
        // active-goal load is in flight, then leave the tab before it finishes.
        macroCubit.beginActiveGoalLoad();
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();
        expect(macroCubit.rangeLogCalls, 0);

        isVisible.value = false;
        await tester.pump();

        macroCubit.completeActiveGoalLoad();
        await tester.pumpAndSettle();

        expect(macroCubit.rangeLogCalls, 0);

        // Returning to the Macros tab reconciles the deferred Week range load.
        isVisible.value = true;
        await tester.pumpAndSettle();
        expect(macroCubit.rangeLogCalls, 1);
      },
    );

    testWidgets(
      'MacroTrackerScreen reloads daily log on activation when cached log date disagrees with selectedDate',
      (tester) async {
        final today = DateUtils.dateOnly(DateTime.now());
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
          updateStateOnDailyLog: true,
        );
        // Simulate a late water-update response replacing selectedDailyLog with
        // yesterday's log while selectedDate remains today.
        macroCubit.seedDailyLog(
          today,
          DailyNutritionLogDto(
            id: 77,
            date:
                yesterday.year * 10000 + yesterday.month * 100 + yesterday.day,
            waterIntakeMl: 500,
            totalCalories: 400,
            totalProtein: 30,
            totalCarbs: 40,
            totalFat: 10,
            totalFiber: 5,
          ),
        );
        final isVisible = ValueNotifier<bool>(false);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, _) =>
                    MacroTrackerScreen(isVisible: visible),
              ),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          isVisible.dispose();
          await macroCubit.close();
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();
        expect(macroCubit.dailyLogCalls, 0);

        isVisible.value = true;
        await tester.pumpAndSettle();

        expect(macroCubit.dailyLogCalls, 1);
        expect(DateUtils.isSameDay(macroCubit.lastDailyLogDate, today), isTrue);
        expect(
          macroCubit.state.selectedDailyLog?.date,
          today.year * 10000 + today.month * 100 + today.day,
        );
      },
    );

    testWidgets(
      'MacroTrackerScreen reloads daily log on goal recovery when cached log date disagrees with selectedDate',
      (tester) async {
        final today = DateUtils.dateOnly(DateTime.now());
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        final macroCubit = _TestMacroTrackingCubit(updateStateOnDailyLog: true)
          ..failActiveGoalLoad();
        macroCubit.seedDailyLog(
          today,
          DailyNutritionLogDto(
            id: 78,
            date:
                yesterday.year * 10000 + yesterday.month * 100 + yesterday.day,
            waterIntakeMl: 500,
            totalCalories: 400,
            totalProtein: 30,
            totalCarbs: 40,
            totalFat: 10,
            totalFiber: 5,
          ),
        );
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
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();
        expect(macroCubit.dailyLogCalls, 0);

        macroCubit.completeActiveGoalLoad();
        await tester.pumpAndSettle();

        expect(macroCubit.dailyLogCalls, 1);
        expect(DateUtils.isSameDay(macroCubit.lastDailyLogDate, today), isTrue);
        expect(
          macroCubit.state.selectedDailyLog?.date,
          today.year * 10000 + today.month * 100 + today.day,
        );
      },
    );

    testWidgets(
      'WorkoutPlanDetailScreen pops cleanly via State context when deleting plan disposes inner record builder',
      (tester) async {
        const activePlan = WorkoutPlanDto(
          id: 1,
          name: 'Deletable Active Workout Plan',
          currentVersion: 1,
          totalWeeks: 1,
          totalDays: 7,
          totalWorkouts: 3,
          difficulty: Difficulty.beginner,
          isFavorite: false,
          createdBy: CreatedBy.user,
        );
        final refreshCompleter = Completer<void>();
        final workoutPlanCubit = _TestWorkoutPlanCubit(
          selectedWorkoutPlan: activePlan,
        );
        final workoutPlanRecordCubit = _TestWorkoutPlanRecordCubit(
          clearOnLoad: true,
          loadCompleter: refreshCompleter,
        )..showPlan(inProgress: true);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => context.push('/workout-plans/1'),
                  child: const Text('Open Plan Details'),
                ),
              ),
            ),
            GoRoute(
              path: '/workout-plans/1',
              builder: (context, state) =>
                  const WorkoutPlanDetailScreen(workoutPlanId: 1),
            ),
          ],
        );
        addTearDown(() async {
          if (!refreshCompleter.isCompleted) {
            refreshCompleter.complete();
          }
          router.dispose();
          await workoutPlanCubit.close();
          await workoutPlanRecordCubit.close();
        });

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WorkoutPlanCubit>.value(value: workoutPlanCubit),
              BlocProvider<WorkoutPlanRecordCubit>.value(
                value: workoutPlanRecordCubit,
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Plan Details'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('DELETABLE ACTIVE WORKOUT PLAN'),
          findsOneWidget,
        );

        final deleteButton = find.text('DELETE');
        await tester.ensureVisible(deleteButton);
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        await tester.tap(find.text('CONFIRM'));
        // Allow deleteWorkoutPlan to clear selectedWorkoutPlan and rebuild the
        // screen into the fallback branch (disposing the nested BlocBuilder
        // context) while handleDeletedWorkoutPlan is still awaiting refresh.
        await tester.pump();
        await tester.pump();
        expect(find.text('Workout plan not found'), findsOneWidget);

        refreshCompleter.complete();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Open Plan Details'), findsOneWidget);
        expect(workoutPlanRecordCubit.loadCalls, 1);
      },
    );

    testWidgets(
      'MacroTrackerScopeSelection buttons meet accessible minimum tap target height',
      (tester) async {
        for (final screenSize in [ScreenSize.xs, ScreenSize.md]) {
          final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MacroTrackerScopeSelection(
                  sizes: sizes,
                  theme: ThemeData.light(),
                  scope: TrackerScope.day,
                  onScopeChanged: (_) {},
                  onGoToToday: () {},
                ),
              ),
            ),
          );
          await tester.pump();

          for (final label in ['Day', 'Week', 'Month']) {
            final inkWell = find.ancestor(
              of: find.text(label),
              matching: find.byType(InkWell),
            );
            expect(tester.getSize(inkWell).height, greaterThanOrEqualTo(48.0));
          }
        }
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
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
        );
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
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
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
      'MacroTrackerScreen keeps scope synced when manual swipe interrupts programmatic change',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
        );
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
        });

        await tester.pumpWidget(
          BlocProvider<MacroTrackingCubit>.value(
            value: macroCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        TrackerScope currentScope() => tester
            .widget<MacroTrackerScopeSelection>(
              find.byType(MacroTrackerScopeSelection),
            )
            .scope;

        // Start programmatic animation Day -> Month, then interrupt with a manual swipe back to Day.
        await tester.tap(find.text('Month'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.drag(
          find.byKey(const ValueKey('macro-tracker-scope-pager')),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        expect(currentScope(), TrackerScope.day);
        expect(find.byType(MacroTrackerDayWidget), findsOneWidget);
        expect(macroCubit.rangeLogCalls, 0);

        // Start programmatic animation Day -> Month, then rapidly retarget back to Day mid-animation.
        await tester.tap(find.text('Month'));
        await tester.pump(const Duration(milliseconds: 80));
        await tester.tap(find.text('Day'));
        await tester.pumpAndSettle();

        expect(currentScope(), TrackerScope.day);
        expect(find.byType(MacroTrackerDayWidget), findsOneWidget);
        expect(macroCubit.rangeLogCalls, 0);
      },
    );

    testWidgets(
      'MacroTrackerScreen disables next chevron when next period is past today',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(
            activeMacroGoal: _sampleActiveMacroGoal,
            child: const MacroTrackerScreen(),
          ),
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
          buildAppHarness(
            activeMacroGoal: _sampleActiveMacroGoal,
            child: const MacroTrackerScreen(),
          ),
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

    testWidgets(
      'MainNavigationScreen Macros tab without active goal shows placeholder and auto-opens 2000 kcal modal',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          emitOnActiveGoalCall: true,
          returnActiveGoalOnLoad: false,
        );
        addTearDown(macroCubit.close);

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MainNavigationScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Offscreen warm-up does not open the modal while on Home.
        expect(find.byType(MacroGoalFormModal), findsNothing);

        final macrosTab = find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Macros'),
        );
        await tester.tap(macrosTab);
        await tester.pumpAndSettle();

        expect(find.byType(MacroGoalFormModal), findsOneWidget);
        expect(find.text('Create Macro Goal'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('macro-goal-recommended-note')),
          findsOneWidget,
        );
        expect(find.textContaining('2000 kcal'), findsWidgets);

        Finder goalField(String name) => find.descendant(
          of: find.byKey(ValueKey('macro-goal-$name-input')),
          matching: find.byType(TextFormField),
        );
        expect(
          tester.widget<TextFormField>(goalField('calories')).controller?.text,
          '2000',
        );
        expect(
          tester.widget<TextFormField>(goalField('protein')).controller?.text,
          '150',
        );
        expect(
          tester.widget<TextFormField>(goalField('carbs')).controller?.text,
          '215',
        );
        expect(
          tester.widget<TextFormField>(goalField('fat')).controller?.text,
          '60',
        );
        expect(
          tester.widget<TextFormField>(goalField('water')).controller?.text,
          '2500',
        );

        expect(find.byType(MacroTrackerPlaceholder), findsOneWidget);
        expect(
          find.byKey(const ValueKey('macro-tracker-log-food-fab')),
          findsNothing,
        );
        expect(macroCubit.dailyLogCalls, 0);
      },
    );

    testWidgets(
      'MainNavigationScreen Macros tab modal dismissal keeps placeholder and reopens via button or tab re-tap',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          returnActiveGoalOnLoad: false,
        );
        addTearDown(macroCubit.close);

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MainNavigationScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final macrosTab = find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Macros'),
        );
        await tester.tap(macrosTab);
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);

        // Dismiss via close button: placeholder stays visible without looping.
        await tester.tap(
          find.byKey(const ValueKey('macro-goal-modal-close-btn')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MacroGoalFormModal), findsNothing);
        expect(find.text('No Active Macro Goal'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('macro-tracker-set-goal-btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('macro-tracker-log-food-fab')),
          findsNothing,
        );

        // Reopen via placeholder button with 2000 kcal recommended defaults.
        await tester.tap(
          find.byKey(const ValueKey('macro-tracker-set-goal-btn')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);
        expect(
          find.byKey(const ValueKey('macro-goal-recommended-note')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('macro-goal-modal-close-btn')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsNothing);

        // Re-tapping Macros bottom nav item while already on Macros tab reopens modal.
        await tester.tap(macrosTab);
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);
      },
    );

    testWidgets(
      'MainNavigationScreen Macros tab modal submission creates 2000 kcal goal and transitions to tracker',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          returnActiveGoalOnLoad: false,
          updateStateOnDailyLog: true,
        );
        addTearDown(macroCubit.close);

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MainNavigationScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final macrosTab = find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Macros'),
        );
        await tester.tap(macrosTab);
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);

        final createButton = find.byKey(
          const ValueKey('macro-goal-submit-button'),
        );
        await tester.ensureVisible(createButton);
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.byType(MacroGoalFormModal), findsNothing);
        expect(macroCubit.createdGoals, hasLength(1));
        final createdDay = macroCubit.createdGoals.single.days.single;
        expect(createdDay.targetCalories, 2000);
        expect(createdDay.targetProtein, 150);
        expect(createdDay.targetCarbs, 215);
        expect(createdDay.targetFat, 60);
        expect(createdDay.targetWaterIntakeMl.value, 2500);

        expect(find.byType(MacroTrackerPlaceholder), findsNothing);
        expect(
          find.byKey(const ValueKey('macro-tracker-log-food-fab')),
          findsOneWidget,
        );
        expect(find.byType(MacroTrackerDayWidget), findsOneWidget);
        expect(macroCubit.dailyLogCalls, 1);
      },
    );

    testWidgets(
      'MainNavigationScreen switching away from Macros before in-flight active goal completes does not pop modal',
      (tester) async {
        final goalCompleter = Completer<void>();
        final macroCubit = _TestMacroTrackingCubit(
          activeGoalCompleter: goalCompleter,
          returnActiveGoalOnLoad: false,
        );
        addTearDown(() async {
          if (!goalCompleter.isCompleted) {
            goalCompleter.complete();
          }
          await macroCubit.close();
        });

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MainNavigationScreen(),
          ),
        );
        await tester.pump();

        final bottomNav = find.byType(BottomNavigationBar);
        await tester.tap(
          find.descendant(of: bottomNav, matching: find.text('Macros')),
        );
        await tester.pump();
        expect(find.byType(MacroGoalFormModal), findsNothing);
        expect(
          find.descendant(
            of: find.byType(MacroTrackerScreen),
            matching: find.byWidgetPredicate(
              (w) => w is Skeletonizer && w.enabled && w.ignorePointers,
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MacroTrackerScreen),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsNothing,
        );

        // Leave Macros tab before active goal query finishes.
        await tester.tap(
          find.descendant(of: bottomNav, matching: find.text('Home')),
        );
        await tester.pump();

        goalCompleter.complete();
        await tester.pumpAndSettle();

        // Modal must not pop up over Home.
        expect(find.byType(MacroGoalFormModal), findsNothing);
      },
    );

    testWidgets(
      'leaving MacroTrackerScreen during in-flight active-goal load does not consume goalPromptTrigger',
      (tester) async {
        final goalCompleter = Completer<void>();
        final macroCubit = _TestMacroTrackingCubit(
          activeGoalCompleter: goalCompleter,
          returnActiveGoalOnLoad: false,
        );
        addTearDown(() async {
          if (!goalCompleter.isCompleted) {
            goalCompleter.complete();
          }
          await macroCubit.close();
        });

        var isVisible = true;
        const trigger = 1;
        late StateSetter setHostState;

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: StatefulBuilder(
              builder: (context, setState) {
                setHostState = setState;
                return MacroTrackerScreen(
                  isVisible: isVisible,
                  goalPromptTrigger: trigger,
                );
              },
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(MacroGoalFormModal), findsNothing);

        // Hide screen while active-goal load is still in flight.
        setHostState(() => isVisible = false);
        await tester.pump();

        // Active-goal load finishes while hidden: modal must not open.
        goalCompleter.complete();
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsNothing);

        // Returning with the same trigger should still open the modal once.
        setHostState(() => isVisible = true);
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);

        // Dismissing consumes the trigger so toggling visibility does not reopen.
        await tester.tap(
          find.byKey(const ValueKey('macro-goal-modal-close-btn')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsNothing);

        setHostState(() => isVisible = false);
        await tester.pump();
        setHostState(() => isVisible = true);
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsNothing);
      },
    );

    testWidgets(
      'MacroTrackerScreen does not show duplicate SnackBar when MacroGoalFormModal submit fails',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          returnActiveGoalOnLoad: false,
        )..createGoalError = 'Failed to persist goal';
        addTearDown(macroCubit.close);

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MacroTrackerScreen(goalPromptTrigger: 1),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);

        final submit = find.byKey(const ValueKey('macro-goal-submit-button'));
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();

        expect(find.byType(MacroGoalFormModal), findsOneWidget);
        expect(
          find.byKey(const ValueKey('macro-goal-submit-error')),
          findsOneWidget,
        );
        expect(find.text('Failed to persist goal'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'MacroTrackerScreen opens pending goal prompt once unrelated cubit loading finishes',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          returnActiveGoalOnLoad: false,
        );
        addTearDown(macroCubit.close);

        // Simulate an unrelated cubit call (e.g. getMacroGoals) in flight.
        macroCubit.emit(macroCubit.state.copyWith(isLoading: true));

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MacroTrackerScreen(goalPromptTrigger: 1),
          ),
        );
        await tester.pump();
        expect(find.byType(MacroGoalFormModal), findsNothing);
        final setGoalButton = tester.widget<TextButton>(
          find.descendant(
            of: find.byKey(const ValueKey('macro-tracker-set-goal-btn')),
            matching: find.byType(TextButton),
          ),
        );
        expect(setGoalButton.onPressed, isNotNull);

        // Once the unrelated call completes, the pending prompt should open.
        macroCubit.emit(macroCubit.state.copyWith(isLoading: false));
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);
      },
    );

    testWidgets(
      'MacroGoalsScreen suppresses duplicate SnackBar when MacroGoalFormModal fails on create or edit',
      (tester) async {
        final macroCubit =
            _TestMacroTrackingCubit(
                hasLoadedActiveGoal: true,
                activeGoal: _sampleActiveMacroGoal,
              )
              ..createGoalError = 'Create failed'
              ..updateGoalError = 'Update failed';
        addTearDown(macroCubit.close);

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MacroGoalsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Open edit modal from ActiveMacroGoal and submit a failing update.
        await tester.tap(find.byKey(const ValueKey('macro-goal-edit-btn')));
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);

        final submit = find.byKey(const ValueKey('macro-goal-submit-button'));
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();

        expect(find.byType(MacroGoalFormModal), findsOneWidget);
        expect(find.text('Update failed'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);

        // Close edit modal, then open create modal from FAB and submit a failing create.
        await tester.tap(
          find.byKey(const ValueKey('macro-goal-modal-close-btn')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsNothing);

        await tester.tap(find.byKey(const ValueKey('macro-goal-add-fab')));
        await tester.pumpAndSettle();
        expect(find.byType(MacroGoalFormModal), findsOneWidget);

        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();

        expect(find.byType(MacroGoalFormModal), findsOneWidget);
        expect(find.text('Create failed'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);

        // Close modal and emit a non-modal error -> SnackBar still appears.
        await tester.tap(
          find.byKey(const ValueKey('macro-goal-modal-close-btn')),
        );
        await tester.pumpAndSettle();

        macroCubit.emit(
          macroCubit.state.copyWith(
            isLoading: false,
            error: const Nullable(
              ErrorState(
                type: 'operationFailure',
                description: 'Delete failed',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Delete failed'), findsOneWidget);
      },
    );

    test('TrackerBodyStates.fromState stays in waitingForGoal until active goal load completes or fails', () {
      final unloadedIdle = MacroTrackingState.initial();
      expect(
        TrackerBodyStates.fromState(unloadedIdle),
        TrackerBodyStates.waitingForGoal,
      );

      final unloadedLoading = unloadedIdle.copyWith(
        isLoading: true,
        isLoadingActiveGoal: true,
      );
      expect(
        TrackerBodyStates.fromState(unloadedLoading),
        TrackerBodyStates.waitingForGoal,
      );

      final unloadedError = unloadedIdle.copyWith(
        error: const Nullable(
          ErrorState(type: 'operationFailure', description: 'Load failed'),
        ),
      );
      expect(
        TrackerBodyStates.fromState(unloadedError),
        TrackerBodyStates.initialGoalError,
      );

      final loadedNoGoal = unloadedIdle.copyWith(hasLoadedActiveGoal: true);
      expect(
        TrackerBodyStates.fromState(loadedNoGoal),
        TrackerBodyStates.noGoal,
      );

      final loadedWithGoal = loadedNoGoal.copyWith(
        activeGoal: const Nullable(_sampleActiveMacroGoal),
      );
      expect(
        TrackerBodyStates.fromState(loadedWithGoal),
        TrackerBodyStates.activeGoal,
      );
    });

    testWidgets(
      'MacroGoalsScreen reports repeated identical failure when retrying Deactivate',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
        )..completeGoalError = 'Deactivate failed';
        addTearDown(macroCubit.close);

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MacroGoalsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final deactivateBtn = find.byKey(
          const ValueKey('macro-goal-deactivate-btn'),
        );
        await tester.tap(deactivateBtn);
        await tester.pumpAndSettle();
        expect(find.text('Deactivate failed'), findsOneWidget);

        // Dismiss the first SnackBar and retry with the same error.
        ScaffoldMessenger.of(tester.element(find.byType(MacroGoalsScreen)))
            .hideCurrentSnackBar();
        await tester.pumpAndSettle();
        expect(find.text('Deactivate failed'), findsNothing);

        await tester.tap(deactivateBtn);
        await tester.pumpAndSettle();
        expect(find.text('Deactivate failed'), findsOneWidget);
      },
    );

    testWidgets(
      'MacroTrackerScreen reports repeated identical failure on retried diary load',
      (tester) async {
        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          activeGoal: _sampleActiveMacroGoal,
        )..dailyLogError = 'Diary load failed';
        addTearDown(macroCubit.close);

        await tester.pumpWidget(
          buildAppHarness(
            macroCubit: macroCubit,
            child: const MacroTrackerScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Diary load failed'), findsOneWidget);

        ScaffoldMessenger.of(tester.element(find.byType(MacroTrackerScreen)))
            .hideCurrentSnackBar();
        await tester.pumpAndSettle();
        expect(find.text('Diary load failed'), findsNothing);

        // Navigate to previous day -> triggers another getDailyLog with same error.
        await tester.tap(find.byKey(const ValueKey('macro-tracker-prev-btn')));
        await tester.pumpAndSettle();
        expect(find.text('Diary load failed'), findsOneWidget);
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
          activeMacroGoal: _sampleActiveMacroGoal,
          child: const MacroTrackerScreen(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Macro Tracker'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'MacroTrackerPlaceholder renders narrow screen with large text',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.reset);

        final macroCubit = _TestMacroTrackingCubit(
          hasLoadedActiveGoal: true,
          returnActiveGoalOnLoad: false,
        );
        addTearDown(macroCubit.close);

        await tester.pumpWidget(
          buildAppHarness(
            textScaler: const TextScaler.linear(2.0),
            macroCubit: macroCubit,
            child: const MacroTrackerScreen(),
          ),
        );
        await tester.pump();

        expect(find.text('No Active Macro Goal'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('macro-tracker-set-goal-btn')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

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
