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

import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/workout_plans_list_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/states/workout_plan_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/workout_plan_card.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/workout_plans_list.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workouts_list_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/states/workout_state.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/workout_card.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/workouts_list.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _TestWorkoutPlanCubit extends WorkoutPlanCubit {
  _TestWorkoutPlanCubit()
    : super(workoutPlanRepository: WorkoutPlanRepository.create());

  Completer<void>? pending;
  List<WorkoutPlanDto> nextPlans = const [];
  int nextTotal = 0;

  void publish(WorkoutPlanState nextState) => emit(nextState);

  @override
  Future<void> getWorkoutPlans({
    String? name,
    Difficulty? difficulty,
    bool isFavorite = false,
    CreatedBy? createdBy,
    int? limit,
    int? offset,
  }) async {
    emit(
      state.copyWith(
        pendingWorkoutPlansQuery: Nullable(
          WorkoutPlanPagination(
            name: name ?? '',
            difficulty: difficulty,
            isFavorite: isFavorite,
            createdBy: createdBy,
            limit: limit ?? state.pagination.limit,
            offset: offset ?? 0,
            total: state.pagination.total,
          ),
        ),
      ),
    );
    await pending?.future;
    if (isClosed) return;
    emit(
      state.copyWith(
        workoutPlans: nextPlans,
        pagination: state.pagination.copyWith(
          total: nextTotal,
          offset: offset ?? 0,
        ),
        pendingWorkoutPlansQuery: const Nullable(null),
      ),
    );
  }
}

class _TestWorkoutCubit extends WorkoutCubit {
  _TestWorkoutCubit() : super(workoutRepository: WorkoutRepository.create());

  Completer<void>? pending;
  List<WorkoutDto> nextWorkouts = const [];
  int nextTotal = 0;

  void publish(WorkoutState nextState) => emit(nextState);

  @override
  Future<void> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    int? limit,
    int? offset,
    bool isFavorite = false,
    CreatedBy? createdBy,
  }) async {
    emit(
      state.copyWith(
        pendingWorkoutsQuery: Nullable(
          WorkoutPagination(
            name: name ?? '',
            difficulty: difficulty,
            muscleGroup: muscleGroup,
            isFavorite: isFavorite,
            createdBy: createdBy,
            limit: limit ?? state.pagination.limit,
            offset: offset ?? 0,
            total: state.pagination.total,
          ),
        ),
      ),
    );
    await pending?.future;
    if (isClosed) return;
    emit(
      state.copyWith(
        workouts: nextWorkouts,
        pagination: state.pagination.copyWith(
          total: nextTotal,
          offset: offset ?? 0,
        ),
        pendingWorkoutsQuery: const Nullable(null),
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

WorkoutPlanDto _samplePlan({int id = 1, String name = 'Hypertrophy Split'}) {
  return WorkoutPlanDto(
    id: id,
    name: name,
    currentVersion: 1,
    totalWeeks: 4,
    totalDays: 16,
    totalWorkouts: 16,
    difficulty: Difficulty.intermediate,
    isFavorite: false,
    createdBy: CreatedBy.user,
  );
}

WorkoutDto _sampleWorkout({int id = 1, String name = 'Upper Body Push'}) {
  return WorkoutDto(
    id: id,
    name: name,
    muscleGroups: const {MuscleGroup.push},
    muscles: const TargetMuscles(primary: {Muscle.chest}, secondary: {}),
    difficulty: Difficulty.intermediate,
    version: 1,
    isFavorite: false,
    totalSets: 5,
    totalReps: 50,
    editorType: EditorType.advanced,
    createdBy: CreatedBy.user,
  );
}

void main() {
  group('WorkoutPlanListScreen Skeletonizer', () {
    Future<void> pumpPlansScreen(
      WidgetTester tester,
      _TestWorkoutPlanCubit cubit,
    ) async {
      final router = _routerFor(const WorkoutPlanListScreen());
      addTearDown(cubit.close);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutPlanCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'shows skeleton cards on initial load, then renders plans and paginates with skeleton footer',
      (tester) async {
        final cubit = _TestWorkoutPlanCubit()
          ..pending = Completer<void>()
          ..nextPlans = [_samplePlan()]
          ..nextTotal = 2;

        await pumpPlansScreen(tester, cubit);

        expect(
          find.descendant(
            of: find.byType(WorkoutPlansList),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsNothing,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled && w.ignorePointers,
          ),
          findsOneWidget,
        );
        expect(find.byType(WorkoutPlanCard), findsNWidgets(3));

        cubit.pending!.complete();
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
          findsNothing,
        );
        expect(find.byType(WorkoutPlanCard), findsOneWidget);
        expect(find.text('Hypertrophy Split'), findsOneWidget);

        cubit.publish(cubit.state.copyWith(isLoading: true));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));

        expect(
          find.descendant(
            of: find.byType(WorkoutPlansList),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsNothing,
        );
        expect(find.byType(WorkoutPlanCard), findsNWidgets(2));
        expect(
          find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders empty state when loaded list is empty', (
      tester,
    ) async {
      final cubit = _TestWorkoutPlanCubit()
        ..pending = Completer<void>()
        ..nextPlans = const [];

      await pumpPlansScreen(tester, cubit);
      cubit.pending!.complete();
      await tester.pumpAndSettle();

      expect(find.text('No workout plans found'), findsOneWidget);
      expect(find.byType(WorkoutPlanCard), findsNothing);
    });
  });

  group('WorkoutsScreen Skeletonizer', () {
    Future<void> pumpWorkoutsScreen(
      WidgetTester tester,
      _TestWorkoutCubit cubit,
    ) async {
      final router = _routerFor(const WorkoutsScreen());
      addTearDown(cubit.close);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'shows skeleton cards on initial load, then renders workouts and paginates with skeleton footer',
      (tester) async {
        final cubit = _TestWorkoutCubit()
          ..pending = Completer<void>()
          ..nextWorkouts = [_sampleWorkout()]
          ..nextTotal = 2;

        await pumpWorkoutsScreen(tester, cubit);

        expect(
          find.descendant(
            of: find.byType(WorkoutsList),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsNothing,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled && w.ignorePointers,
          ),
          findsOneWidget,
        );
        expect(find.byType(WorkoutCard), findsNWidgets(3));

        cubit.pending!.complete();
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
          findsNothing,
        );
        expect(find.byType(WorkoutCard), findsOneWidget);
        expect(find.text('Upper Body Push'), findsOneWidget);

        cubit.publish(cubit.state.copyWith(isLoading: true));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));

        expect(
          find.descendant(
            of: find.byType(WorkoutsList),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsNothing,
        );
        expect(find.byType(WorkoutCard), findsNWidgets(2));
        expect(
          find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders empty state when loaded list is empty', (
      tester,
    ) async {
      final cubit = _TestWorkoutCubit()
        ..pending = Completer<void>()
        ..nextWorkouts = const [];

      await pumpWorkoutsScreen(tester, cubit);
      cubit.pending!.complete();
      await tester.pumpAndSettle();

      expect(find.text('No workouts found'), findsOneWidget);
      expect(find.byType(WorkoutCard), findsNothing);
    });
  });
}
