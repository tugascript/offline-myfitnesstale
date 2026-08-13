import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/cubits/states/common_state.dart';
import 'package:myfitnesstale/src/cubits/states/workout_plan_record_state.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_record_dto.dart';
import 'package:myfitnesstale/src/views/workout_plans/workout_plan_history_view.dart';

class _WorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _WorkoutPlanRecordCubit(WorkoutPlanRecordState initialState) {
    emit(initialState);
  }

  int loadCalls = 0;

  @override
  Future<void> getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? progressStatus,
    int limit = 20,
    int offset = 0,
  }) async {
    loadCalls++;
  }
}

void main() {
  WorkoutPlanRecordDto record(int id, ProgressStatus status) {
    return WorkoutPlanRecordDto(
      id: id,
      workoutPlanId: 9,
      workoutPlanVersion: id,
      status: status,
      currentWeek: id,
      currentDay: 2,
      currentWorkoutPosition: 3,
      startedAt: DateTime.utc(2026, 8, id),
      completedAt: status == ProgressStatus.completed
          ? DateTime.utc(2026, 8, id, 1)
          : null,
    );
  }

  Future<_WorkoutPlanRecordCubit> pumpView(
    WidgetTester tester,
    WorkoutPlanRecordState state,
  ) async {
    final cubit = _WorkoutPlanRecordCubit(state);
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: WorkoutPlanHistoryView.location(9),
      routes: [
        GoRoute(
          path: WorkoutPlanHistoryView.routeName,
          builder: (context, state) =>
              const WorkoutPlanHistoryView(workoutPlanId: 9),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<WorkoutPlanRecordCubit>.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    return cubit;
  }

  testWidgets('renders loading, empty, and error states', (tester) async {
    var cubit = await pumpView(
      tester,
      WorkoutPlanRecordState.initial().copyWith(isLoading: true),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(cubit.loadCalls, 1);

    cubit = await pumpView(tester, WorkoutPlanRecordState.initial());
    expect(find.text('No Plan History'), findsOneWidget);

    cubit = await pumpView(
      tester,
      WorkoutPlanRecordState.initial().copyWith(
        error: const ErrorState(
          type: 'operationFailure',
          description: 'History failed',
        ),
      ),
    );
    expect(find.text('Could not load plan history'), findsOneWidget);
    expect(find.text('History failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('renders read-only progress summaries for every status',
      (tester) async {
    final records = [
      record(1, ProgressStatus.inProgress),
      record(2, ProgressStatus.completed),
      record(3, ProgressStatus.abandoned),
      record(4, ProgressStatus.skipped),
    ];
    await pumpView(
      tester,
      WorkoutPlanRecordState.initial().copyWith(
        planRecords: records,
        pagination: const WorkoutPlanRecordPagination(
          workoutPlanId: 9,
          limit: 20,
          offset: 0,
          total: 4,
        ),
      ),
    );

    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Abandoned'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Abandoned'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Skipped'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Skipped'), findsOneWidget);
    expect(find.text('Version 4'), findsOneWidget);
    expect(
      find.text('Last reached: Week 4 • Day 2 • Workout 3'),
      findsOneWidget,
    );
    expect(find.textContaining('Completed:'), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
  });
}
