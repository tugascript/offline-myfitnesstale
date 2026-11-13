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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/workout_plans_list_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workouts_list_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _FakeWorkoutCubit extends WorkoutCubit {
  final bool shouldFail;

  _FakeWorkoutCubit({this.shouldFail = false})
    : super(workoutRepository: WorkoutRepository.create());

  @override
  Future<void> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    int? limit,
    int? offset,
    bool isFavorite = false,
    CreatedBy? createdBy,
  }) async {}

  @override
  Future<void> createWorkout(WorkoutInput input) async {
    if (shouldFail) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(type: 'operationFailure', description: 'Create failed'),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedWorkout: Nullable(
          WorkoutDto(
            id: 42,
            name: input.name,
            muscleGroups: const {},
            muscles: const TargetMuscles(primary: {}, secondary: {}),
            difficulty: input.difficulty,
            version: 1,
            isFavorite: input.isFavorite,
            totalSets: 0,
            totalReps: 0,
            editorType: input.editorType,
            createdBy: CreatedBy.user,
          ),
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}

class _FakeWorkoutPlanCubit extends WorkoutPlanCubit {
  final bool shouldFail;

  _FakeWorkoutPlanCubit({this.shouldFail = false})
    : super(workoutPlanRepository: WorkoutPlanRepository.create());

  @override
  Future<void> getWorkoutPlans({
    String? name,
    Difficulty? difficulty,
    bool isFavorite = false,
    CreatedBy? createdBy,
    int? limit,
    int? offset,
  }) async {}

  @override
  Future<void> createWorkoutPlan(WorkoutPlanInput input) async {
    if (shouldFail) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(type: 'operationFailure', description: 'Create failed'),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedWorkoutPlan: Nullable(
          WorkoutPlanDto(
            id: 77,
            name: input.name,
            currentVersion: 1,
            totalWeeks: 0,
            totalDays: 0,
            totalWorkouts: 0,
            difficulty: input.difficulty,
            isFavorite: input.isFavorite,
            createdBy: CreatedBy.user,
          ),
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}

void main() {
  testWidgets(
    'Creating a workout through modal navigates directly to workout edit page',
    (tester) async {
      final cubit = _FakeWorkoutCubit();
      addTearDown(cubit.close);

      final pushedLocations = <String>[];
      final router = GoRouter(
        initialLocation: '/workouts',
        routes: [
          GoRoute(
            path: '/workouts',
            builder: (_, _) => const WorkoutsScreen(),
          ),
          GoRoute(
            path: '/workouts/:id/edit',
            builder: (_, state) {
              pushedLocations.add(state.uri.toString());
              return Scaffold(
                body: Text('Edit Workout ${state.pathParameters['id']}'),
              );
            },
          ),
          GoRoute(
            path: '/workouts/:id',
            builder: (_, state) {
              pushedLocations.add(state.uri.toString());
              return Scaffold(
                body: Text('Workout Detail ${state.pathParameters['id']}'),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('workout-add')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        ),
        'Push Day',
      );
      await tester.tap(find.text('CREATE WORKOUT'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(pushedLocations, ['/workouts/42/edit']);
      expect(find.text('Edit Workout 42'), findsOneWidget);
    },
  );

  testWidgets(
    'Creating a workout plan through modal navigates directly to workout plan edit page',
    (tester) async {
      final cubit = _FakeWorkoutPlanCubit();
      addTearDown(cubit.close);

      final pushedLocations = <String>[];
      final router = GoRouter(
        initialLocation: '/workout-plans',
        routes: [
          GoRoute(
            path: '/workout-plans',
            builder: (_, _) => const WorkoutPlanListScreen(),
          ),
          GoRoute(
            path: '/workout-plans/:id/edit',
            builder: (_, state) {
              pushedLocations.add(state.uri.toString());
              return Scaffold(
                body: Text('Edit Plan ${state.pathParameters['id']}'),
              );
            },
          ),
          GoRoute(
            path: '/workout-plans/:id',
            builder: (_, state) {
              pushedLocations.add(state.uri.toString());
              return Scaffold(
                body: Text('Plan Detail ${state.pathParameters['id']}'),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutPlanCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('workout-plan-add')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        ),
        'Hypertrophy Block',
      );
      await tester.tap(find.text('CREATE WORKOUT PLAN'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(pushedLocations, ['/workout-plans/77/edit']);
      expect(find.text('Edit Plan 77'), findsOneWidget);
    },
  );

  testWidgets(
    'Failed workout creation through modal does not navigate to edit page',
    (tester) async {
      final cubit = _FakeWorkoutCubit(shouldFail: true);
      addTearDown(cubit.close);

      final pushedLocations = <String>[];
      final router = GoRouter(
        initialLocation: '/workouts',
        routes: [
          GoRoute(
            path: '/workouts',
            builder: (_, _) => const WorkoutsScreen(),
          ),
          GoRoute(
            path: '/workouts/:id/edit',
            builder: (_, state) {
              pushedLocations.add(state.uri.toString());
              return Scaffold(
                body: Text('Edit Workout ${state.pathParameters['id']}'),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('workout-add')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        ),
        'Push Day',
      );
      await tester.tap(find.text('CREATE WORKOUT'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(pushedLocations, isEmpty);
    },
  );

  testWidgets(
    'Failed workout plan creation through modal does not navigate to edit page',
    (tester) async {
      final cubit = _FakeWorkoutPlanCubit(shouldFail: true);
      addTearDown(cubit.close);

      final pushedLocations = <String>[];
      final router = GoRouter(
        initialLocation: '/workout-plans',
        routes: [
          GoRoute(
            path: '/workout-plans',
            builder: (_, _) => const WorkoutPlanListScreen(),
          ),
          GoRoute(
            path: '/workout-plans/:id/edit',
            builder: (_, state) {
              pushedLocations.add(state.uri.toString());
              return Scaffold(
                body: Text('Edit Plan ${state.pathParameters['id']}'),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutPlanCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('workout-plan-add')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        ),
        'Hypertrophy Block',
      );
      await tester.tap(find.text('CREATE WORKOUT PLAN'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(pushedLocations, isEmpty);
    },
  );
}
