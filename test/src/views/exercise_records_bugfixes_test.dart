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
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:myfitnesstale/src/data/models/sqlite/exercise_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/strength_goal_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/equipment_input.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/exercise_record_input.dart';
import 'package:myfitnesstale/src/data/utils/dates.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/core/widgets/layout/app_icon_button.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/states/exercise_record_state.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/progress/exercise_progress_error_card.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/progress/exercise_progress_history.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/progress/exercise_progress_records_list.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/progress/latest_exercise_progress_record.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/records/exercise_records_history.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/records/latest_exercise_record.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/test_database.dart';

class _ControlledExerciseRecordCubit extends ExerciseRecordCubit {
  _ControlledExerciseRecordCubit(
    ExerciseRecordState initialState, {
    this.pendingLatest,
    this.pendingRecords,
    this.failLatest = false,
    this.failRecords = false,
  }) : super(exerciseRecordRepository: ExerciseRecordRepository.create()) {
    emit(initialState);
  }

  final Completer<void>? pendingLatest;
  final Completer<void>? pendingRecords;
  bool failLatest;
  bool failRecords;
  int latestCalls = 0;
  int listCalls = 0;

  @override
  Future<void> getLatestExerciseRecord([int? exerciseId]) async {
    latestCalls++;
    emit(state.copyWith(isLoadingLatest: true));
    await pendingLatest?.future;
    if (isClosed) return;
    if (failLatest) {
      const err = ErrorState(
        type: 'operationFailure',
        description: 'Failed to get latest exercise record',
      );
      emit(
        state.copyWith(
          isLoadingLatest: false,
          error: const Nullable(err),
          latestError: const Nullable(err),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoadingLatest: false,
        latestExerciseId: Nullable(exerciseId),
        error: const Nullable(null),
        latestError: const Nullable(null),
      ),
    );
  }

  @override
  Future<void> getExerciseRecords({
    int limit = 25,
    int offset = 0,
    (DateTime start, DateTime end)? dateRange,
    int? exerciseId,
  }) async {
    listCalls++;
    emit(
      state.copyWith(
        isLoadingRecords: true,
        exerciseRecords: offset == 0 ? const [] : state.exerciseRecords,
      ),
    );
    await pendingRecords?.future;
    if (isClosed) return;
    if (failRecords) {
      const err = ErrorState(
        type: 'operationFailure',
        description: 'Failed to get exercise records',
      );
      emit(
        state.copyWith(
          isLoadingRecords: false,
          error: const Nullable(err),
          recordsError: const Nullable(err),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoadingRecords: false,
        recordPagination: state.recordPagination.copyWith(
          exerciseId: Nullable(exerciseId),
          dateRange: Nullable(dateRange),
        ),
        error: const Nullable(null),
        recordsError: const Nullable(null),
      ),
    );
  }
}

void main() {
  const testBreakPoint = BreakPoint(400, 800);
  const emptyMuscles = TargetMuscles(primary: {}, secondary: {});
  const exerciseA = ExerciseDto(
    id: 1,
    name: 'Alpha Press',
    description: '',
    muscleGroup: MuscleGroup.push,
    muscles: emptyMuscles,
    createdBy: CreatedBy.system,
  );
  const exerciseB = ExerciseDto(
    id: 2,
    name: 'Beta Row',
    description: '',
    muscleGroup: MuscleGroup.pull,
    muscles: emptyMuscles,
    createdBy: CreatedBy.system,
  );

  final recordA = ExerciseRecordDto(
    id: 10,
    exerciseId: 1,
    weight: 100000,
    reps: 5,
    maxStrength: 116667,
    recordDate: DateTime(2026, 3, 1),
    exercise: exerciseA,
  );

  testWidgets('AppIconButton disables onPressed when isLoading is true', (
    tester,
  ) async {
    var tapped = false;
    final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppIconButton(
            sizes: sizes,
            isLoading: true,
            color: Colors.red,
            icon: Icons.delete,
            tooltip: 'Delete',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(iconButton.onPressed, isNull);

    await tester.tap(find.byType(IconButton));
    expect(tapped, isFalse);
  });

  testWidgets(
    'LatestExerciseRecord ignores previous exercise record while loading',
    (tester) async {
      final pending = Completer<void>();
      final cubit = _ControlledExerciseRecordCubit(
        ExerciseRecordState.initial().copyWith(
          latestExerciseRecord: Nullable(recordA),
        ),
        pendingLatest: pending,
      );
      addTearDown(cubit.close);

      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<ExerciseRecordCubit>.value(
              value: cubit,
              child: LatestExerciseRecord(
                theme: ThemeData.light(),
                sizes: sizes,
                units: Units.metric,
                exercise: exerciseB,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('100.00 KG'), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
        findsOneWidget,
      );

      pending.complete();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'ExerciseRecordsHistory does not show previous exercise records while switching',
    (tester) async {
      final pending = Completer<void>();
      final cubit = _ControlledExerciseRecordCubit(
        ExerciseRecordState.initial().copyWith(
          exerciseRecords: [recordA],
          recordPagination: const ExerciseRecordPagination(
            exerciseId: 1,
            limit: 1000,
            offset: 0,
            total: 1,
          ),
        ),
        pendingRecords: pending,
      );
      addTearDown(cubit.close);

      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<ExerciseRecordCubit>.value(
              value: cubit,
              child: ExerciseRecordsHistory(
                theme: ThemeData.light(),
                breakPoint: testBreakPoint,
                sizes: sizes,
                units: Units.metric,
                exercise: exerciseB,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('100.00 KG'), findsNothing);

      pending.complete();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'ExerciseProgressRecordsList shows skeleton when loading with empty list and does not force skeleton with stale exerciseId when not loading',
    (tester) async {
      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseProgressRecordsList(
              sizes: sizes,
              units: Units.metric,
              isLoading: true,
              exerciseRecords: const [],
              pagination: const ExerciseRecordPagination(
                limit: 20,
                offset: 0,
                total: 0,
              ),
              onTapExercise: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
        findsOneWidget,
      );
    },
  );

  test('ExerciseRecordCubit.getExerciseRecords clears records on offset 0 and deleteExerciseRecord fetches latest from DB', () async {
    final testDatabase = TestDatabase();
    await testDatabase.initialize();
    addTearDown(testDatabase.destroy);

    final db = await testDatabase.db;
    final exerciseId = await db.insert(
      Exercise.table,
      Exercise.create(
        name: 'Bench Press',
        description: '',
        muscleGroup: MuscleGroup.push,
        muscles: emptyMuscles,
      ).toMap(),
    );

    final olderUnix = DateUtilities.getDateUnix(DateTime.utc(2025, 1, 10));
    final newerUnix = DateUtilities.getDateUnix(DateTime.utc(2026, 3, 10));

    await db.insert(
      ExerciseRecord.table,
      ExerciseRecord.create(
        exerciseId: exerciseId,
        weight: 80000,
        reps: 5,
        recordDate: olderUnix,
      ).toMap(),
    );
    final newerId = await db.insert(
      ExerciseRecord.table,
      ExerciseRecord.create(
        exerciseId: exerciseId,
        weight: 100000,
        reps: 5,
        recordDate: newerUnix,
      ).toMap(),
    );

    final cubit = ExerciseRecordCubit(
      exerciseRecordRepository: ExerciseRecordRepository.create(),
    );
    addTearDown(cubit.close);

    await cubit.getLatestExerciseRecord(exerciseId);
    expect(cubit.state.latestExerciseRecord?.id, newerId);

    // Filter records to only 2026 so the 2025 record is not in state.exerciseRecords
    await cubit.getExerciseRecords(
      exerciseId: exerciseId,
      dateRange: (DateTime(2026, 1, 1), DateTime(2026, 12, 31)),
      offset: 0,
    );
    expect(cubit.state.exerciseRecords.length, 1);

    // Verify offset 0 clears exerciseRecords while loading
    final loadingFuture = cubit.getExerciseRecords(
      exerciseId: exerciseId,
      dateRange: (DateTime(2026, 1, 1), DateTime(2026, 12, 31)),
      offset: 0,
    );
    expect(cubit.state.isLoadingRecords, isTrue);
    expect(cubit.state.exerciseRecords, isEmpty);
    await loadingFuture;
    expect(cubit.state.exerciseRecords.length, 1);

    // Deleting the latest (2026) record should fall back to the 2025 DB record,
    // even though the 2025 record is not in the filtered in-memory page.
    await cubit.deleteExerciseRecord(newerId);
    expect(cubit.state.latestExerciseRecord, isNotNull);
    expect(cubit.state.latestExerciseRecord!.weight, 80000);
  });

  testWidgets(
    'LatestExerciseProgressRecord clears stale per-exercise latest while loading',
    (tester) async {
      final pending = Completer<void>();
      final cubit = _ControlledExerciseRecordCubit(
        ExerciseRecordState.initial().copyWith(
          latestExerciseRecord: Nullable(recordA),
        ),
        pendingLatest: pending,
      );
      addTearDown(cubit.close);

      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<ExerciseRecordCubit>.value(
              value: cubit,
              child: LatestExerciseProgressRecord(
                theme: ThemeData.light(),
                sizes: sizes,
                units: Units.metric,
                onOpenExerciseRecords: (_) async {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Alpha Press'), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
        findsOneWidget,
      );

      pending.complete();
      await tester.pumpAndSettle();
    },
  );

  test('createExerciseRecord preserves pagination scope, does not block on another exercise latest, and updateExerciseRecord uses DB latest', () async {
    final testDatabase = TestDatabase();
    await testDatabase.initialize();
    addTearDown(testDatabase.destroy);

    final db = await testDatabase.db;
    final benchId = await db.insert(
      Exercise.table,
      Exercise.create(
        name: 'Bench Press',
        description: '',
        muscleGroup: MuscleGroup.push,
        muscles: emptyMuscles,
      ).toMap(),
    );
    final squatId = await db.insert(
      Exercise.table,
      Exercise.create(
        name: 'Back Squat',
        description: '',
        muscleGroup: MuscleGroup.legs,
        muscles: emptyMuscles,
      ).toMap(),
    );

    // Newer global record for squat
    await db.insert(
      ExerciseRecord.table,
      ExerciseRecord.create(
        exerciseId: squatId,
        weight: 140000,
        reps: 5,
        recordDate: DateUtilities.getDateUnix(DateTime.utc(2026, 6, 1)),
      ).toMap(),
    );

    final cubit = ExerciseRecordCubit(
      exerciseRecordRepository: ExerciseRecordRepository.create(),
    );
    addTearDown(cubit.close);

    // Load global latest (squat, 2026-06-01) and global progress pagination (exerciseId: null)
    await cubit.getLatestExerciseRecord();
    await cubit.getExerciseRecords(offset: 0);
    expect(cubit.state.recordPagination.exerciseId, isNull);
    expect(cubit.state.latestExerciseRecord?.exerciseId, squatId);

    // Create an older record for bench (2026-05-01) while in global scope:
    // 1) recordPagination.exerciseId must remain null
    // 2) latestExerciseRecord must remain squat (2026-06-01), the true app-wide latest
    // 3) isLoading must be false
    await cubit.createExerciseRecord(
      ExerciseRecordInput(
        exerciseId: benchId,
        weight: 90000,
        reps: 5,
        recordDate: DateTime.utc(2026, 5, 1),
      ),
    );
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.recordPagination.exerciseId, isNull);
    expect(cubit.state.latestExerciseRecord?.exerciseId, squatId);

    // Now scope cubit to squat (e.g. visited squat records), then create for bench:
    // 1) recordPagination.exerciseId must remain squatId (not overwritten with benchId)
    // 2) exerciseRecords must still contain squat, not bench
    // 3) latestExerciseRecord / latestExerciseId must remain squat, not overwritten with bench
    await cubit.getLatestExerciseRecord(squatId);
    await cubit.getExerciseRecords(exerciseId: squatId, offset: 0);
    await cubit.createExerciseRecord(
      ExerciseRecordInput(
        exerciseId: benchId,
        weight: 95000,
        reps: 5,
        recordDate: DateTime.utc(2026, 5, 2),
      ),
    );
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.recordPagination.exerciseId, squatId);
    expect(
      cubit.state.exerciseRecords.every((r) => r.exerciseId == squatId),
      isTrue,
    );
    expect(cubit.state.latestExerciseId, squatId);
    expect(cubit.state.latestExerciseRecord?.exerciseId, squatId);

    // Create a newer bench record (2026-07-01) outside a 2025-only date filter,
    // then update an older 2025 bench record under that 2025 filter.
    await cubit.createExerciseRecord(
      ExerciseRecordInput(
        exerciseId: benchId,
        weight: 110000,
        reps: 3,
        recordDate: DateTime.utc(2026, 7, 1),
      ),
    );
    final oldBenchId = await db.insert(
      ExerciseRecord.table,
      ExerciseRecord.create(
        exerciseId: benchId,
        weight: 70000,
        reps: 8,
        recordDate: DateUtilities.getDateUnix(DateTime.utc(2025, 2, 1)),
      ).toMap(),
    );

    await cubit.getLatestExerciseRecord(benchId);
    await cubit.getExerciseRecords(
      exerciseId: benchId,
      dateRange: (DateTime.utc(2025, 1, 1), DateTime.utc(2025, 12, 31)),
      offset: 0,
    );
    await cubit.updateExerciseRecord(
      oldBenchId,
      ExerciseRecordInput(
        exerciseId: benchId,
        weight: 75000,
        reps: 8,
        recordDate: DateTime.utc(2025, 2, 1),
      ),
    );

    // Latest should still be the 2026-07-01 record (110000), not the 2025 filtered page record.
    expect(cubit.state.latestExerciseRecord?.weight, 110000);
  });

  test(
    'updateExerciseRecord completes matching in-progress strength goals',
    () async {
      final testDatabase = TestDatabase();
      await testDatabase.initialize();
      addTearDown(testDatabase.destroy);

      final db = await testDatabase.db;
      final benchId = await db.insert(
        Exercise.table,
        Exercise.create(
          name: 'Bench Press',
          description: '',
          muscleGroup: MuscleGroup.push,
          muscles: emptyMuscles,
        ).toMap(),
      );
      final goalId = await db.insert(
        StrengthGoal.table,
        StrengthGoal.create(
          exerciseId: benchId,
          targetWeight: 100000,
          targetReps: 5,
          targetMaxStrength: 116667,
          startDate: DateUtilities.getDateUnix(DateTime.utc(2026, 4, 1)),
          name: '2 Plates',
        ).toMap(),
      );
      final recordId = await db.insert(
        ExerciseRecord.table,
        ExerciseRecord.create(
          exerciseId: benchId,
          weight: 90000,
          reps: 5,
          recordDate: DateUtilities.getDateUnix(DateTime.utc(2026, 5, 1)),
        ).toMap(),
      );

      final cubit = ExerciseRecordCubit(
        exerciseRecordRepository: ExerciseRecordRepository.create(),
      );
      addTearDown(cubit.close);

      await cubit.getActiveStrengthGoal(exerciseId: benchId);
      expect(cubit.state.activeStrengthGoal?.id, goalId);

      await cubit.updateExerciseRecord(
        recordId,
        ExerciseRecordInput(
          exerciseId: benchId,
          weight: 100000,
          reps: 5,
          recordDate: DateTime.utc(2026, 5, 1),
        ),
      );

      final goalRows = await db.query(
        StrengthGoal.table,
        where: '${StrengthGoalColumns.id.name} = ?',
        whereArgs: [goalId],
      );
      expect(goalRows.single[StrengthGoalColumns.status.name], 'completed');
      expect(cubit.state.activeStrengthGoal, isNull);
    },
  );

  testWidgets(
    'Progress widgets show retry card when scoped refetch fails and recover on retry',
    (tester) async {
      final cubit = _ControlledExerciseRecordCubit(
        ExerciseRecordState.initial().copyWith(
          latestExerciseRecord: Nullable(recordA),
          latestExerciseId: const Nullable(1),
          exerciseRecords: [recordA],
          recordPagination: const ExerciseRecordPagination(
            exerciseId: 1,
            limit: 20,
            offset: 0,
            total: 1,
          ),
        ),
        failLatest: true,
        failRecords: true,
      );
      addTearDown(cubit.close);

      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<ExerciseRecordCubit>.value(
              value: cubit,
              child: Column(
                children: [
                  LatestExerciseProgressRecord(
                    theme: ThemeData.light(),
                    sizes: sizes,
                    units: Units.metric,
                    onOpenExerciseRecords: (_) async {},
                  ),
                  Expanded(
                    child: ExerciseProgressHistory(
                      theme: ThemeData.light(),
                      breakPoint: testBreakPoint,
                      sizes: sizes,
                      units: Units.metric,
                      dateRange: DateTimeRange(
                        start: DateTime(2026, 1, 1),
                        end: DateTime(2026, 3, 1),
                      ),
                      onDateRangeChanged: (_) {},
                      onOpenExerciseRecords: (_) async {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseProgressErrorCard), findsNWidgets(2));
      expect(find.text('Empty history'), findsNothing);
      expect(find.text('No exercise records'), findsNothing);

      cubit.failLatest = false;
      cubit.failRecords = false;
      final retries = find.text('RETRY');
      expect(retries, findsNWidgets(2));
      await tester.tap(retries.first);
      await tester.tap(retries.last);
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseProgressErrorCard), findsNothing);
    },
  );

  test('negative weightProgress goal completes at <= targetWeight and not at > targetWeight', () async {
    final testDatabase = TestDatabase();
    await testDatabase.initialize();
    addTearDown(testDatabase.destroy);

    final db = await testDatabase.db;
    final assistedId = await db.insert(
      Exercise.table,
      Exercise.create(
        name: 'Assisted Pull-Up',
        description: '',
        muscleGroup: MuscleGroup.pull,
        muscles: emptyMuscles,
        weightProgress: ExerciseWeightProgress.negative,
      ).toMap(),
    );
    final goalId = await db.insert(
      StrengthGoal.table,
      StrengthGoal.create(
        exerciseId: assistedId,
        targetWeight: 20000, // 20 kg assistance
        targetReps: 8,
        targetMaxStrength: 25333,
        startDate: DateUtilities.getDateUnix(DateTime.utc(2026, 4, 1)),
      ).toMap(),
    );

    final repo = ExerciseRecordRepository.create();

    // 40 kg assistance (more help) must NOT complete a 20 kg assistance goal
    final heavierAssist = await repo.createExerciseRecord(
      ExerciseRecordInput(
        exerciseId: assistedId,
        weight: 40000,
        reps: 8,
        recordDate: DateTime.utc(2026, 5, 1),
      ),
    );
    expect(heavierAssist.isOk(), isTrue);

    var goalRows = await db.query(
      StrengthGoal.table,
      where: '${StrengthGoalColumns.id.name} = ?',
      whereArgs: [goalId],
    );
    expect(goalRows.single[StrengthGoalColumns.status.name], 'in_progress');

    // Qualifying record predating goal.startDate (2026-03-01 < 2026-04-01) must NOT complete it
    final predatingAssist = await repo.createExerciseRecord(
      ExerciseRecordInput(
        exerciseId: assistedId,
        weight: 10000,
        reps: 8,
        recordDate: DateTime.utc(2026, 3, 1),
      ),
    );
    expect(predatingAssist.isOk(), isTrue);

    goalRows = await db.query(
      StrengthGoal.table,
      where: '${StrengthGoalColumns.id.name} = ?',
      whereArgs: [goalId],
    );
    expect(goalRows.single[StrengthGoalColumns.status.name], 'in_progress');

    // 10 kg assistance (less help) MUST complete the 20 kg assistance goal
    final lighterAssist = await repo.createExerciseRecord(
      ExerciseRecordInput(
        exerciseId: assistedId,
        weight: 10000,
        reps: 8,
        recordDate: DateTime.utc(2026, 5, 2),
      ),
    );
    expect(lighterAssist.isOk(), isTrue);

    goalRows = await db.query(
      StrengthGoal.table,
      where: '${StrengthGoalColumns.id.name} = ?',
      whereArgs: [goalId],
    );
    expect(goalRows.single[StrengthGoalColumns.status.name], 'completed');

    // Qualifying record at midnight on the same calendar day as a goal created later
    // that day (14:30) MUST complete the goal.
    final sameDayGoalId = await db.insert(
      StrengthGoal.table,
      StrengthGoal.create(
        exerciseId: assistedId,
        targetWeight: 20000,
        targetReps: 8,
        targetMaxStrength: 25333,
        startDate: DateUtilities.getDateUnix(DateTime(2026, 6, 10, 14, 30)),
      ).toMap(),
    );
    final sameDayRecord = await repo.createExerciseRecord(
      ExerciseRecordInput(
        exerciseId: assistedId,
        weight: 10000,
        reps: 8,
        recordDate: DateTime(2026, 6, 10),
      ),
    );
    expect(sameDayRecord.isOk(), isTrue);

    final sameDayGoalRows = await db.query(
      StrengthGoal.table,
      where: '${StrengthGoalColumns.id.name} = ?',
      whereArgs: [sameDayGoalId],
    );
    expect(
      sameDayGoalRows.single[StrengthGoalColumns.status.name],
      'completed',
    );
  });

  testWidgets(
    'successful getLatestExerciseRecord does not clear recordsError from concurrent history failure',
    (tester) async {
      final pendingLatest = Completer<void>();
      final cubit = _ControlledExerciseRecordCubit(
        ExerciseRecordState.initial(),
        pendingLatest: pendingLatest,
        failRecords: true,
        failLatest: false,
      );
      addTearDown(cubit.close);

      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<ExerciseRecordCubit>.value(
              value: cubit,
              child: Column(
                children: [
                  LatestExerciseProgressRecord(
                    theme: ThemeData.light(),
                    sizes: sizes,
                    units: Units.metric,
                    onOpenExerciseRecords: (_) async {},
                  ),
                  Expanded(
                    child: ExerciseProgressHistory(
                      theme: ThemeData.light(),
                      breakPoint: testBreakPoint,
                      sizes: sizes,
                      units: Units.metric,
                      dateRange: DateTimeRange(
                        start: DateTime(2026, 1, 1),
                        end: DateTime(2026, 3, 1),
                      ),
                      onDateRangeChanged: (_) {},
                      onOpenExerciseRecords: (_) async {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // History failed while latest is still in flight; now latest succeeds
      pendingLatest.complete();
      await tester.pumpAndSettle();

      // History must still show its error/retry card, not "Empty history"
      expect(find.byType(ExerciseProgressErrorCard), findsOneWidget);
      expect(find.text('Empty history'), findsNothing);
    },
  );

  test('updateEquipmentFavorite removes unfavorited equipment from favorites list and decrements total', () async {
    final testDatabase = TestDatabase();
    await testDatabase.initialize();
    addTearDown(testDatabase.destroy);

    final exerciseCubit = ExerciseCubit(
      exerciseRepository: ExerciseRepository.create(),
    );
    addTearDown(exerciseCubit.close);

    await exerciseCubit.createEquipment(
      const EquipmentInput(name: 'Fav Barbell', isFavorite: true),
    );
    await exerciseCubit.getEquipments(limit: 20, offset: 0, isFavorite: true);
    expect(exerciseCubit.state.equipments.length, 1);
    expect(exerciseCubit.state.equipmentPagination.total, 1);

    final id = exerciseCubit.state.equipments.single.id;
    await exerciseCubit.updateEquipmentFavorite(id, false);
    expect(exerciseCubit.state.equipments, isEmpty);
    expect(exerciseCubit.state.equipmentPagination.total, 0);

    await exerciseCubit.updateEquipmentFavorite(id, true);
    expect(exerciseCubit.state.equipments.length, 1);
    expect(exerciseCubit.state.equipments.single.id, id);
    expect(exerciseCubit.state.equipmentPagination.total, 1);
  });
}
