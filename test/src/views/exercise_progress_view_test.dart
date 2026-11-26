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

import 'package:myfitnesstale/src/data/models/sqlite/exercise_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_record_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/utils/dates.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/exercise_details.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_progress_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/states/exercise_record_state.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/progress/exercise_progress_head.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/progress/exercise_progress_records_list.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/test_database.dart';

class _ExerciseRecordCubit extends ExerciseRecordCubit {
  _ExerciseRecordCubit(
    ExerciseRecordState initialState,
    this.aggregateRecords, {
    this.pendingLatest,
    this.pendingRecords,
    int? total,
  }) : totalCount = total ?? aggregateRecords.length,
       super(exerciseRecordRepository: ExerciseRecordRepository.create()) {
    emit(initialState);
  }

  final List<ExerciseRecordDto> aggregateRecords;
  final Completer<void>? pendingLatest;
  final Completer<void>? pendingRecords;
  final int totalCount;
  int latestCalls = 0;
  int listCalls = 0;
  final List<(DateTime, DateTime)?> requestedDateRanges = [];

  void publish(ExerciseRecordState nextState) => emit(nextState);

  void showOnlyExercise(int exerciseId) {
    final filtered = aggregateRecords
        .where((record) => record.exerciseId == exerciseId)
        .toList();
    emit(
      state.copyWith(
        exerciseRecords: filtered,
        latestExerciseRecord: Nullable(filtered.firstOrNull),
        recordPagination: state.recordPagination.copyWith(
          exerciseId: Nullable(exerciseId),
          total: filtered.length,
        ),
      ),
    );
  }

  @override
  Future<void> getLatestExerciseRecord([int? exerciseId]) async {
    latestCalls++;
    emit(state.copyWith(isLoadingLatest: true));
    await pendingLatest?.future;
    if (isClosed) return;

    final matching = exerciseId == null
        ? aggregateRecords.firstOrNull
        : aggregateRecords
              .where((record) => record.exerciseId == exerciseId)
              .firstOrNull;
    emit(
      state.copyWith(
        latestExerciseRecord: Nullable(matching),
        isLoadingLatest: false,
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
    requestedDateRanges.add(dateRange);
    emit(state.copyWith(isLoadingRecords: true));
    await pendingRecords?.future;
    if (isClosed) return;

    final filtered = exerciseId == null
        ? aggregateRecords
        : aggregateRecords
              .where((record) => record.exerciseId == exerciseId)
              .toList();
    emit(
      state.copyWith(
        exerciseRecords: filtered,
        recordPagination: state.recordPagination.copyWith(
          exerciseId: Nullable(exerciseId),
          dateRange: Nullable(dateRange),
          limit: limit,
          offset: offset,
          total: exerciseId == null ? totalCount : filtered.length,
        ),
        isLoadingRecords: false,
      ),
    );
  }
}

class _ProfileCubit extends ProfileCubit {
  _ProfileCubit(Units units)
    : super(profileRepository: ProfileRepository.create()) {
    setUnits(units);
  }

  void setUnits(Units units) {
    emit(
      ProfileState(
        system: SystemDto(
          id: 1,
          units: units,
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

void main() {
  const muscles = TargetMuscles(primary: <Muscle>{}, secondary: <Muscle>{});
  const alpha = ExerciseDto(
    id: 1,
    name: 'Alpha Press',
    description: '',
    muscleGroup: MuscleGroup.push,
    muscles: muscles,
    createdBy: CreatedBy.user,
  );
  const zulu = ExerciseDto(
    id: 2,
    name: 'Zulu Row',
    description: '',
    muscleGroup: MuscleGroup.pull,
    muscles: muscles,
    createdBy: CreatedBy.user,
  );

  final records = <ExerciseRecordDto>[
    ExerciseRecordDto(
      id: 1,
      exerciseId: alpha.id,
      weight: 100000,
      reps: 3,
      maxStrength: 110000,
      recordDate: DateTime.utc(2026, 8, 13),
      exercise: alpha,
    ),
    ExerciseRecordDto(
      id: 2,
      exerciseId: alpha.id,
      weight: 90000,
      reps: 12,
      maxStrength: 120000,
      recordDate: DateTime.utc(2026, 8, 12),
      exercise: alpha,
    ),
    ExerciseRecordDto(
      id: 3,
      exerciseId: zulu.id,
      weight: 50000,
      reps: 8,
      maxStrength: 60000,
      recordDate: DateTime.utc(2026, 8, 11),
      exercise: zulu,
    ),
  ];

  late _ExerciseRecordCubit exerciseRecordCubit;
  late _ProfileCubit profileCubit;

  Widget buildHarness({
    Units units = Units.metric,
    List<ExerciseRecordDto>? customRecords,
    Completer<void>? pendingLatest,
    Completer<void>? pendingRecords,
    int? total,
  }) {
    final seedRecords = customRecords ?? records;
    exerciseRecordCubit = _ExerciseRecordCubit(
      ExerciseRecordState.initial(),
      seedRecords,
      pendingLatest: pendingLatest,
      pendingRecords: pendingRecords,
      total: total,
    );
    profileCubit = _ProfileCubit(units);

    final router = GoRouter(
      initialLocation: Routes.exerciseProgress.name,
      routes: [
        GoRoute(
          path: Routes.exerciseProgress.name,
          builder: (context, state) => const ExerciseProgressScreen(),
        ),
        GoRoute(
          path: Routes.exerciseRecords.name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(),
            body: Text('Records for ${state.pathParameters['id']}'),
          ),
        ),
        GoRoute(
          path: Routes.exercises.name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(),
            body: const Text('Exercises Destination'),
          ),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ExerciseRecordCubit>.value(value: exerciseRecordCubit),
        BlocProvider<ProfileCubit>.value(value: profileCubit),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  tearDown(() async {
    await exerciseRecordCubit.close();
    await profileCubit.close();
  });

  testWidgets(
    'shows Skeletonizer for header and list during initial load, then renders latest header and chronological records',
    (tester) async {
      final pendingLatest = Completer<void>();
      final pendingRecords = Completer<void>();

      await tester.pumpWidget(
        buildHarness(
          pendingLatest: pendingLatest,
          pendingRecords: pendingRecords,
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(exerciseRecordCubit.latestCalls, 1);
      expect(exerciseRecordCubit.listCalls, 1);
      expect(exerciseRecordCubit.requestedDateRanges.single, isNotNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.descendant(
          of: find.byType(ExerciseProgressHead),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ExerciseProgressRecordsList),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled,
          ),
        ),
        findsOneWidget,
      );

      pendingLatest.complete();
      pendingRecords.complete();
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
        findsNothing,
      );
      expect(find.text('Latest Record'), findsOneWidget);
      expect(find.text('Exercise Records'), findsOneWidget);
      expect(find.textContaining('100.00 KG'), findsWidgets);
      expect(find.textContaining('110.00 KG'), findsWidgets);
      expect(find.textContaining('Alpha Press'), findsWidgets);

      final firstListCard = tester.getTopLeft(
        find.byKey(const ValueKey('exercise-progress-record-1')),
      );
      final secondListCard = tester.getTopLeft(
        find.byKey(const ValueKey('exercise-progress-record-2')),
      );
      expect(firstListCard.dy, lessThan(secondListCard.dy));

      final listScrollable = find.descendant(
        of: find.byType(ExerciseProgressRecordsList),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('exercise-progress-record-3')),
        100,
        scrollable: listScrollable,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Zulu Row'), findsOneWidget);
      final scrolledSecondListCard = tester.getTopLeft(
        find.byKey(const ValueKey('exercise-progress-record-2')),
      );
      final thirdListCard = tester.getTopLeft(
        find.byKey(const ValueKey('exercise-progress-record-3')),
      );
      expect(scrolledSecondListCard.dy, lessThan(thirdListCard.dy));
    },
  );

  testWidgets('displays profile-selected imperial weights in header and list', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness(units: Units.imperial));
    await tester.pumpAndSettle();

    expect(find.textContaining('220.46 LBS'), findsWidgets);
    expect(find.textContaining('KG'), findsNothing);
  });

  testWidgets(
    'opens exercise records from latest header and list card and reloads on return',
    (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('latest-exercise-progress-card')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Records for 1'), findsOneWidget);
      exerciseRecordCubit.showOnlyExercise(alpha.id);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(exerciseRecordCubit.latestCalls, 2);
      expect(exerciseRecordCubit.listCalls, 2);

      final listScrollable = find.descendant(
        of: find.byType(ExerciseProgressRecordsList),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('exercise-progress-record-3')),
        100,
        scrollable: listScrollable,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Zulu Row'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('exercise-progress-record-3')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Records for 2'), findsOneWidget);
    },
  );

  testWidgets(
    'renders empty header and empty history when there are no records',
    (tester) async {
      await tester.pumpWidget(buildHarness(customRecords: const []));
      await tester.pumpAndSettle();

      expect(find.text('No exercise records'), findsOneWidget);
      expect(find.text('BROWSE EXERCISES'), findsOneWidget);
      expect(find.text('Empty history'), findsOneWidget);

      await tester.tap(find.text('BROWSE EXERCISES'));
      await tester.pumpAndSettle();
      expect(find.text('Exercises Destination'), findsOneWidget);
    },
  );

  testWidgets('shows skeleton footer card when loading more records', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(customRecords: [records.first], total: 5),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
      findsNothing,
    );

    exerciseRecordCubit.publish(
      exerciseRecordCubit.state.copyWith(isLoadingRecords: true),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ExerciseProgressRecordsList),
        matching: find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
      ),
      findsOneWidget,
    );
  });

