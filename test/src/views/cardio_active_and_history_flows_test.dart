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

import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_cardio_set_exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_cardio_set_exercise_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_cardio_set_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_record_batch_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/exercise_details.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/active_workout_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/create_workout_record_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/update_workout_record_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_history_detail_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_history_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/active_workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/states/active_workout_state.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/active_cardio_exercise_card.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/active_cardio_time_exercise.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/active_cardio_units_exercise.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/active_rest_timer.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/history/detail/workout_cardio_record_sets.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

const _runExercise = ExerciseDto(
  id: 201,
  name: 'Outdoor Running',
  description: 'Steady pace run',
  details: CardioExerciseDetails(
    defaultMode: CardioBaseMode.time,
    unitType: CardioUnitType.distance,
    unit: 'km',
  ),
  createdBy: CreatedBy.system,
);

const _rowExercise = ExerciseDto(
  id: 202,
  name: 'Concept2 Rowing',
  description: 'Meter target row',
  details: CardioExerciseDetails(
    defaultMode: CardioBaseMode.units,
    unitType: CardioUnitType.distance,
    unit: 'm',
  ),
  createdBy: CreatedBy.system,
);

WorkoutDto _buildCardioWorkout() {
  return const WorkoutDto(
    id: 77,
    name: 'Hybrid Cardio Session',
    description: 'Time run followed by rowing distance',
    muscleGroups: {},
    muscles: TargetMuscles(primary: {}, secondary: {}),
    difficulty: Difficulty.intermediate,
    version: 1,
    isFavorite: false,
    totalSets: 2,
    totalReps: 0,
    editorType: EditorType.cardio,
    createdBy: CreatedBy.user,
    cardioSets: [
      WorkoutCardioSetDto(
        id: 701,
        position: 1,
        setType: CardioSetType.constant,
        restSecs: 45,
        rounds: 1,
        exercises: [
          WorkoutCardioSetExerciseDto(
            id: 711,
            position: 1,
            exerciseId: 201,
            restSecs: 0,
            mode: CardioBaseMode.time,
            quantity: 120,
            exercise: _runExercise,
          ),
        ],
      ),
      WorkoutCardioSetDto(
        id: 702,
        position: 2,
        setType: CardioSetType.constant,
        restSecs: 0,
        rounds: 1,
        exercises: [
          WorkoutCardioSetExerciseDto(
            id: 712,
            position: 1,
            exerciseId: 202,
            restSecs: 0,
            mode: CardioBaseMode.units,
            quantity: 500,
            exercise: _rowExercise,
          ),
        ],
      ),
    ],
  );
}

WorkoutRecordDto _buildCardioRecord(WorkoutDto workout) {
  final start = DateTime(2026, 6, 10, 9, 0);
  final end = DateTime(2026, 6, 10, 9, 25);
  return WorkoutRecordDto(
    id: 901,
    workoutId: workout.id,
    version: workout.version,
    currentSetPosition: 1,
    currentSetNumber: 1,
    currentExercisePosition: 0,
    totalSets: 2,
    totalReps: 0,
    totalRestSecs: 45,
    totalVolume: 0,
    muscles: const TargetMuscles(primary: {}, secondary: {}),
    startedAt: start,
    completedAt: end,
    workout: workout,
    cardioSetRecords: [
      WorkoutCardioSetRecordDto(
        id: 801,
        workoutCardioSetId: 701,
        roundNumber: 1,
        totalRestSecs: 45,
        startedAt: start,
        completedAt: start.add(const Duration(minutes: 2)),
        exerciseRecords: const [
          WorkoutCardioSetExerciseRecordDto(
            id: 811,
            workoutCardioSetExerciseId: 711,
            exerciseId: 201,
            position: 1,
            mode: CardioBaseMode.time,
            quantity: 120,
            durationSecs: 120,
            restSecs: 0,
            rpe: 7,
            exercise: _runExercise,
          ),
        ],
      ),
      WorkoutCardioSetRecordDto(
        id: 802,
        workoutCardioSetId: 702,
        roundNumber: 1,
        totalRestSecs: 0,
        startedAt: start.add(const Duration(minutes: 3)),
        completedAt: end,
        exerciseRecords: const [
          WorkoutCardioSetExerciseRecordDto(
            id: 812,
            workoutCardioSetExerciseId: 712,
            exerciseId: 202,
            position: 1,
            mode: CardioBaseMode.units,
            quantity: 520,
            durationSecs: 115,
            restSecs: 0,
            rpe: 9,
            exercise: _rowExercise,
          ),
        ],
      ),
    ],
  );
}

