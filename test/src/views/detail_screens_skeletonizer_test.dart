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
import 'package:skeletonizer/skeletonizer.dart';

import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_set_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_set_exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/screens/loading_screen.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/workout_plan_detail_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_detail_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _TestWorkoutPlanCubit extends WorkoutPlanCubit {
  _TestWorkoutPlanCubit()
    : super(workoutPlanRepository: WorkoutPlanRepository.create());

  Completer<void>? pending;
  WorkoutPlanDto? nextPlan;
  ErrorState? nextError;

  @override
  Future<void> getWorkoutPlan(int id, {bool isRefresh = false}) async {
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));
    await pending?.future;
    if (isClosed) return;
    emit(
      state.copyWith(
        selectedWorkoutPlan: Nullable(nextPlan),
        isLoading: false,
        error: Nullable(nextError),
      ),
    );
  }
}

class _NoopWorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _NoopWorkoutPlanRecordCubit()
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );

  @override
  Future<void> getLatestActivePlanRecord() async {}
}

class _TestWorkoutCubit extends WorkoutCubit {
  _TestWorkoutCubit() : super(workoutRepository: WorkoutRepository.create());

  Completer<void>? pending;
  WorkoutDto? nextWorkout;
  ErrorState? nextError;

  @override
  Future<void> getWorkout(int id, {int? version, bool refresh = false}) async {
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));
    await pending?.future;
    if (isClosed) return;
    emit(
      state.copyWith(
        selectedWorkout: Nullable(nextWorkout),
        isLoading: false,
        error: Nullable(nextError),
      ),
    );
  }
}

GoRouter _routerFor(Widget child) {
  return GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, _) => child)],
  );
}

WorkoutPlanDto _samplePlan({int id = 1, String name = 'Upper Lower Split'}) {
  return WorkoutPlanDto(
    id: id,
    name: name,
    description: 'Four day hypertrophy split',
    currentVersion: 1,
    totalWeeks: 4,
    totalDays: 16,
    totalWorkouts: 16,
    difficulty: Difficulty.intermediate,
    isFavorite: false,
    createdBy: CreatedBy.user,
    weeks: const [],
  );
}

WorkoutDto _sampleWorkout({int id = 1, String name = 'Push Day'}) {
  return WorkoutDto(
    id: id,
    name: name,
    description: 'Chest, shoulders, and triceps',
    muscleGroups: const {MuscleGroup.push},
    muscles: const TargetMuscles(primary: {Muscle.chest}, secondary: {}),
    difficulty: Difficulty.intermediate,
    version: 1,
    isFavorite: false,
    totalSets: 3,
    totalReps: 30,
    editorType: EditorType.advanced,
    createdBy: CreatedBy.user,
    sets: const [
      WorkoutSetDto(
        id: 1,
        position: 1,
        setType: WorkoutSetType.standard,
        minSets: 3,
        recommendedRestSecs: 90,
        totalExercises: 1,
        totalReps: 30,
        exercises: [
          WorkoutSetExerciseDto(
            id: 11,
            position: 1,
            minReps: 8,
            maxReps: 12,
            exerciseId: 101,
            toMaxReps: false,
            exercise: ExerciseDto(
              id: 101,
              name: 'Bench Press',
              description: '',
              muscleGroup: MuscleGroup.push,
              muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
              createdBy: CreatedBy.system,
            ),
          ),
        ],
      ),
    ],
  );
}

