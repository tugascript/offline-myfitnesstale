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

import 'package:myfitnesstale/src/data/models/sqlite/exercise_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_set_exercise_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_set_record_model.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/services/sqlite/dao.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_history_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/history/empty_workout_record.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/history/latest_workout_record.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/history/latest_workout_record_card.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/test_database.dart';

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

class _WorkoutCubit extends WorkoutCubit {
  _WorkoutCubit() : super(workoutRepository: WorkoutRepository.create());

  @override
  Future<void> getWorkout(int id, {int? version, bool refresh = false}) async {}
}

class _SpyWorkoutRecordCubit extends WorkoutRecordCubit {
  _SpyWorkoutRecordCubit()
    : super(workoutRecordRepository: WorkoutRecordRepository.create());

  final List<({int? workoutId, bool skipSkipped})> latestCalls = [];
  final List<({int? workoutId, bool? skipSkipped})> listCalls = [];

  void seedLatestRecord(WorkoutRecordDto? record) {
    emit(
      state.copyWith(latestWorkoutRecord: Nullable(record), isLoading: false),
    );
  }

  @override
  Future<void> getLatestWorkoutRecord({
    int? workoutId,
    bool skipSkipped = false,
  }) async {
    latestCalls.add((workoutId: workoutId, skipSkipped: skipSkipped));
  }

  @override
  Future<void> getWorkoutRecords({
    int? workoutId,
    (DateTime, DateTime)? dateRange,
    bool? skipSkipped,
    int? limit,
    int? offset,
  }) async {
    listCalls.add((workoutId: workoutId, skipSkipped: skipSkipped));
  }
}

