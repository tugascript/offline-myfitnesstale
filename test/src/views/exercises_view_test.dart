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
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/exercise_details.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/core/widgets/favourite_checkbox.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercises_list_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/states/exercise_state.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/cardio_exercise_search_form.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/details/create_exercise_modal.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/exercise_card.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/exercises_list.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _GetExercisesCall {
  final String? name;
  final ExerciseType type;
  final MuscleGroup? muscleGroup;
  final CardioBaseMode? cardioBaseMode;
  final CardioUnitType? cardioUnitType;
  final Difficulty? difficulty;
  final int? equipmentId;
  final bool isFavourite;
  final CreatedBy? createdBy;

  const _GetExercisesCall({
    required this.name,
    required this.type,
    required this.muscleGroup,
    required this.cardioBaseMode,
    required this.cardioUnitType,
    required this.difficulty,
    required this.equipmentId,
    required this.isFavourite,
    required this.createdBy,
  });
}

class _ExerciseSearchCubit extends ExerciseCubit {
  int equipmentFetchCount = 0;
  final equipmentFetchStarted = Completer<void>();
  final releaseEquipmentFetch = Completer<void>();
  final bool blockEquipmentFetch;
  final List<_GetExercisesCall> getExercisesCalls = [];
  Completer<void>? pendingExercisesFetch;
  List<ExerciseDto>? nextExercises;

  _ExerciseSearchCubit({
    this.blockEquipmentFetch = true,
    List<ExerciseDto> initialExercises = const [],
    ExercisePagination? initialPagination,
  }) : super(exerciseRepository: ExerciseRepository.create()) {
    emit(
      state.copyWith(
        equipmentSelection: const {1: 'Barbell', 2: 'Treadmill'},
        exercises: initialExercises,
        exercisePagination:
            initialPagination ??
            state.exercisePagination.copyWith(total: initialExercises.length),
      ),
    );
  }

  @override
  Future<void> getSelectionEquipments() async {
    equipmentFetchCount += 1;
    if (!equipmentFetchStarted.isCompleted) {
      equipmentFetchStarted.complete();
    }
    if (blockEquipmentFetch) {
      await releaseEquipmentFetch.future;
      emit(
        state.copyWith(
          equipmentSelection: const {1: 'Barbell', 2: 'Cable Machine'},
        ),
      );
    }
  }

  @override
  Future<void> getExercises({
    String? name,
    ExerciseType type = ExerciseType.strength,
    MuscleGroup? muscleGroup,
    CardioBaseMode? cardioBaseMode,
    CardioUnitType? cardioUnitType,
    Difficulty? difficulty,
    int? equipmentId,
    int? limit,
    int? offset,
    bool isFavourite = false,
    CreatedBy? createdBy,
  }) async {
    final effectiveMuscleGroup = type == ExerciseType.strength
        ? muscleGroup
        : null;
    final effectiveCardioBaseMode = type == ExerciseType.cardio
        ? cardioBaseMode
        : null;
    final effectiveCardioUnitType = type == ExerciseType.cardio
        ? cardioUnitType
        : null;

    getExercisesCalls.add(
      _GetExercisesCall(
        name: name,
        type: type,
        muscleGroup: effectiveMuscleGroup,
        cardioBaseMode: effectiveCardioBaseMode,
        cardioUnitType: effectiveCardioUnitType,
        difficulty: difficulty,
        equipmentId: equipmentId,
        isFavourite: isFavourite,
        createdBy: createdBy,
      ),
    );

    final query = ExercisePagination(
      name: name ?? '',
      type: type,
      muscleGroup: effectiveMuscleGroup,
      cardioBaseMode: effectiveCardioBaseMode,
      cardioUnitType: effectiveCardioUnitType,
      difficulty: difficulty,
      equipmentId: equipmentId,
      isFavorite: isFavourite,
      createdBy: createdBy,
      limit: limit ?? state.exercisePagination.limit,
      offset: offset ?? 0,
      total: 0,
    );

    if (pendingExercisesFetch != null) {
      emit(state.copyWith(pendingExercisesQuery: Nullable(query)));
      await pendingExercisesFetch!.future;
      if (isClosed) return;
    }

    emit(
      state.copyWith(
        exercises: nextExercises ?? state.exercises,
        exercisePagination: query.copyWith(
          total: (nextExercises ?? state.exercises).length,
        ),
        pendingExercisesQuery: const Nullable(null),
      ),
    );
  }