void main() {
  group('WorkoutPlanDetailScreen Skeletonizer', () {
    Future<void> pumpPlanScreen(
      WidgetTester tester, {
      required _TestWorkoutPlanCubit cubit,
      int workoutPlanId = 1,
      double textScale = 1.0,
    }) async {
      final recordCubit = _NoopWorkoutPlanRecordCubit();
      final router = _routerFor(
        WorkoutPlanDetailScreen(workoutPlanId: workoutPlanId),
      );
      addTearDown(cubit.close);
      addTearDown(recordCubit.close);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<WorkoutPlanCubit>.value(value: cubit),
            BlocProvider<WorkoutPlanRecordCubit>.value(value: recordCubit),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'shows enabled Skeletonizer instead of LoadingScreen while loading, then renders loaded plan',
      (tester) async {
        final cubit = _TestWorkoutPlanCubit()
          ..pending = Completer<void>()
          ..nextPlan = _samplePlan();

        await pumpPlanScreen(tester, cubit: cubit);

        expect(find.byType(LoadingScreen), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.textContaining('Workout Plan details'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Skeletonizer &&
                widget.enabled &&
                widget.ignorePointers,
          ),
          findsOneWidget,
        );

        cubit.pending!.complete();
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Skeletonizer && !widget.enabled,
          ),
          findsOneWidget,
        );
        expect(find.textContaining('UPPER LOWER SPLIT'), findsOneWidget);
      },
    );

    testWidgets(
      'skeletonizes when switching to a different plan id while previous plan is in state',
      (tester) async {
        final cubit = _TestWorkoutPlanCubit()
          ..pending = Completer<void>()
          ..nextPlan = _samplePlan(id: 2, name: 'New Plan');
        cubit.emit(
          cubit.state.copyWith(
            selectedWorkoutPlan: Nullable(
              _samplePlan(id: 1, name: 'Stale Plan'),
            ),
          ),
        );

        await pumpPlanScreen(tester, cubit: cubit, workoutPlanId: 2);

        expect(find.textContaining('STALE PLAN'), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Skeletonizer && widget.enabled,
          ),
          findsOneWidget,
        );

        cubit.pending!.complete();
        await tester.pumpAndSettle();

        expect(find.textContaining('NEW PLAN'), findsOneWidget);
      },
    );

    testWidgets('renders Unknown Workout Plan when loading resolves to null', (
      tester,
    ) async {
      final cubit = _TestWorkoutPlanCubit()
        ..pending = Completer<void>()
        ..nextPlan = null
        ..nextError = const ErrorState(
          type: 'notFound',
          description: 'Workout plan not found',
        );

      await pumpPlanScreen(tester, cubit: cubit);
      cubit.pending!.complete();
      await tester.pumpAndSettle();

      expect(find.textContaining('Unknown Workout Plan'), findsOneWidget);
      expect(find.text('Workout plan not found'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'skeleton state fits mobile screens without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(540, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final cubit = _TestWorkoutPlanCubit()
          ..pending = Completer<void>()
          ..nextPlan = _samplePlan();

        await pumpPlanScreen(tester, cubit: cubit);
        await tester.pump(const Duration(milliseconds: 150));

        expect(tester.takeException(), isNull);

        cubit.pending!.complete();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('WorkoutDetailScreen Skeletonizer', () {
    Future<void> pumpWorkoutScreen(
      WidgetTester tester, {
      required _TestWorkoutCubit cubit,
      int workoutId = 1,
      double textScale = 1.0,
    }) async {
      final router = _routerFor(WorkoutDetailScreen(workoutId: workoutId));
      addTearDown(cubit.close);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutCubit>.value(
          value: cubit,
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'shows enabled Skeletonizer instead of LoadingScreen while loading, then renders loaded workout',
      (tester) async {
        final cubit = _TestWorkoutCubit()
          ..pending = Completer<void>()
          ..nextWorkout = _sampleWorkout();

        await pumpWorkoutScreen(tester, cubit: cubit);

        expect(find.byType(LoadingScreen), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.textContaining('Workout details'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Skeletonizer &&
                widget.enabled &&
                widget.ignorePointers,
          ),
          findsOneWidget,
        );

        cubit.pending!.complete();
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Skeletonizer && !widget.enabled,
          ),
          findsOneWidget,
        );
        expect(find.textContaining('PUSH DAY'), findsOneWidget);
        expect(find.text('Bench Press'), findsOneWidget);
      },
    );

    testWidgets(
      'skeletonizes when switching to a different workout id while previous workout is in state',
      (tester) async {
        final cubit = _TestWorkoutCubit()
          ..pending = Completer<void>()
          ..nextWorkout = _sampleWorkout(id: 2, name: 'Pull Day');
        cubit.emit(
          cubit.state.copyWith(
            selectedWorkout: Nullable(
              _sampleWorkout(id: 1, name: 'Stale Workout'),
            ),
          ),
        );

        await pumpWorkoutScreen(tester, cubit: cubit, workoutId: 2);

        expect(find.textContaining('STALE WORKOUT'), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Skeletonizer && widget.enabled,
          ),
          findsOneWidget,
        );

        cubit.pending!.complete();
        await tester.pumpAndSettle();

        expect(find.textContaining('PULL DAY'), findsOneWidget);
      },
    );

    testWidgets('renders Unknown Workout when loading resolves to null', (
      tester,
    ) async {
      final cubit = _TestWorkoutCubit()
        ..pending = Completer<void>()
        ..nextWorkout = null
        ..nextError = const ErrorState(
          type: 'notFound',
          description: 'Workout not found',
        );

      await pumpWorkoutScreen(tester, cubit: cubit);
      cubit.pending!.complete();
      await tester.pumpAndSettle();

      expect(find.textContaining('Unknown Workout'), findsOneWidget);
      expect(find.text('Workout not found'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'skeleton state fits narrow screens at 200% text scaling without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final cubit = _TestWorkoutCubit()
          ..pending = Completer<void>()
          ..nextWorkout = _sampleWorkout();

        await pumpWorkoutScreen(tester, cubit: cubit, textScale: 2.0);
        await tester.pump(const Duration(milliseconds: 150));

        expect(tester.takeException(), isNull);

        cubit.pending!.complete();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
