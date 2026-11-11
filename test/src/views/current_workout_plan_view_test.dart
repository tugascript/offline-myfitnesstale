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
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/states/workout_plan_record_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/current_workout_plan_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/active/active_workout_plan_content.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/active/active_workout_plan_dummy_data.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';

class _Cubit extends WorkoutPlanRecordCubit {
  _Cubit()
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
      );

  int loads = 0;
  WorkoutPlanRecordState nextState = WorkoutPlanRecordState.initial();
  Completer<void>? pending;

  void publish(WorkoutPlanRecordState value) => emit(value);

  @override
  Future<void> getLatestActivePlanRecord() async {
    loads++;
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));
    await pending?.future;
    emit(nextState);
  }

  @override
  Future<void> getOrCreateActivePlanRecord(int workoutPlanId) async {
    fail('Opening the current plan must not create an execution');
  }

  @override
  Future<void> startWorkoutPlan(int workoutPlanId) async {
    fail('Opening the current plan must not start an execution');
  }
}

void main() {
  WorkoutPlanRecordState activeState() =>
      WorkoutPlanRecordState.initial().copyWith(
        currentPlanRecord: ActiveWorkoutPlanDummyData.dummyState.copyWith(
          workoutPlan: Nullable(
            ActiveWorkoutPlanDummyData.dummyState.workoutPlan!.copyWith(
              name: 'My current plan',
            ),
          ),
        ),
      );

  Future<void> pumpView(
    WidgetTester tester,
    _Cubit cubit, {
    ValueNotifier<bool>? visible,
    double textScale = 1,
  }) async {
    addTearDown(cubit.close);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => visible == null
              ? const CurrentWorkoutPlanScreen()
              : ValueListenableBuilder<bool>(
                  valueListenable: visible,
                  builder: (_, value, child) =>
                      CurrentWorkoutPlanScreen(isVisible: value),
                ),
        ),
        GoRoute(
          path: '/workout-plans',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Return from library'),
            ),
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
    await tester.pump();
  }

  testWidgets('loads read-only and separates loading from empty', (
    tester,
  ) async {
    final cubit = _Cubit()..pending = Completer<void>();
    await pumpView(tester, cubit);
    expect(cubit.loads, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Skeletonizer && widget.enabled && widget.ignorePointers,
      ),
      findsOneWidget,
    );
    expect(find.text('No Active Workout Plan'), findsNothing);
    expect(find.text('BROWSE PLANS'), findsNothing);
    cubit.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.text('No Active Workout Plan'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('current-plan-browse-plans')),
      findsOneWidget,
    );
  });

  testWidgets('renders active content and observes plan updates', (
    tester,
  ) async {
    final cubit = _Cubit()..nextState = activeState();
    await pumpView(tester, cubit);
    await tester.pumpAndSettle();
    expect(find.byType(ActiveWorkoutPlanContent), findsOneWidget);
    expect(find.text('My current plan'), findsOneWidget);
    expect(find.text('BROWSE PLANS'), findsNothing);
    cubit.publish(cubit.state.copyWith(isLoading: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Skeletonizer && widget.enabled,
      ),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    cubit.publish(WorkoutPlanRecordState.initial());
    await tester.pumpAndSettle();
    expect(find.text('No Active Workout Plan'), findsOneWidget);
  });

  testWidgets('reports failure and retries even with stale content', (
    tester,
  ) async {
    final cubit = _Cubit()
      ..nextState = activeState().copyWith(
        error: const Nullable(
          ErrorState(type: 'operationFailure', description: 'Lookup failed'),
        ),
      );
    await pumpView(tester, cubit);
    await tester.pumpAndSettle();
    expect(find.text('Lookup failed'), findsOneWidget);
    expect(find.text('BROWSE PLANS'), findsNothing);
    expect(find.byType(ActiveWorkoutPlanContent), findsNothing);
    cubit.nextState = activeState();
    await tester.tap(find.text('RETRY'));
    await tester.pumpAndSettle();
    expect(cubit.loads, 2);
    expect(find.text('My current plan'), findsOneWidget);
  });

  testWidgets(
    'keeps cached state on activation and refreshes after Browse Plans',
    (tester) async {
      final visible = ValueNotifier(false);
      addTearDown(visible.dispose);
      final cubit = _Cubit();
      await pumpView(tester, cubit, visible: visible);
      expect(cubit.loads, 0);
      visible.value = true;
      await tester.pumpAndSettle();
      visible.value = false;
      await tester.pumpAndSettle();
      visible.value = true;
      await tester.pumpAndSettle();
      expect(cubit.loads, 1);
      expect(find.text('No Active Workout Plan'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('current-plan-browse-plans')));
      await tester.pumpAndSettle();
      cubit.nextState = activeState();
      await tester.tap(find.text('Return from library'));
      await tester.pumpAndSettle();
      expect(cubit.loads, 2);
      expect(find.text('My current plan'), findsOneWidget);
      expect(find.text('BROWSE PLANS'), findsNothing);
      visible.value = false;
      await tester.pumpAndSettle();
      visible.value = true;
      await tester.pumpAndSettle();
      expect(cubit.loads, 2);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer && widget.enabled,
        ),
        findsNothing,
      );
    },
  );

  testWidgets('does not display completed or abandoned executions', (
    tester,
  ) async {
    final cubit = _Cubit();
    await pumpView(tester, cubit);
    await tester.pumpAndSettle();
    for (final status in [ProgressStatus.completed, ProgressStatus.abandoned]) {
      final current = activeState().currentPlanRecord;
      cubit.publish(
        activeState().copyWith(
          currentPlanRecord: current.copyWith(
            currentPlanRecord: Nullable(
              current.currentPlanRecord!.copyWith(status: status),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No Active Workout Plan'), findsOneWidget);
      expect(find.byType(ActiveWorkoutPlanContent), findsNothing);
    }
  });

  testWidgets('waits for shared Cubit work before refreshing', (tester) async {
    final cubit = _Cubit();
    cubit.publish(cubit.state.copyWith(isLoading: true));
    await pumpView(tester, cubit);
    expect(cubit.loads, 0);
    cubit.publish(WorkoutPlanRecordState.initial());
    await tester.pumpAndSettle();
    expect(cubit.loads, 1);
  });

  testWidgets('empty and active content fit narrow screens at 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cubit = _Cubit()..pending = Completer<void>();
    await pumpView(tester, cubit, textScale: 2);
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    cubit.pending!.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    cubit.publish(activeState());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