  void emitError(ErrorState error) {
    emit(state.copyWith(error: Nullable(error)));
  }
}

void main() {
  testWidgets('refreshes equipment choices when exercise search opens', (
    tester,
  ) async {
    final cubit = _ExerciseSearchCubit();
    addTearDown(cubit.close);

    final router = GoRouter(
      initialLocation: Routes.exercises.name,
      routes: [
        GoRoute(
          path: Routes.exercises.name,
          builder: (_, _) => const ExercisesListScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<ExerciseCubit>.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await cubit.equipmentFetchStarted.future;

    expect(cubit.equipmentFetchCount, 1);
    expect(find.text('Cable Machine'), findsNothing);

    final fetchedState = cubit.stream.firstWhere(
      (state) => state.equipmentSelection.containsValue('Cable Machine'),
    );
    cubit.releaseEquipmentFetch.complete();
    await fetchedState;
    await tester.pump();

    await tester.tap(find.text('All Equipment'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Barbell'), findsOneWidget);
    expect(find.text('Cable Machine'), findsOneWidget);
  });

  testWidgets(
    'toggles between Strength and Cardio search UI, preserves shared filters, submits cardio filters, and defaults create modal to Cardio',
    (tester) async {
      final cubit = _ExerciseSearchCubit(
        blockEquipmentFetch: false,
        initialPagination: const ExercisePagination(
          name: 'Run',
          type: ExerciseType.strength,
          muscleGroup: MuscleGroup.legs,
          difficulty: Difficulty.intermediate,
          equipmentId: 2,
          isFavorite: true,
          createdBy: CreatedBy.user,
          total: 0,
          limit: 20,
          offset: 0,
        ),
      );
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: Routes.exercises.name,
        routes: [
          GoRoute(
            path: Routes.exercises.name,
            builder: (_, _) => const ExercisesListScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('strength-exercise-search-form')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('cardio-exercise-search-form')),
        findsNothing,
      );

      // Toggle to Cardio.
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('exercise-search-type-toggle')),
          matching: find.text('Cardio'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('cardio-exercise-search-form')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('strength-exercise-search-form')),
        findsNothing,
      );

      final toggleCall = cubit.getExercisesCalls.last;
      expect(toggleCall.type, ExerciseType.cardio);
      expect(toggleCall.name, 'Run');
      expect(toggleCall.difficulty, Difficulty.intermediate);
      expect(toggleCall.equipmentId, 2);
      expect(toggleCall.isFavourite, isTrue);
      expect(toggleCall.createdBy, CreatedBy.user);
      expect(toggleCall.muscleGroup, isNull);

      // Pick Cardio Default Mode = Units and Unit Type = Action, then search.
      await tester.tap(
        find.byKey(const ValueKey('cardio-search-mode-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Units').last);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('cardio-search-unit-type-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Action').last);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CardioExerciseSearchForm),
          matching: find.byIcon(Icons.search).last,
        ),
      );
      await tester.pumpAndSettle();

      final searchCall = cubit.getExercisesCalls.last;
      expect(searchCall.type, ExerciseType.cardio);
      expect(searchCall.cardioBaseMode, CardioBaseMode.units);
      expect(searchCall.cardioUnitType, CardioUnitType.action);

      // Opening FAB while Cardio is active defaults CreateExerciseModal to Cardio.
      await tester.tap(find.byKey(const ValueKey('exercise-add')));
      await tester.pumpAndSettle();

      expect(find.byType(CreateExerciseModal), findsOneWidget);
      expect(
        find.byKey(const ValueKey('exercise-form-cardio-unit')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Cardio search screen fits 320px width at 200% text scaling without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cubit = _ExerciseSearchCubit(
        blockEquipmentFetch: false,
        initialExercises: const [
          ExerciseDto(
            id: 50,
            name: 'Treadmill Interval Sprint',
            description: 'High intensity intervals',
            details: CardioExerciseDetails(
              defaultMode: CardioBaseMode.time,
              unitType: CardioUnitType.distance,
              unit: 'km',
            ),
            difficulty: Difficulty.intermediate,
            createdBy: CreatedBy.user,
          ),
        ],
        initialPagination: const ExercisePagination(
          name: '',
          type: ExerciseType.cardio,
          isFavorite: false,
          total: 1,
          limit: 20,
          offset: 0,
        ),
      );
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: Routes.exercises.name,
        routes: [
          GoRoute(
            path: Routes.exercises.name,
            builder: (_, _) => const ExercisesListScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2.0)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('cardio-exercise-search-form')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Strength to Cardio toggle hides stale strength items behind Skeletonizer while offset-0 reload is in flight',
    (tester) async {
      final fetchCompleter = Completer<void>();
      final cubit =
          _ExerciseSearchCubit(
              blockEquipmentFetch: false,
              initialExercises: const [
                ExerciseDto(
                  id: 1,
                  name: 'Bench Press',
                  description: 'Chest press',
                  details: StrengthExerciseDetails(
                    muscleGroup: MuscleGroup.push,
                    muscles: TargetMuscles(
                      primary: {Muscle.chest},
                      secondary: {},
                    ),
                    weightProgress: ExerciseWeightProgress.positive,
                  ),
                  difficulty: Difficulty.intermediate,
                  createdBy: CreatedBy.system,
                ),
              ],
            )
            ..pendingExercisesFetch = fetchCompleter
            ..nextExercises = const [
              ExerciseDto(
                id: 2,
                name: 'Outdoor Run',
                description: 'Steady run',
                details: CardioExerciseDetails(
                  defaultMode: CardioBaseMode.time,
                  unitType: CardioUnitType.distance,
                  unit: 'km',
                ),
                difficulty: Difficulty.beginner,
                createdBy: CreatedBy.user,
              ),
            ];
      addTearDown(cubit.close);

      var pushedExerciseDetail = false;
      final router = GoRouter(
        initialLocation: Routes.exercises.name,
        routes: [
          GoRoute(
            path: Routes.exercises.name,
            builder: (_, _) => const ExercisesListScreen(),
          ),
          GoRoute(
            path: '/exercises/:id',
            builder: (_, _) {
              pushedExerciseDetail = true;
              return const Scaffold(body: Text('Exercise Detail'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);

      // Toggle to Cardio while the fetch is pending.
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('exercise-search-type-toggle')),
          matching: find.text('Cardio'),
        ),
      );
      await tester.pump();

      // Stale Strength card is hidden, Skeletonizer is active with 3 placeholder cards,
      // and tapping a placeholder does not navigate.
      expect(find.text('Bench Press'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(ExercisesList),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(ExercisesList),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled,
          ),
        ),
        findsOneWidget,
      );
      expect(find.byType(ExerciseCard), findsNWidgets(3));

      await tester.tap(find.byType(ExerciseCard).first);
      await tester.pump();
      expect(pushedExerciseDetail, isFalse);

      // Complete the Cardio reload and verify Cardio results appear.
      fetchCompleter.complete();
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ExercisesList),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled,
          ),
        ),
        findsNothing,
      );
      expect(find.text('Outdoor Run'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
    },
  );

  testWidgets(
    'FAB opens CreateExerciseModal with Cardio type while Strength to Cardio reload is in flight',
    (tester) async {
      final fetchCompleter = Completer<void>();
      final cubit = _ExerciseSearchCubit(blockEquipmentFetch: false);
      addTearDown(() {
        if (!fetchCompleter.isCompleted) {
          fetchCompleter.complete();
        }
        return cubit.close();
      });

      final router = GoRouter(
        initialLocation: Routes.exercises.name,
        routes: [
          GoRoute(
            path: Routes.exercises.name,
            builder: (_, _) => const ExercisesListScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      cubit.pendingExercisesFetch = fetchCompleter;

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('exercise-search-type-toggle')),
          matching: find.text('Cardio'),
        ),
      );
      await tester.pump();

      expect(cubit.state.exercisePagination.type, ExerciseType.strength);
      expect(cubit.state.pendingExercisesQuery?.type, ExerciseType.cardio);

      await tester.tap(find.byKey(const ValueKey('exercise-add')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CreateExerciseModal), findsOneWidget);
      expect(
        find.byKey(const ValueKey('exercise-form-cardio-unit')),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows error snackbar even when a list query is still loading', (
    tester,
  ) async {
    final fetchCompleter = Completer<void>();
    final cubit = _ExerciseSearchCubit(blockEquipmentFetch: false);
    addTearDown(() {
      if (!fetchCompleter.isCompleted) {
        fetchCompleter.complete();
      }
      return cubit.close();
    });

    final router = GoRouter(
      initialLocation: Routes.exercises.name,
      routes: [
        GoRoute(
          path: Routes.exercises.name,
          builder: (_, _) => const ExercisesListScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<ExerciseCubit>.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    cubit.pendingExercisesFetch = fetchCompleter;

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('exercise-search-type-toggle')),
        matching: find.text('Cardio'),
      ),
    );
    await tester.pump();

    expect(cubit.state.isLoading, isTrue);

    cubit.emitError(
      const ErrorState(
        type: 'FetchFailed',
        description: 'Failed to load exercises',
      ),
    );
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Failed to load exercises'), findsOneWidget);
  });

  testWidgets(
    'preserves unsubmitted shared search filter edits when toggling between Strength and Cardio',
    (tester) async {
      final cubit = _ExerciseSearchCubit(blockEquipmentFetch: false);
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: Routes.exercises.name,
        routes: [
          GoRoute(
            path: Routes.exercises.name,
            builder: (_, _) => const ExercisesListScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Edit shared filters on Strength form without tapping Search.
      await tester.enterText(find.byType(TextFormField), 'Sprint');
      await tester.pump();

      await tester.tap(find.byType(HeartCheckbox));
      await tester.pump();

      await tester.tap(find.text('All Difficulties'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Intermediate').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('All Equipment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Treadmill').last);
      await tester.pumpAndSettle();

      // Toggle to Cardio without pressing Search first.
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('exercise-search-type-toggle')),
          matching: find.text('Cardio'),
        ),
      );
      await tester.pumpAndSettle();

      final toCardioCall = cubit.getExercisesCalls.last;
      expect(toCardioCall.type, ExerciseType.cardio);
      expect(toCardioCall.name, 'Sprint');
      expect(toCardioCall.difficulty, Difficulty.intermediate);
      expect(toCardioCall.equipmentId, 2);
      expect(toCardioCall.isFavourite, isTrue);

      final cardioField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(cardioField.controller?.text, 'Sprint');
      expect(
        tester.widget<HeartCheckbox>(find.byType(HeartCheckbox)).value,
        isTrue,
      );
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Treadmill'), findsOneWidget);

      // Edit shared filters on Cardio form without pressing Search.
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'Row');
      await tester.pump();

      await tester.tap(find.byType(HeartCheckbox));
      await tester.pump();

      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced').last);
      await tester.pumpAndSettle();

      // Toggle back to Strength without pressing Search first.
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('exercise-search-type-toggle')),
          matching: find.text('Strength'),
        ),
      );
      await tester.pumpAndSettle();

      final toStrengthCall = cubit.getExercisesCalls.last;
      expect(toStrengthCall.type, ExerciseType.strength);
      expect(toStrengthCall.name, 'Row');
      expect(toStrengthCall.difficulty, Difficulty.advanced);
      expect(toStrengthCall.equipmentId, 2);
      expect(toStrengthCall.isFavourite, isFalse);

      final strengthField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(strengthField.controller?.text, 'Row');
      expect(
        tester.widget<HeartCheckbox>(find.byType(HeartCheckbox)).value,
        isFalse,
      );
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.text('Treadmill'), findsOneWidget);
    },
  );
}
