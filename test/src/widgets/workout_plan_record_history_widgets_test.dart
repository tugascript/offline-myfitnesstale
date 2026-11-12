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
import 'package:material_ui/material_ui.dart';

import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/states/workout_plan_record_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/history/latest_workout_plan_record.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/history/single_workout_plan_record_list.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/history/workout_plan_record_head.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/history/workout_plan_record_history.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _FakeWorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _FakeWorkoutPlanRecordCubit(WorkoutPlanRecordState initialState)
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
      ) {
    emit(initialState);
  }

  @override
  Future<void> getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? progressStatus,
    (DateTime, DateTime)? dateRange,
    int limit = 20,
    int offset = 0,
  }) async {}

  @override
  Future<void> getLatestWorkoutPlanRecord([int? workoutPlanId]) async {}
}

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm);

  WorkoutPlanDto samplePlan(String name) => WorkoutPlanDto(
    id: 1,
    name: name,
    difficulty: Difficulty.intermediate,
    currentVersion: 1,
    isFavorite: false,
    totalWeeks: 8,
    totalDays: 4,
    totalWorkouts: 32,
    createdBy: CreatedBy.user,
  );

  WorkoutPlanRecordDto sampleRecord({
    required DateTime startedAt,
    DateTime? completedAt,
    ProgressStatus status = ProgressStatus.inProgress,
    WorkoutPlanDto? plan,
  }) => WorkoutPlanRecordDto(
    id: 10,
    workoutPlanId: 1,
    workoutPlanVersion: 1,
    status: status,
    currentWeek: 2,
    currentDay: 3,
    currentWorkoutPosition: 1,
    startedAt: startedAt,
    completedAt: completedAt,
    workoutPlan: plan,
  );

  testWidgets('WorkoutPlanRecordHead displays plan details correctly', (
    tester,
  ) async {
    final record = sampleRecord(
      startedAt: DateTime.utc(2026, 3, 1, 10, 0),
      completedAt: DateTime.utc(2026, 3, 1, 11, 30),
      status: ProgressStatus.completed,
      plan: samplePlan('Hypertrophy Phase 1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => WorkoutPlanRecordHead(
              sizes: sizes,
              theme: Theme.of(context),
              units: Units.metric,
              isLoading: false,
              workoutPlanRecord: record,
            ),
          ),
        ),
      ),
    );

    expect(find.text(' Hypertrophy Phase 1'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Version 1'), findsOneWidget);
    expect(find.text(' 1h 30m 0s'), findsOneWidget);
    expect(find.textContaining('Week'), findsWidgets);
    expect(find.textContaining('Day'), findsWidgets);
    expect(find.textContaining('Workout'), findsWidgets);
    expect(find.text('Last reached: Week 2 • Day 3 • Workout 1'), findsOneWidget);
  });

  testWidgets('SingleWorkoutPlanRecordList renders cards and empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleWorkoutPlanRecordList(
            sizes: sizes,
            units: Units.metric,
            isLoading: false,
            planRecords: const [],
            pagination: WorkoutPlanRecordPagination.initial(),
          ),
        ),
      ),
    );

    expect(find.text('No plan records found'), findsOneWidget);

    final records = [
      sampleRecord(
        startedAt: DateTime.utc(2026, 4, 1),
        plan: samplePlan('Push Pull Legs'),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleWorkoutPlanRecordList(
            sizes: sizes,
            units: Units.metric,
            isLoading: false,
            planRecords: records,
            pagination: const WorkoutPlanRecordPagination(
              limit: 20,
              offset: 0,
              total: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Push Pull Legs'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
  });

  testWidgets('LatestWorkoutPlanRecord renders empty and loaded record states', (
    tester,
  ) async {
    final emptyCubit = _FakeWorkoutPlanRecordCubit(
      WorkoutPlanRecordState.initial(),
    );
    addTearDown(emptyCubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<WorkoutPlanRecordCubit>.value(
            value: emptyCubit,
            child: Builder(
              builder: (context) => LatestWorkoutPlanRecord(
                sizes: sizes,
                theme: Theme.of(context),
                units: Units.metric,
                workoutPlanId: 1,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No workout plan records'), findsOneWidget);
    expect(find.text('START PLAN'), findsOneWidget);

    final loadedRecord = sampleRecord(
      startedAt: DateTime.utc(2026, 5, 1, 9, 0),
      plan: samplePlan('Strength Block A'),
    );
    final loadedCubit = _FakeWorkoutPlanRecordCubit(
      WorkoutPlanRecordState.initial().copyWith(
        latestWorkoutPlanRecord: Nullable(loadedRecord),
      ),
    );
    addTearDown(loadedCubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<WorkoutPlanRecordCubit>.value(
            value: loadedCubit,
            child: Builder(
              builder: (context) => LatestWorkoutPlanRecord(
                sizes: sizes,
                theme: Theme.of(context),
                units: Units.metric,
                workoutPlanId: 1,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Latest Record'), findsOneWidget);
    expect(find.text(' Strength Block A'), findsOneWidget);
  });

  testWidgets('WorkoutPlanRecordHistory renders date range and records', (
    tester,
  ) async {
    final cubit = _FakeWorkoutPlanRecordCubit(
      WorkoutPlanRecordState.initial().copyWith(
        planRecords: [
          sampleRecord(
            startedAt: DateTime.utc(2026, 6, 1),
            plan: samplePlan('Upper Lower'),
          ),
        ],
        pagination: const WorkoutPlanRecordPagination(
          limit: 20,
          offset: 0,
          total: 1,
        ),
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<WorkoutPlanRecordCubit>.value(
            value: cubit,
            child: Builder(
              builder: (context) => WorkoutPlanRecordHistory(
                theme: Theme.of(context),
                breakPoint: BreakPoint.fromContext(context),
                sizes: sizes,
                units: Units.metric,
                workoutPlanId: 1,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Plan Records'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Upper Lower'), findsOneWidget);
  });
}