class _LoggedCardioCall {
  final int position;
  final CardioBaseMode mode;
  final int quantity;
  final int durationSecs;
  final int roundNumber;
  final int rpe;
  final int exerciseRestSecs;
  final int? roundRestSecs;
  final bool markRoundCompleted;

  const _LoggedCardioCall({
    required this.position,
    required this.mode,
    required this.quantity,
    required this.durationSecs,
    required this.roundNumber,
    required this.rpe,
    required this.exerciseRestSecs,
    required this.roundRestSecs,
    required this.markRoundCompleted,
  });
}

class _FakeActiveWorkoutCubit extends ActiveWorkoutCubit {
  final WorkoutDto workout;
  final List<_LoggedCardioCall> loggedCalls = [];
  int completedCount = 0;

  _FakeActiveWorkoutCubit(this.workout)
    : super(
        workoutRepository: WorkoutRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
      );

  @override
  Future<void> startWorkout(
    int workoutId, {
    int? workoutPlanRecordId,
    int? week,
    int? day,
    int? workoutPosition,
  }) async {
    emit(
      ActiveWorkoutState.initial().copyWith(
        workout: Nullable(workout),
        workoutRecord: Nullable(
          WorkoutRecordDto(
            id: 500,
            workoutId: workout.id,
            version: workout.version,
            currentSetPosition: 0,
            currentSetNumber: 1,
            currentExercisePosition: 0,
            totalSets: 0,
            totalReps: 0,
            totalRestSecs: 0,
            totalVolume: 0,
            muscles: const TargetMuscles(primary: {}, secondary: {}),
            startedAt: DateTime(2026, 6, 10, 9, 0),
          ),
        ),
        isLoading: false,
      ),
    );
  }

  @override
  Future<void> logCardioExerciseSet({
    required int position,
    required CardioBaseMode mode,
    required int quantity,
    required int durationSecs,
    required int roundNumber,
    required int rpe,
    int exerciseRestSecs = 0,
    int? roundRestSecs,
    bool markRoundCompleted = false,
  }) async {
    loggedCalls.add(
      _LoggedCardioCall(
        position: position,
        mode: mode,
        quantity: quantity,
        durationSecs: durationSecs,
        roundNumber: roundNumber,
        rpe: rpe,
        exerciseRestSecs: exerciseRestSecs,
        roundRestSecs: roundRestSecs,
        markRoundCompleted: markRoundCompleted,
      ),
    );
  }

  @override
  Future<void> completeWorkout() async {
    completedCount++;
    emit(state.copyWith(isCompleted: true, isLoading: false, isResting: false));
  }
}

class _FakeWorkoutCubit extends WorkoutCubit {
  final WorkoutDto workout;

  _FakeWorkoutCubit(this.workout)
    : super(workoutRepository: WorkoutRepository.create()) {
    emit(state.copyWith(selectedWorkout: Nullable(workout)));
  }

  @override
  Future<void> getWorkout(int id, {int? version, bool refresh = false}) async {
    emit(state.copyWith(selectedWorkout: Nullable(workout), isLoading: false));
  }
}

class _FakeWorkoutRecordCubit extends WorkoutRecordCubit {
  final WorkoutRecordDto record;
  WorkoutRecordBatchInput? lastCreatedBatch;
  WorkoutRecordBatchInput? lastUpdatedBatch;

  _FakeWorkoutRecordCubit(this.record)
    : super(workoutRecordRepository: WorkoutRecordRepository.create()) {
    emit(
      state.copyWith(
        latestWorkoutRecord: Nullable(record),
        workoutRecords: [record],
        selectedWorkoutRecord: Nullable(record),
        isLoadingLatest: false,
        isLoadingRecords: false,
        isLoading: false,
      ),
    );
  }

  @override
  Future<void> getLatestWorkoutRecord({
    int? workoutId,
    bool skipSkipped = false,
  }) async {}

  @override
  Future<void> getWorkoutRecords({
    int? workoutId,
    (DateTime, DateTime)? dateRange,
    bool? skipSkipped,
    int? limit,
    int? offset,
  }) async {}

