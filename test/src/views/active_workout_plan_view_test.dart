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
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/ui/core/screens/entity_error_screen.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/active_workout_plan_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/states/workout_plan_record_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/active/active_workout_plan_dummy_data.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _FakeWorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _FakeWorkoutPlanRecordCubit()
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );

  final List<int> deletedRecordIds = [];
  bool failNextDelete = false;
  WorkoutPlanRecordState? loadedState;

  void publish(WorkoutPlanRecordState value) => emit(value);

  @override
  Future<void> getOrCreateActivePlanRecord(int workoutPlanId) async {
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));
    if (loadedState != null) {
      emit(loadedState!);
    }
  }

  @override
  Future<bool> deleteWorkoutPlanRecord(int id) async {
    deletedRecordIds.add(id);
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));
    if (failNextDelete) {
      failNextDelete = false;
      emit(
        state.copyWith(
          isLoading: false,
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to delete workout plan record',
            ),
          ),
        ),
      );
      return false;
    }
    emit(
      state.copyWith(
        currentPlanRecord: CurrentWorkoutPlanRecordState.initial(),
        hasLoadedActivePlan: true,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }
}

void main() {
  const planId = 42;
  const recordId = 7;

  WorkoutPlanRecordState activeState() {
    final dummy = ActiveWorkoutPlanDummyData.dummyState;
    return WorkoutPlanRecordState.initial().copyWith(
      hasLoadedActivePlan: true,
      currentPlanRecord: dummy.copyWith(
        workoutPlan: Nullable(
          dummy.workoutPlan!.copyWith(id: planId, name: 'Active Plan'),
        ),
        currentPlanRecord: Nullable(
          dummy.currentPlanRecord!.copyWith(
            id: recordId,
            workoutPlanId: planId,
          ),
        ),
      ),
    );
  }

  Future<GoRouter> pumpRouter(
    WidgetTester tester,
    _FakeWorkoutPlanRecordCubit cubit, {
    required String initialLocation,
    double textScale = 1,
  }) async {
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => context.push('/workout-plans/$planId/active'),
                child: const Text('Open Active Plan'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/workout-plans/:id',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Text('Plan Detail ${state.pathParameters['id']}'),
            ),
          ),
        ),
        GoRoute(
          path: '/workout-plans/:id/active',
          builder: (context, state) => ActiveWorkoutPlanScreen(
            workoutPlanId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<WorkoutPlanRecordCubit>.value(
        value: cubit,
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets(
    'cancels without deleting, then deletes after confirmation and pops back',
    (tester) async {
      final cubit = _FakeWorkoutPlanRecordCubit()..publish(activeState());
      await pumpRouter(tester, cubit, initialLocation: '/');

      await tester.tap(find.text('Open Active Plan'));
      await tester.pumpAndSettle();
      expect(find.text('Active Plan'), findsOneWidget);

      final deleteButton = find.byKey(
        const ValueKey('active-workout-plan-record-delete'),
      );
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      expect(find.text('DELETE WORKOUT PLAN RECORD'), findsOneWidget);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(cubit.deletedRecordIds, isEmpty);
      expect(find.text('Active Plan'), findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pump();
      expect(find.byType(EntityErrorScreen), findsNothing);
      await tester.pumpAndSettle();

      expect(cubit.deletedRecordIds, [recordId]);
      expect(find.text('Open Active Plan'), findsOneWidget);
      expect(find.byType(ActiveWorkoutPlanScreen), findsNothing);
    },
  );

  testWidgets(
    'navigates to workout plan detail when deleted from root active route',
    (tester) async {
      final cubit = _FakeWorkoutPlanRecordCubit()..publish(activeState());
      await pumpRouter(
        tester,
        cubit,
        initialLocation: '/workout-plans/$planId/active',
      );

      await tester.tap(
        find.byKey(const ValueKey('active-workout-plan-record-delete')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(cubit.deletedRecordIds, [recordId]);
      expect(find.text('Plan Detail $planId'), findsOneWidget);
    },
  );

  testWidgets('shows error snackbar and stays on screen when delete fails', (
    tester,
  ) async {
    final cubit = _FakeWorkoutPlanRecordCubit()
      ..publish(activeState())
      ..failNextDelete = true;
    await pumpRouter(
      tester,
      cubit,
      initialLocation: '/workout-plans/$planId/active',
    );

    final deleteButton = find.byKey(
      const ValueKey('active-workout-plan-record-delete'),
    );
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    expect(cubit.deletedRecordIds, [recordId]);
    expect(find.text('Failed to delete workout plan record'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Active Plan'), findsOneWidget);
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    expect(cubit.deletedRecordIds, [recordId, recordId]);
    expect(find.text('Plan Detail $planId'), findsOneWidget);
  });

  testWidgets('fits narrow 320px screen at 200% text scale without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = _FakeWorkoutPlanRecordCubit()..publish(activeState());
    await pumpRouter(
      tester,
      cubit,
      initialLocation: '/workout-plans/$planId/active',
      textScale: 2,
    );

    expect(
      find.byKey(const ValueKey('active-workout-plan-record-delete')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
