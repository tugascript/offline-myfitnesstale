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

import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/active_workout_plan_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/workout_plan_history_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/states/workout_plan_record_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/active/active_workout_plan_dummy_data.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/history/single_workout_plan_record_list.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _ProfileCubit extends ProfileCubit {
  _ProfileCubit() : super(profileRepository: ProfileRepository.create()) {
    emit(
      ProfileState(
        profile: ProfileDto(
          id: 1,
          name: 'Tester',
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

class _WorkoutPlanCubit extends WorkoutPlanCubit {
  _WorkoutPlanCubit()
    : super(workoutPlanRepository: WorkoutPlanRepository.create());

  @override
  Future<void> getWorkoutPlan(int id, {bool isRefresh = false}) async {}
}

class _WorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _WorkoutPlanRecordCubit(WorkoutPlanRecordState initialState)
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      ) {
    emit(initialState);
  }

  int loadCalls = 0;
  final List<int> deletedRecordIds = [];
  bool failNextDelete = false;

  void failWithLoadedRecords(String description) {
    emit(
      state.copyWith(
        error: Nullable(
          ErrorState(type: 'operationFailure', description: description),
        ),
      ),
    );
  }

  @override
  Future<void> getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? progressStatus,
    (DateTime, DateTime)? dateRange,
    int limit = 20,
    int offset = 0,
  }) async {
    loadCalls++;
  }

  @override
  Future<void> getLatestWorkoutPlanRecord([int? workoutPlanId]) async {}

  @override
  Future<void> getOrCreateActivePlanRecord(int workoutPlanId) async {}

  @override
  Future<bool> deleteWorkoutPlanRecord(int id) async {
    deletedRecordIds.add(id);
    if (failNextDelete) {
      failNextDelete = false;
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to delete workout plan record',
            ),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    final remaining = state.planRecords.where((r) => r.id != id).toList();
    final nextLatest = state.latestWorkoutPlanRecord?.id == id
        ? (remaining.isNotEmpty ? remaining.first : null)
        : state.latestWorkoutPlanRecord;
    emit(
      state.copyWith(
        planRecords: remaining,
        latestWorkoutPlanRecord: Nullable(nextLatest),
        pagination: state.pagination.copyWith(
          total: state.pagination.total > 0 ? state.pagination.total - 1 : 0,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }
}

void main() {
  WorkoutPlanRecordDto record(
    int id,
    ProgressStatus status, {
    String? planName,
  }) {
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
      workoutPlan: planName != null
          ? WorkoutPlanDto(
              id: 9,
              name: planName,
              currentVersion: id,
              totalWeeks: 4,
              totalDays: 12,
              totalWorkouts: 12,
              difficulty: Difficulty.intermediate,
              isFavorite: false,
              createdBy: CreatedBy.user,
            )
          : null,
    );
  }

  Future<_WorkoutPlanRecordCubit> pumpView(
    WidgetTester tester,
    WorkoutPlanRecordState state, {
    int? workoutPlanId = 9,
  }) async {
    final cubit = _WorkoutPlanRecordCubit(state);
    final workoutPlanCubit = _WorkoutPlanCubit();
    final profileCubit = _ProfileCubit();
    addTearDown(() async {
      await cubit.close();
      await workoutPlanCubit.close();
      await profileCubit.close();
    });
    final router = GoRouter(
      initialLocation: WorkoutPlanHistoryScreen.location(workoutPlanId),
      routes: [
        GoRoute(
          path: Routes.workoutPlanHistory.name,
          builder: (context, state) =>
              WorkoutPlanHistoryScreen(workoutPlanId: workoutPlanId),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutPlanCubit>.value(value: workoutPlanCubit),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
          BlocProvider<WorkoutPlanRecordCubit>.value(value: cubit),
        ],
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
    expect(cubit.loadCalls, 1);

    cubit = await pumpView(tester, WorkoutPlanRecordState.initial());
    expect(find.text('No Plan History'), findsOneWidget);
    expect(find.text('No workout plan records'), findsOneWidget);

    cubit.failWithLoadedRecords('History failed');
    await tester.pump();
    expect(find.text('History failed'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
    'renders progress summaries for every status without card navigation',
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
      expect(find.textContaining('Completed:'), findsOneWidget);
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

      // Cards are not wrapped in a tappable card-level InkWell; only delete IconButtons exist.
      final listCards = find.descendant(
        of: find.byType(SingleWorkoutPlanRecordList),
        matching: find.byType(Card),
      );
      for (final cardElement in listCards.evaluate()) {
        final cardWidget = cardElement.widget as Card;
        expect(cardWidget.child, isNot(isA<InkWell>()));
      }
    },
  );

  testWidgets(
    'shows workout plan names when global history includes workoutPlan DTOs',
    (tester) async {
      final records = [
        record(1, ProgressStatus.inProgress, planName: 'Upper/Lower Split'),
        record(2, ProgressStatus.completed, planName: 'Push/Pull/Legs'),
      ];
      await pumpView(
        tester,
        WorkoutPlanRecordState.initial().copyWith(
          planRecords: records,
          pagination: const WorkoutPlanRecordPagination(
            limit: 20,
            offset: 0,
            total: 2,
          ),
        ),
        workoutPlanId: null,
      );

      expect(find.text('Upper/Lower Split'), findsOneWidget);
      expect(find.text('Push/Pull/Legs'), findsOneWidget);
    },
  );

  testWidgets('reports refresh errors while retaining loaded history', (
    tester,
  ) async {
    final cubit = await pumpView(
      tester,
      WorkoutPlanRecordState.initial().copyWith(
        planRecords: [record(1, ProgressStatus.inProgress)],
        pagination: const WorkoutPlanRecordPagination(
          workoutPlanId: 9,
          limit: 20,
          offset: 0,
          total: 1,
        ),
      ),
    );

    cubit.failWithLoadedRecords('Refresh failed');
    await tester.pump();

    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Refresh failed'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
    'deletes latest workout plan record after confirmation and cancels without deleting',
    (tester) async {
      final latest = record(2, ProgressStatus.completed);
      final older = record(1, ProgressStatus.abandoned);
      final cubit = await pumpView(
        tester,
        WorkoutPlanRecordState.initial().copyWith(
          latestWorkoutPlanRecord: Nullable(latest),
          planRecords: [latest, older],
          pagination: const WorkoutPlanRecordPagination(
            workoutPlanId: 9,
            limit: 20,
            offset: 0,
            total: 2,
          ),
        ),
      );

      final deleteButton = find.byKey(
        const ValueKey('latest-workout-plan-record-delete'),
      );
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      expect(find.text('DELETE WORKOUT PLAN RECORD'), findsOneWidget);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(cubit.deletedRecordIds, isEmpty);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(cubit.deletedRecordIds, [2]);
      expect(cubit.state.latestWorkoutPlanRecord?.id, 1);
      expect(cubit.state.planRecords.map((r) => r.id), [1]);
    },
  );

  testWidgets(
    'deletes history list workout plan record after confirmation and shows error snackbar on failure',
    (tester) async {
      final first = record(10, ProgressStatus.completed);
      final second = record(11, ProgressStatus.abandoned);
      final cubit = await pumpView(
        tester,
        WorkoutPlanRecordState.initial().copyWith(
          latestWorkoutPlanRecord: Nullable(first),
          planRecords: [first, second],
          pagination: const WorkoutPlanRecordPagination(
            workoutPlanId: 9,
            limit: 20,
            offset: 0,
            total: 2,
          ),
        ),
      );

      // Scroll the outer page down so the history list sits cleanly in view above the FAB.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -350));
      await tester.pumpAndSettle();

      final itemDelete = find.byKey(
        const ValueKey('workout-plan-record-delete-11'),
      );
      await tester.scrollUntilVisible(
        itemDelete,
        150,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(itemDelete);
      await tester.pumpAndSettle();
      expect(find.text('DELETE WORKOUT PLAN RECORD'), findsOneWidget);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(cubit.deletedRecordIds, isEmpty);

      cubit.failNextDelete = true;
      await tester.tap(itemDelete);
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(cubit.deletedRecordIds, [11]);
      expect(find.text('Failed to delete workout plan record'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(cubit.state.planRecords.map((r) => r.id), [10, 11]);

      ScaffoldMessenger.of(
        tester.element(find.byType(WorkoutPlanHistoryScreen)),
      ).clearSnackBars();
      await tester.pumpAndSettle();

      await tester.tap(itemDelete);
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(cubit.deletedRecordIds, [11, 11]);
      expect(cubit.state.planRecords.map((r) => r.id), [10]);
    },
  );

  testWidgets(
    'does not enqueue duplicate error snackbars when covered by ActiveWorkoutPlanScreen',
    (tester) async {
      final activeRecord = record(15, ProgressStatus.inProgress);
      final dummy = ActiveWorkoutPlanDummyData.dummyState;
      final initialState = WorkoutPlanRecordState.initial().copyWith(
        hasLoadedActivePlan: true,
        latestWorkoutPlanRecord: Nullable(activeRecord),
        planRecords: [activeRecord],
        pagination: const WorkoutPlanRecordPagination(
          workoutPlanId: 9,
          limit: 20,
          offset: 0,
          total: 1,
        ),
        currentPlanRecord: dummy.copyWith(
          workoutPlan: Nullable(
            dummy.workoutPlan!.copyWith(id: 9, name: 'Active Split'),
          ),
          currentPlanRecord: Nullable(
            dummy.currentPlanRecord!.copyWith(id: 15, workoutPlanId: 9),
          ),
        ),
      );

      final cubit = _WorkoutPlanRecordCubit(initialState);
      final workoutPlanCubit = _WorkoutPlanCubit();
      final profileCubit = _ProfileCubit();
      addTearDown(() async {
        await cubit.close();
        await workoutPlanCubit.close();
        await profileCubit.close();
      });

      final router = GoRouter(
        initialLocation: WorkoutPlanHistoryScreen.location(9),
        routes: [
          GoRoute(
            path: Routes.workoutPlanHistory.name,
            builder: (context, state) =>
                const WorkoutPlanHistoryScreen(workoutPlanId: 9),
          ),
          GoRoute(
            path: Routes.activeWorkoutPlan.name,
            builder: (context, state) =>
                const ActiveWorkoutPlanScreen(workoutPlanId: 9),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<WorkoutPlanCubit>.value(value: workoutPlanCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
            BlocProvider<WorkoutPlanRecordCubit>.value(value: cubit),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Push ActiveWorkoutPlanScreen on top of WorkoutPlanHistoryScreen.
      router.push('/workout-plans/9/active');
      await tester.pumpAndSettle();
      expect(find.byType(ActiveWorkoutPlanScreen), findsOneWidget);

      // Fail a delete from ActiveWorkoutPlanScreen: only the active screen should show a SnackBar.
      cubit.failNextDelete = true;
      await tester.tap(
        find.byKey(const ValueKey('active-workout-plan-record-delete')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to delete workout plan record'), findsOneWidget);

      // Dismissing the single snackbar must NOT reveal a second duplicate queued by the hidden history screen.
      ScaffoldMessenger.of(tester.element(find.byType(ActiveWorkoutPlanScreen)))
          .hideCurrentSnackBar();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);

      // Pop back to WorkoutPlanHistoryScreen and verify it still displays errors when current.
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutPlanHistoryScreen), findsOneWidget);
      expect(find.byType(ActiveWorkoutPlanScreen), findsNothing);
      final historyRoute = ModalRoute.of(
        tester.element(find.byType(WorkoutPlanHistoryScreen)),
      );
      expect(historyRoute?.isCurrent, isTrue);
      cubit.failWithLoadedRecords('History error when foreground');
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('History error when foreground'), findsOneWidget);
    },
  );
}