  @override
  Future<void> getWorkoutRecord(int id) async {
    emit(
      state.copyWith(selectedWorkoutRecord: Nullable(record), isLoading: false),
    );
  }

  @override
  Future<WorkoutRecordDto?> batchCreateWorkoutRecord(
    WorkoutRecordBatchInput input,
  ) async {
    lastCreatedBatch = input;
    emit(state.copyWith(error: const Nullable(null), isLoading: false));
    return record;
  }

  @override
  Future<void> batchUpdateWorkoutRecord(
    int id,
    WorkoutRecordBatchInput input,
  ) async {
    lastUpdatedBatch = input;
    emit(state.copyWith(error: const Nullable(null), isLoading: false));
  }
}

void main() {
  group('ActiveWorkoutScreen cardio flows', () {
    testWidgets(
      'runs time-based circular timer, rest timer, units-based elapsed time with editable units, and auto-completes',
      (tester) async {
        final workout = _buildCardioWorkout();
        final activeCubit = _FakeActiveWorkoutCubit(workout);
        final profileCubit = ProfileCubit(
          profileRepository: ProfileRepository.create(),
        );
        addTearDown(activeCubit.close);
        addTearDown(profileCubit.close);

        final router = GoRouter(
          initialLocation: '/workouts/77/active',
          routes: [
            GoRoute(
              path: '/workouts/:id',
              builder: (_, _) => const Scaffold(body: Text('Workout Detail')),
            ),
            GoRoute(
              path: '/workouts/:id/active',
              builder: (_, _) => const ActiveWorkoutScreen(workoutId: 77),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ActiveWorkoutCubit>.value(value: activeCubit),
              BlocProvider<ProfileCubit>.value(value: profileCubit),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        // Step 1: Time-based exercise renders circular progress timer
        expect(find.byType(ActiveCardioExerciseCard), findsOneWidget);
        expect(find.byType(ActiveCardioTimeExercise), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.textContaining('Round 1 of 2'), findsOneWidget);
        expect(find.text('00:00'), findsOneWidget);

        // Advance timer by 3 seconds, pause, advance 2 more (must stay 00:03)
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('00:03'), findsOneWidget);

        await tester.ensureVisible(find.text('PAUSE'));
        await tester.tap(find.text('PAUSE'));
        await tester.pump();
        expect(find.text('Paused'), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        expect(find.text('00:03'), findsOneWidget);

        // Complete step 1 -> transitions into ActiveRestTimer (45s configured)
        await tester.ensureVisible(find.text('COMPLETE & NEXT'));
        await tester.tap(find.text('COMPLETE & NEXT'));
        await tester.pump();

        expect(activeCubit.loggedCalls, hasLength(1));
        expect(activeCubit.loggedCalls.first.mode, CardioBaseMode.time);
        expect(activeCubit.loggedCalls.first.durationSecs, 3);
        expect(activeCubit.loggedCalls.first.rpe, 8);
        expect(find.byType(ActiveRestTimer), findsOneWidget);

        // Advance rest by 2s and tap Next -> persists rest and shows units exercise
        await tester.pump(const Duration(seconds: 2));
        await tester.ensureVisible(find.text('Next'));
        await tester.tap(find.text('Next'));
        await tester.pump();

        expect(activeCubit.loggedCalls, hasLength(2));
        expect(activeCubit.loggedCalls[1].roundRestSecs, 2);

        // Step 2: Units-based exercise renders live elapsed timer + prefilled units
        expect(find.byType(ActiveCardioUnitsExercise), findsOneWidget);
        expect(find.text('Elapsed Time'), findsOneWidget);
        expect(find.text('500'), findsWidgets);

        await tester.pump(const Duration(seconds: 4));
        expect(find.text('00:04'), findsOneWidget);

        // Invalid quantity (0) shows SnackBar and blocks completion
        await tester.enterText(find.byType(TextFormField).first, '0');
        await tester.ensureVisible(find.text('FINISH WORKOUT'));
        await tester.tap(find.text('FINISH WORKOUT'));
        await tester.pump();
        expect(
          find.text('Please enter a valid completed amount'),
          findsOneWidget,
        );
        expect(activeCubit.completedCount, 0);

        // Valid updated quantity completes workout
        await tester.enterText(find.byType(TextFormField).first, '550');
        await tester.ensureVisible(find.text('FINISH WORKOUT'));
        await tester.tap(find.text('FINISH WORKOUT'));
        await tester.pumpAndSettle();

        expect(activeCubit.loggedCalls, hasLength(3));
        expect(activeCubit.loggedCalls[2].mode, CardioBaseMode.units);
        expect(activeCubit.loggedCalls[2].quantity, 550);
        expect(
          activeCubit.loggedCalls[2].durationSecs,
          greaterThanOrEqualTo(4),
        );
        expect(activeCubit.completedCount, 1);
      },
    );
  });

  group('Cardio history and manual record screens', () {
    testWidgets(
      'WorkoutHistoryScreen and WorkoutHistoryDetailScreen render cardio metrics and rounds',
      (tester) async {
        final workout = _buildCardioWorkout();
        final record = _buildCardioRecord(workout);
        final workoutCubit = _FakeWorkoutCubit(workout);
        final recordCubit = _FakeWorkoutRecordCubit(record);
        final profileCubit = ProfileCubit(
          profileRepository: ProfileRepository.create(),
        );
        addTearDown(workoutCubit.close);
        addTearDown(recordCubit.close);
        addTearDown(profileCubit.close);

        // History screen
        final historyRouter = GoRouter(
          initialLocation: '/history',
          routes: [
            GoRoute(
              path: '/history',
              builder: (_, _) =>
                  const WorkoutHistoryScreen(workoutId: 77, version: 1),
            ),
          ],
        );
        addTearDown(historyRouter.dispose);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WorkoutCubit>.value(value: workoutCubit),
              BlocProvider<WorkoutRecordCubit>.value(value: recordCubit),
              BlocProvider<ProfileCubit>.value(value: profileCubit),
            ],
            child: MaterialApp.router(routerConfig: historyRouter),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Rounds', findRichText: true), findsWidgets);
        expect(find.textContaining('Volume', findRichText: true), findsNothing);
        expect(find.textContaining('Reps', findRichText: true), findsNothing);

        // Detail screen
        final detailRouter = GoRouter(
          initialLocation: '/detail',
          routes: [
            GoRoute(
              path: '/detail',
              builder: (_, _) => const WorkoutHistoryDetailScreen(
                workoutId: 77,
                workoutRecordId: 901,
                version: 1,
              ),
            ),
          ],
        );
        addTearDown(detailRouter.dispose);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WorkoutCubit>.value(value: workoutCubit),
              BlocProvider<WorkoutRecordCubit>.value(value: recordCubit),
              BlocProvider<ProfileCubit>.value(value: profileCubit),
            ],
            child: MaterialApp.router(routerConfig: detailRouter),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(WorkoutCardioRecordSets), findsOneWidget);
        expect(find.text('Outdoor Running'), findsOneWidget);
        expect(find.text('7 RPE'), findsOneWidget);
        expect(find.textContaining('Volume', findRichText: true), findsNothing);
      },
    );

    testWidgets(
      'CreateWorkoutRecordScreen and UpdateWorkoutRecordScreen submit cardio batch inputs',
      (tester) async {
        final workout = _buildCardioWorkout();
        final record = _buildCardioRecord(workout);
        final workoutCubit = _FakeWorkoutCubit(workout);
        final recordCubit = _FakeWorkoutRecordCubit(record);
        final profileCubit = ProfileCubit(
          profileRepository: ProfileRepository.create(),
        );
        addTearDown(workoutCubit.close);
        addTearDown(recordCubit.close);
        addTearDown(profileCubit.close);

        final createRouter = GoRouter(
          initialLocation: '/back/create',
          routes: [
            GoRoute(
              path: '/back',
              builder: (_, _) => const Scaffold(body: Text('Back')),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (_, _) => const CreateWorkoutRecordScreen(
                    workoutId: 77,
                    version: 1,
                  ),
                ),
              ],
            ),
          ],
        );
        addTearDown(createRouter.dispose);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WorkoutCubit>.value(value: workoutCubit),
              BlocProvider<WorkoutRecordCubit>.value(value: recordCubit),
              BlocProvider<ProfileCubit>.value(value: profileCubit),
            ],
            child: MaterialApp.router(routerConfig: createRouter),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Outdoor Running'), findsOneWidget);
        expect(find.text('Concept2 Rowing'), findsOneWidget);

        await tester.ensureVisible(find.text('SAVE WORKOUT RECORD'));
        await tester.tap(find.text('SAVE WORKOUT RECORD'));
        await tester.pumpAndSettle();

        expect(recordCubit.lastCreatedBatch, isNotNull);
        expect(recordCubit.lastCreatedBatch!.cardioSets, hasLength(2));
        expect(recordCubit.lastCreatedBatch!.sets, isEmpty);

        // Update screen
        final updateRouter = GoRouter(
          initialLocation: '/back/update',
          routes: [
            GoRoute(
              path: '/back',
              builder: (_, _) => const Scaffold(body: Text('Back')),
              routes: [
                GoRoute(
                  path: 'update',
                  builder: (_, _) => const UpdateWorkoutRecordScreen(
                    workoutId: 77,
                    workoutRecordId: 901,
                    version: 1,
                  ),
                ),
              ],
            ),
          ],
        );
        addTearDown(updateRouter.dispose);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WorkoutCubit>.value(value: workoutCubit),
              BlocProvider<WorkoutRecordCubit>.value(value: recordCubit),
              BlocProvider<ProfileCubit>.value(value: profileCubit),
            ],
            child: MaterialApp.router(
              key: const ValueKey('update-record-app'),
              routerConfig: updateRouter,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('520'), findsWidgets);
        await tester.ensureVisible(find.text('SAVE WORKOUT RECORD'));
        await tester.tap(find.text('SAVE WORKOUT RECORD'));
        await tester.pumpAndSettle();

        expect(recordCubit.lastUpdatedBatch, isNotNull);
        expect(recordCubit.lastUpdatedBatch!.cardioSets, hasLength(2));
        expect(
          recordCubit.lastUpdatedBatch!.cardioSets[1].exercises.first.quantity,
          520,
        );
      },
    );

    testWidgets(
      'active cardio, history, detail, and record forms render without overflow at 320px width and 200% text scaling',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final workout = _buildCardioWorkout();
        final record = _buildCardioRecord(workout);
        final activeCubit = _FakeActiveWorkoutCubit(workout);
        final workoutCubit = _FakeWorkoutCubit(workout);
        final recordCubit = _FakeWorkoutRecordCubit(record);
        final profileCubit = ProfileCubit(
          profileRepository: ProfileRepository.create(),
        );
        addTearDown(activeCubit.close);
        addTearDown(workoutCubit.close);
        addTearDown(recordCubit.close);
        addTearDown(profileCubit.close);

        Future<void> pumpScaled(Widget screen) async {
          final router = GoRouter(
            initialLocation: '/test',
            routes: [GoRoute(path: '/test', builder: (_, _) => screen)],
          );
          addTearDown(router.dispose);

          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<ActiveWorkoutCubit>.value(value: activeCubit),
                BlocProvider<WorkoutCubit>.value(value: workoutCubit),
                BlocProvider<WorkoutRecordCubit>.value(value: recordCubit),
                BlocProvider<ProfileCubit>.value(value: profileCubit),
              ],
              child: MaterialApp.router(
                key: UniqueKey(),
                routerConfig: router,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2.0)),
                  child: child!,
                ),
              ),
            ),
          );
          await tester.pump();
          final exception = tester.takeException();
          expect(
            exception,
            isNull,
            reason: exception is FlutterError
                ? exception.toStringDeep()
                : exception?.toString(),
          );
        }

        // Active cardio (time-based)
        await pumpScaled(const ActiveWorkoutScreen(workoutId: 77));

        // Active cardio (units-based)
        activeCubit.nextExercise();
        await tester.pump();
        expect(tester.takeException(), isNull);

        // History, Detail, Create Record, Update Record
        await pumpScaled(const WorkoutHistoryScreen(workoutId: 77, version: 1));
        await pumpScaled(
          const WorkoutHistoryDetailScreen(
            workoutId: 77,
            workoutRecordId: 901,
            version: 1,
          ),
        );
        await pumpScaled(
          const CreateWorkoutRecordScreen(workoutId: 77, version: 1),
        );
        await pumpScaled(
          const UpdateWorkoutRecordScreen(
            workoutId: 77,
            workoutRecordId: 901,
            version: 1,
          ),
        );
      },
    );
  });
}
