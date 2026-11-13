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

import 'package:myfitnesstale/src/data/models/sqlite/workout_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_record_model.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_history_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_record_cubit.dart';

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
          builder: (context, state) => WorkoutHistoryScreen(
            workoutId: workoutId,
            version: version,
          ),
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
}