void main() {
  final testDatabase = TestDatabase();

  setUpAll(() => testDatabase.initialize());

  tearDownAll(() => testDatabase.destroy());

  Future<void> pumpHistoryScreen(
    WidgetTester tester, {
    required WorkoutRecordCubit workoutRecordCubit,
    int? workoutId,
    int? version,
  }) async {
    final workoutCubit = _WorkoutCubit();
    final profileCubit = _ProfileCubit();
    addTearDown(() async {
      await workoutCubit.close();
      await profileCubit.close();
    });

    final router = GoRouter(
      initialLocation: WorkoutHistoryScreen.location(
        workoutId: workoutId,
        version: version,
      ),
      routes: [
        GoRoute(
          path: Routes.workoutHistory.name,
          builder: (context, state) =>
              WorkoutHistoryScreen(workoutId: workoutId, version: version),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutCubit>.value(value: workoutCubit),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
          BlocProvider<WorkoutRecordCubit>.value(value: workoutRecordCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets(
    'WorkoutHistoryScreen requests skipSkipped: true for latest and paginated fetches',
    (tester) async {
      final spyCubit = _SpyWorkoutRecordCubit();
      addTearDown(spyCubit.close);

      await pumpHistoryScreen(
        tester,
        workoutRecordCubit: spyCubit,
        workoutId: 9,
        version: 2,
      );

      expect(spyCubit.latestCalls, [(workoutId: 9, skipSkipped: true)]);
      expect(spyCubit.listCalls, [(workoutId: 9, skipSkipped: true)]);
    },
  );

  testWidgets(
    'WorkoutHistoryScreen wraps empty-state actions at 200% text scaling',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final spyCubit = _SpyWorkoutRecordCubit();
      addTearDown(spyCubit.close);
      await pumpHistoryScreen(
        tester,
        workoutRecordCubit: spyCubit,
        workoutId: 9,
        version: 2,
      );

      final start = find.text('START WORKOUT');
      final create = find.text('CREATE RECORD');
      expect(
        tester.getBottomLeft(start).dy,
        lessThan(tester.getTopLeft(create).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'WorkoutHistoryScreen omits skipped workout records from latest and history list',
    (tester) async {
      final workoutId = await tester.runAsync(() async {
        final db = await testDatabase.db;
        final id = await db.insert(
          Workout.table,
          Workout.create(
            name: 'Skipped Only Workout',
            difficulty: Difficulty.beginner,
          ).toMap(),
        );

        final now = DateTime.now();
        await db.insert(
          WorkoutRecord.table,
          WorkoutRecord.create(
            workoutId: id,
            version: 1,
            startedAt: now.millisecondsSinceEpoch ~/ 1000,
            droppedAt: now.millisecondsSinceEpoch ~/ 1000,
            status: ProgressStatus.skipped,
          ).toMap(),
        );
        return id;
      });

      final cubit = WorkoutRecordCubit(
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );
      addTearDown(cubit.close);

      await tester.runAsync(() async {
        await pumpHistoryScreen(
          tester,
          workoutRecordCubit: cubit,
          workoutId: workoutId,
          version: 1,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(cubit.state.latestWorkoutRecord, isNull);
      expect(cubit.state.workoutRecords, isEmpty);
      expect(cubit.state.pagination.skipSkipped, isTrue);
      expect(find.text('No workout records'), findsOneWidget);
      expect(find.text('Empty history'), findsOneWidget);
    },
  );

  testWidgets(
    'LatestWorkoutRecord refetches on workoutId change and ignores mismatched cached record',
    (tester) async {
      final spyCubit = _SpyWorkoutRecordCubit();
      addTearDown(spyCubit.close);
      spyCubit.seedLatestRecord(
        WorkoutRecordDto(
          id: 10,
          workoutId: 1,
          version: 1,
          currentSetPosition: 0,
          currentSetNumber: 1,
          currentExercisePosition: 0,
          totalSets: 3,
          totalReps: 30,
          totalRestSecs: 90,
          totalVolume: 1500000,
          muscles: const TargetMuscles(primary: {}, secondary: {}),
          startedAt: DateTime(2026, 3, 1),
          completedAt: DateTime(2026, 3, 1, 0, 30),
        ),
      );

      Widget buildWidget(int workoutId) {
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);
        return BlocProvider<WorkoutRecordCubit>.value(
          value: spyCubit,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => LatestWorkoutRecord(
                  sizes: sizes,
                  theme: Theme.of(context),
                  units: Units.metric,
                  workoutId: workoutId,
                  workoutVersion: 1,
                ),
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildWidget(1));
      await tester.pump();

      expect(spyCubit.latestCalls, [(workoutId: 1, skipSkipped: true)]);
      expect(find.byType(LatestWorkoutRecordCard), findsOneWidget);
      expect(find.byType(EmptyWorkoutRecord), findsNothing);

      await tester.pumpWidget(buildWidget(2));
      await tester.pump();

      expect(spyCubit.latestCalls, [
        (workoutId: 1, skipSkipped: true),
        (workoutId: 2, skipSkipped: true),
      ]);
      expect(find.byType(LatestWorkoutRecordCard), findsNothing);
      expect(find.byType(EmptyWorkoutRecord), findsOneWidget);
    },
  );

  testWidgets(
    'LatestWorkoutRecord shows error and retry action on latestError instead of empty state',
    (tester) async {
      final spyCubit = _SpyWorkoutRecordCubit();
      addTearDown(spyCubit.close);

      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);
      await tester.pumpWidget(
        BlocProvider<WorkoutRecordCubit>.value(
          value: spyCubit,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => LatestWorkoutRecord(
                  sizes: sizes,
                  theme: Theme.of(context),
                  units: Units.metric,
                  workoutId: 7,
                  workoutVersion: 1,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      const err = ErrorState(
        type: 'operationFailure',
        description: 'Failed to get latest workout record',
      );
      spyCubit.emit(
        spyCubit.state.copyWith(
          latestWorkoutRecord: const Nullable(null),
          latestError: const Nullable(err),
          error: const Nullable(err),
          isLoadingLatest: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load latest workout record'), findsOneWidget);
      expect(find.byType(EmptyWorkoutRecord), findsNothing);

      final callsBeforeRetry = spyCubit.latestCalls.length;
      await tester.tap(
        find.byKey(const ValueKey('latest-workout-record-retry')),
      );
      await tester.pump();

      expect(spyCubit.latestCalls.length, callsBeforeRetry + 1);
      expect(spyCubit.latestCalls.last, (workoutId: 7, skipSkipped: true));
    },
  );

  testWidgets(
    'EmptyWorkoutRecord does not spin navigation actions during unrelated cubit work',
    (tester) async {
      final spyCubit = _SpyWorkoutRecordCubit();
      addTearDown(spyCubit.close);

      await tester.pumpWidget(
        BlocProvider<WorkoutRecordCubit>.value(
          value: spyCubit,
          child: MaterialApp(
            home: Scaffold(
              body: LatestWorkoutRecord(
                theme: ThemeData.light(),
                sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs),
                units: Units.metric,
                workoutId: 7,
                workoutVersion: 1,
              ),
            ),
          ),
        ),
      );

      spyCubit.emit(
        spyCubit.state.copyWith(
          latestWorkoutRecord: const Nullable(null),
          isLoading: true,
          isLoadingLatest: false,
          isLoadingRecords: true,
        ),
      );
      await tester.pump();

      expect(spyCubit.state.isLoading, isTrue);
      final emptyCard = tester.widget<EmptyWorkoutRecord>(
        find.byType(EmptyWorkoutRecord),
      );
      expect(emptyCard.isLoading, isFalse);
    },
  );

  test('WorkoutRecordCubit.getLatestWorkoutRecord clears stale record on failure and preserves unrelated errors on recovery', () async {
    final db = await testDatabase.db;
    final workoutId = await db.insert(
      Workout.table,
      Workout.create(
        name: 'Error Recovery Workout',
        difficulty: Difficulty.beginner,
      ).toMap(),
    );
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await db.insert(
      WorkoutRecord.table,
      WorkoutRecord.create(
        workoutId: workoutId,
        version: 1,
        startedAt: now,
        completedAt: now + 1800,
        status: ProgressStatus.completed,
      ).toMap(),
    );

    var failRead = false;
    final helper = DatabaseHelper();
    final repo = WorkoutRecordRepository(
      workoutRecordDao: Dao<WorkoutRecord>(
        databaseHelper: helper,
        tableName: WorkoutRecord.table,
        fromMap: (map) {
          if (failRead) {
            throw StateError('Simulated workout record read failure');
          }
          return WorkoutRecord.fromMap(map);
        },
      ),
      setRecordDao: Dao<WorkoutSetRecord>(
        databaseHelper: helper,
        tableName: WorkoutSetRecord.table,
        fromMap: WorkoutSetRecord.fromMap,
      ),
      setExerciseRecordDao: Dao<WorkoutSetExerciseRecord>(
        databaseHelper: helper,
        tableName: WorkoutSetExerciseRecord.table,
        fromMap: WorkoutSetExerciseRecord.fromMap,
      ),
      workoutDao: Dao<Workout>(
        databaseHelper: helper,
        tableName: Workout.table,
        fromMap: Workout.fromMap,
      ),
      exerciseDao: Dao<Exercise>(
        databaseHelper: helper,
        tableName: Exercise.table,
        fromMap: Exercise.fromMap,
      ),
    );
    final cubit = WorkoutRecordCubit(workoutRecordRepository: repo);
    addTearDown(cubit.close);

    await cubit.getLatestWorkoutRecord(workoutId: workoutId);
    expect(cubit.state.latestWorkoutRecord, isNotNull);
    expect(cubit.state.latestError, isNull);

    failRead = true;
    await cubit.getLatestWorkoutRecord(workoutId: workoutId);
    expect(cubit.state.latestWorkoutRecord, isNull);
    expect(cubit.state.latestError, isNotNull);
    expect(cubit.state.isLoadingLatest, isFalse);

    // Unrelated history failure should survive active latest recovery.
    await cubit.getWorkoutRecords(workoutId: workoutId);
    final historyError = cubit.state.recordsError;
    expect(historyError, isNotNull);

    failRead = false;
    await cubit.getLatestWorkoutRecord(workoutId: workoutId);
    expect(cubit.state.latestWorkoutRecord, isNotNull);
    expect(cubit.state.latestError, isNull);
    expect(cubit.state.error, equals(historyError));
  });
}