  test('ExerciseRecordRepository.getLatestRecord returns global latest record with exercise', () async {
    final testDatabase = TestDatabase();
    await testDatabase.initialize();
    addTearDown(testDatabase.destroy);

    final repo = ExerciseRecordRepository.create();
    final db = await testDatabase.db;

    final benchId = await db.insert(
      Exercise.table,
      Exercise.create(
        name: 'Bench Press',
        description: '',
        details: StrengthExerciseDetails(
          muscleGroup: MuscleGroup.push,
          muscles: muscles,
          weightProgress: ExerciseWeightProgress.positive,
        ),
      ).toMap(),
    );
    final squatId = await db.insert(
      Exercise.table,
      Exercise.create(
        name: 'Back Squat',
        description: '',
        details: StrengthExerciseDetails(
          muscleGroup: MuscleGroup.legs,
          muscles: muscles,
          weightProgress: ExerciseWeightProgress.positive,
        ),
      ).toMap(),
    );

    await db.insert(
      ExerciseRecord.table,
      ExerciseRecord.create(
        exerciseId: benchId,
        weight: 80000,
        reps: 5,
        recordDate: DateUtilities.getDateUnix(DateTime.utc(2026, 8, 10)),
      ).toMap(),
    );
    await db.insert(
      ExerciseRecord.table,
      ExerciseRecord.create(
        exerciseId: squatId,
        weight: 120000,
        reps: 5,
        recordDate: DateUtilities.getDateUnix(DateTime.utc(2026, 8, 15)),
      ).toMap(),
    );

    final result = await repo.getLatestRecord();
    expect(result.isOk(), isTrue);
    expect(result.value.exerciseId, squatId);
    expect(result.value.exercise?.name, 'Back Squat');
    expect(result.value.weight, 120000);
  });
}
