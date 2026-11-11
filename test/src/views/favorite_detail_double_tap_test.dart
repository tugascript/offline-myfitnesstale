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

import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_detail_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/workout_plan_detail_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_detail_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _TestExerciseCubit extends ExerciseCubit {
  final List<(int, bool)> favoriteCalls = [];
  Completer<void>? pendingFavorite;

  _TestExerciseCubit() : super(exerciseRepository: ExerciseRepository.create());

  @override
  Future<void> getExercise(int id) async {
    emit(
      state.copyWith(
        selectedExercise: const Nullable(
          ExerciseDto(
            id: 1,
            name: 'Bench Press',
            description: 'Compound push movement',
            muscleGroup: MuscleGroup.push,
            muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
            equipments: [],
            isFavorite: false,
            createdBy: CreatedBy.user,
          ),
        ),
        isLoading: false,
      ),
    );
  }

  @override
  Future<void> updateExerciseFavorite(int id, bool isFavorite) async {
    favoriteCalls.add((id, isFavorite));
    emit(state.copyWith(isLoading: true));
    await (pendingFavorite ?? (Completer<void>()..complete())).future;
    final current = state.selectedExercise;
    if (current == null || isClosed) return;
    emit(
      state.copyWith(
        selectedExercise: Nullable(
          ExerciseDto(
            id: current.id,
            name: current.name,
            description: current.description,
            muscleGroup: current.muscleGroup,
            muscles: current.muscles,
            equipments: current.equipments,
            isFavorite: isFavorite,
            createdBy: current.createdBy,
          ),
        ),
        isLoading: false,
      ),
    );
  }
}

class _TestWorkoutCubit extends WorkoutCubit {
  final List<(int, bool)> favoriteCalls = [];
  Completer<void>? pendingFavorite;
  bool failNext = false;

  _TestWorkoutCubit() : super(workoutRepository: WorkoutRepository.create());

  @override
  Future<void> getWorkout(int id, {int? version, bool refresh = false}) async {
    emit(
      state.copyWith(
        selectedWorkout: const Nullable(
          WorkoutDto(
            id: 1,
            name: 'Push Day',
            muscleGroups: {MuscleGroup.push},
            muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
            difficulty: Difficulty.intermediate,
            version: 1,
            isFavorite: false,
            totalSets: 0,
            totalReps: 0,
            editorType: EditorType.basic,
            createdBy: CreatedBy.user,
            sets: [],
          ),
        ),
        isLoading: false,
      ),
    );
  }

  @override
  Future<void> updateWorkoutFavorite(int id, bool isFavorite) async {
    favoriteCalls.add((id, isFavorite));
    emit(state.copyWith(isLoading: true));
    await (pendingFavorite ?? (Completer<void>()..complete())).future;
    final current = state.selectedWorkout;
    if (current == null || isClosed) return;
    if (failNext) {
      failNext = false;
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to update workout',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        selectedWorkout: Nullable(current.copyWith(isFavorite: isFavorite)),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}

class _TestWorkoutPlanCubit extends WorkoutPlanCubit {
  final List<(int, bool)> favoriteCalls = [];
  Completer<void>? pendingFavorite;

  _TestWorkoutPlanCubit()
    : super(workoutPlanRepository: WorkoutPlanRepository.create());

  @override
  Future<void> getWorkoutPlan(int id, {bool isRefresh = false}) async {
    emit(
      state.copyWith(
        selectedWorkoutPlan: const Nullable(
          WorkoutPlanDto(
            id: 1,
            name: 'PPL Split',
            currentVersion: 1,
            totalWeeks: 4,
            totalDays: 12,
            totalWorkouts: 12,
            difficulty: Difficulty.intermediate,
            isFavorite: false,
            createdBy: CreatedBy.user,
            weeks: [],
          ),
        ),
        isLoading: false,
      ),
    );
  }

  @override
  Future<void> updateWorkoutPlanFavorite(int id, bool isFavorite) async {
    favoriteCalls.add((id, isFavorite));
    emit(state.copyWith(isLoading: true));
    await (pendingFavorite ?? (Completer<void>()..complete())).future;
    final current = state.selectedWorkoutPlan;
    if (current == null || isClosed) return;
    emit(
      state.copyWith(
        selectedWorkoutPlan: Nullable(current.copyWith(isFavorite: isFavorite)),
        isLoading: false,
      ),
    );
  }
}

class _NoopWorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _NoopWorkoutPlanRecordCubit()
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
      );

  @override
  Future<void> getLatestActivePlanRecord() async {}
}

GoRouter _routerFor(Widget child) {
  return GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, _) => child)],
  );
}

void main() {
  testWidgets(
    'ExerciseDetailScreen ignores duplicate favorite taps while loading',
    (tester) async {
      final cubit = _TestExerciseCubit()..pendingFavorite = Completer<void>();
      final router = _routerFor(const ExerciseDetailScreen(exerciseId: 1));
      addTearDown(cubit.close);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(cubit.favoriteCalls, equals([(1, true)]));

      cubit.pendingFavorite!.complete();
      cubit.pendingFavorite = Completer<void>()..complete();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      expect(cubit.favoriteCalls, equals([(1, true), (1, false)]));
    },
  );

  testWidgets(
    'WorkoutDetailScreen ignores duplicate favorite taps while loading and displays errors',
    (tester) async {
      final cubit = _TestWorkoutCubit()..pendingFavorite = Completer<void>();
      final router = _routerFor(const WorkoutDetailScreen(workoutId: 1));
      addTearDown(cubit.close);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(cubit.favoriteCalls, equals([(1, true)]));

      cubit.pendingFavorite!.complete();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);

      cubit.failNext = true;
      cubit.pendingFavorite = Completer<void>()..complete();
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      expect(find.text('Failed to update workout'), findsOneWidget);
    },
  );

  testWidgets(
    'WorkoutPlanDetailScreen ignores duplicate favorite taps while loading',
    (tester) async {
      final cubit = _TestWorkoutPlanCubit()
        ..pendingFavorite = Completer<void>();
      final recordCubit = _NoopWorkoutPlanRecordCubit();
      final router = _routerFor(
        const WorkoutPlanDetailScreen(workoutPlanId: 1),
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
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(cubit.favoriteCalls, equals([(1, true)]));

      cubit.pendingFavorite!.complete();
      cubit.pendingFavorite = Completer<void>()..complete();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      expect(cubit.favoriteCalls, equals([(1, true), (1, false)]));
    },
  );
}
