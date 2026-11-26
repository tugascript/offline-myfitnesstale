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
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_cardio_set_exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_upsert_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/exercise_details.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/utils/converters.dart';
import 'package:myfitnesstale/src/ui/core/widgets/created_by_checkbox.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_detail_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_edit_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workouts_list_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/states/workout_state.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/cardio_editor/cardio_editor.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/create_workout_modal.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/workout_base_form.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _GetWorkoutsCall {
  final String? name;
  final Difficulty? difficulty;
  final MuscleGroup? muscleGroup;
  final bool isFavorite;
  final CreatedBy? createdBy;
  final ExerciseType type;
  final int? limit;
  final int? offset;

  const _GetWorkoutsCall({
    required this.name,
    required this.difficulty,
    required this.muscleGroup,
    required this.isFavorite,
    required this.createdBy,
    required this.type,
    required this.limit,
    required this.offset,
  });
}

class _FakeWorkoutCubit extends WorkoutCubit {
  final List<_GetWorkoutsCall> getWorkoutsCalls = [];
  final List<WorkoutInput> createdInputs = [];
  final List<List<WorkoutCardioSetUpsertInput>> savedCardioSets = [];
  final List<WorkoutDto> workoutsToEmit;

  _FakeWorkoutCubit({
    WorkoutDto? initialSelectedWorkout,
    this.workoutsToEmit = const [],
    ExerciseType initialType = ExerciseType.strength,
  }) : super(workoutRepository: WorkoutRepository.create()) {
    if (initialSelectedWorkout != null ||
        initialType != ExerciseType.strength) {
      emit(
        state.copyWith(
          selectedWorkout: Nullable(initialSelectedWorkout),
          workouts: initialType == ExerciseType.cardio
              ? workoutsToEmit
              : const [],
          pagination: state.pagination.copyWith(
            type: initialType,
            total: workoutsToEmit.length,
          ),
        ),
      );
    }
  }

  @override
  Future<void> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    int? limit,
    int? offset,
    bool isFavorite = false,
    CreatedBy? createdBy,
    ExerciseType type = ExerciseType.strength,
  }) async {
    getWorkoutsCalls.add(
      _GetWorkoutsCall(
        name: name,
        difficulty: difficulty,
        muscleGroup: muscleGroup,
        isFavorite: isFavorite,
        createdBy: createdBy,
        type: type,
        limit: limit,
        offset: offset,
      ),
    );
    emit(
      state.copyWith(
        workouts: workoutsToEmit,
        isLoading: false,
        error: const Nullable(null),
        pendingWorkoutsQuery: const Nullable(null),
        pagination: WorkoutPagination(
          name: name ?? '',
          difficulty: difficulty,
          muscleGroup: type == ExerciseType.cardio ? null : muscleGroup,
          isFavorite: isFavorite,
          createdBy: createdBy,
          type: type,
          offset: offset ?? 0,
          limit: limit ?? 20,
          total: workoutsToEmit.length,
        ),
      ),
    );
  }

  @override
  Future<void> getWorkout(int id, {int? version, bool refresh = false}) async {
    emit(state.copyWith(isLoading: false, error: const Nullable(null)));
  }

  @override
  Future<void> createWorkout(WorkoutInput input) async {
    createdInputs.add(input);
    emit(
      state.copyWith(
        selectedWorkout: Nullable(
          WorkoutDto(
            id: 99,
            name: input.name,
            muscleGroups: const {},
            muscles: const TargetMuscles(primary: {}, secondary: {}),
            difficulty: input.difficulty,
            version: 1,
            isFavorite: input.isFavorite,
            totalSets: 0,
            totalReps: 0,
            editorType: input.editorType,
            createdBy: CreatedBy.user,
            cardioSets: input.editorType == EditorType.cardio ? const [] : null,
          ),
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  @override
  Future<void> batchUpsertCardioWorkoutSets({
    required int workoutId,
    required List<WorkoutCardioSetUpsertInput> sets,
  }) async {
    savedCardioSets.add(sets);
    emit(state.copyWith(isLoading: false, error: const Nullable(null)));
  }
}

class _FakeExerciseCubit extends ExerciseCubit {
  final List<ExerciseType?> requestedTypes = [];
  final List<ExerciseDto> cardioExercises;

  _FakeExerciseCubit({required this.cardioExercises})
    : super(exerciseRepository: ExerciseRepository.create());

  @override
  Future<void> getSelectionExercises({
    ExerciseType? type,
    MuscleGroup? muscleGroup,
    CardioBaseMode? cardioBaseMode,
    CardioUnitType? cardioUnitType,
    String name = '',
    bool isFavorite = false,
  }) async {
    requestedTypes.add(type);
    emit(
      state.copyWith(
        exerciseSelection: cardioExercises,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}

const _runningExercise = ExerciseDto(
  id: 101,
  name: 'Outdoor Running',
  description: 'Steady aerobic running',
  details: CardioExerciseDetails(
    defaultMode: CardioBaseMode.time,
    unitType: CardioUnitType.distance,
    unit: 'km',
  ),
  createdBy: CreatedBy.system,
);

const _rowingExercise = ExerciseDto(
  id: 102,
  name: 'Concept2 Rowing',
  description: 'High intensity rowing',
  details: CardioExerciseDetails(
    defaultMode: CardioBaseMode.units,
    unitType: CardioUnitType.distance,
    unit: 'm',
  ),
  createdBy: CreatedBy.system,
);

WorkoutDto _buildSampleCardioWorkout({
  int id = 55,
  CreatedBy createdBy = CreatedBy.user,
}) {
  return WorkoutDto(
    id: id,
    name: 'Endurance & HIIT Cardio',
    description: 'Long warm-up followed by rowing sprints',
    muscleGroups: const {},
    muscles: const TargetMuscles(primary: {}, secondary: {}),
    difficulty: Difficulty.intermediate,
    version: 1,
    isFavorite: true,
    totalSets: 5,
    totalReps: 0,
    editorType: EditorType.cardio,
    createdBy: createdBy,
    cardioSets: const [
      WorkoutCardioSetDto(
        id: 1,
        position: 1,
        setType: CardioSetType.constant,
        restSecs: 90,
        rounds: 1,
        exercises: [
          WorkoutCardioSetExerciseDto(
            id: 11,
            position: 1,
            exerciseId: 101,
            restSecs: 0,
            mode: CardioBaseMode.time,
            quantity: 3665,
            exercise: _runningExercise,
          ),
        ],
      ),
      WorkoutCardioSetDto(
        id: 2,
        position: 2,
        setType: CardioSetType.interval,
        restSecs: 120,
        rounds: 4,
        exercises: [
          WorkoutCardioSetExerciseDto(
            id: 21,
            position: 1,
            exerciseId: 102,
            restSecs: 30,
            mode: CardioBaseMode.units,
            quantity: 500,
            exercise: _rowingExercise,
          ),
          WorkoutCardioSetExerciseDto(
            id: 22,
            position: 2,
            exerciseId: 101,
            restSecs: 45,
            mode: CardioBaseMode.time,
            quantity: 120,
            exercise: _runningExercise,
          ),
        ],
      ),
    ],
  );
}

void main() {
  test('Converters.formatDuration formats seconds, minutes, and hours', () {
    expect(Converters.formatDuration(0), '0s');
    expect(Converters.formatDuration(45), '45s');
    expect(Converters.formatDuration(60), '1m');
    expect(Converters.formatDuration(90), '1m 30s');
    expect(Converters.formatDuration(3600), '1h');
    expect(Converters.formatDuration(3605), '1h 5s');
    expect(Converters.formatDuration(3660), '1h 1m');
    expect(Converters.formatDuration(3665), '1h 1m 5s');
  });

  group('CreateWorkoutDialog and WorkoutBaseForm', () {
    testWidgets(
      'supports Basic, Advanced, and Cardio editor types and submits Cardio',
      (tester) async {
        final cubit = _FakeWorkoutCubit();
        addTearDown(cubit.close);

        final pushedLocations = <String>[];
        final router = GoRouter(
          initialLocation: '/workouts',
          routes: [
            GoRoute(
              path: '/workouts',
              builder: (context, _) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => CreateWorkoutDialog(
                          sizes: DataDisplaySizes.getDataDisplaySizes(
                            ScreenSize.sm,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Create'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/workouts/:id/edit',
              builder: (_, state) {
                pushedLocations.add(state.uri.toString());
                return const Scaffold(body: Text('Edit Target'));
              },
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          BlocProvider<WorkoutCubit>.value(
            value: cubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Create'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Name',
          ),
          'Morning Tempo Run',
        );

        await tester.tap(
          find.byKey(const ValueKey('workout-form-editor-type')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Basic').last, findsOneWidget);
        expect(find.text('Advanced').last, findsOneWidget);
        expect(find.text('Cardio').last, findsOneWidget);

        await tester.tap(find.text('Cardio').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('CREATE WORKOUT'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();

        expect(cubit.createdInputs, hasLength(1));
        expect(cubit.createdInputs.first.name, 'Morning Tempo Run');
        expect(cubit.createdInputs.first.editorType, EditorType.cardio);
        expect(pushedLocations, ['/workouts/99/edit']);
      },
    );

    testWidgets(
      'edit mode locks Cardio and Advanced and restricts Basic to Basic/Advanced',
      (tester) async {
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm);

        // Cardio edit mode -> locked
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Builder(
                  builder: (context) => WorkoutBaseForm(
                    key: const ValueKey('edit-cardio'),
                    theme: Theme.of(context),
                    sizes: sizes,
                    isLoading: false,
                    isEditing: true,
                    submitLabel: 'SAVE',
                    initialName: 'Cardio Session',
                    initialIsFavorite: false,
                    initialDifficulty: Difficulty.beginner,
                    initialEditorType: EditorType.cardio,
                    onSubmit: ({
                      required name,
                      required isFavorite,
                      required difficulty,
                      required editorType,
                      description,
                    }) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Cardio workouts cannot be switched to strength editors.'),
          findsOneWidget,
        );

        // Advanced edit mode -> locked
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Builder(
                  builder: (context) => WorkoutBaseForm(
                    key: const ValueKey('edit-advanced'),
                    theme: Theme.of(context),
                    sizes: sizes,
                    isLoading: false,
                    isEditing: true,
                    submitLabel: 'SAVE',
                    initialName: 'Advanced Push',
                    initialIsFavorite: false,
                    initialDifficulty: Difficulty.intermediate,
                    initialEditorType: EditorType.advanced,
                    onSubmit: ({
                      required name,
                      required isFavorite,
                      required difficulty,
                      required editorType,
                      description,
                    }) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            'This workout already uses Advanced Editor and cannot be changed.',
          ),
          findsOneWidget,
        );

        // Basic edit mode -> Basic and Advanced only, no Cardio
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Builder(
                  builder: (context) => WorkoutBaseForm(
                    key: const ValueKey('edit-basic'),
                    theme: Theme.of(context),
                    sizes: sizes,
                    isLoading: false,
                    isEditing: true,
                    submitLabel: 'SAVE',
                    initialName: 'Basic Push',
                    initialIsFavorite: false,
                    initialDifficulty: Difficulty.beginner,
                    initialEditorType: EditorType.basic,
                    onSubmit: ({
                      required name,
                      required isFavorite,
                      required difficulty,
                      required editorType,
                      description,
                    }) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('workout-form-editor-type')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Basic'), findsWidgets);
        expect(find.text('Advanced'), findsWidgets);
        expect(find.text('Cardio'), findsNothing);
      },
    );
  });

  group('WorkoutsScreen cardio filtering', () {
    testWidgets(
      'toggles Strength/Cardio, hides muscle group on Cardio, preserves shared filters, and pre-selects Cardio in create modal',
      (tester) async {
        final cubit = _FakeWorkoutCubit(
          workoutsToEmit: [_buildSampleCardioWorkout()],
        );
        addTearDown(cubit.close);

        final router = GoRouter(
          initialLocation: '/workouts',
          routes: [
            GoRoute(
              path: '/workouts',
              builder: (_, _) => const WorkoutsScreen(),
            ),
            GoRoute(
              path: '/workouts/:id/edit',
              builder: (_, _) => const Scaffold(body: Text('Edit')),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          BlocProvider<WorkoutCubit>.value(
            value: cubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(cubit.getWorkoutsCalls.last.type, ExerciseType.strength);
        expect(find.text('All Muscle Groups'), findsOneWidget);

        // Enable CreatedBy.user filter before switching to Cardio
        await tester.tap(find.byType(CreatedByCheckbox));
        await tester.pump();

        // Switch toggle to Cardio
        await tester.tap(
          find.descendant(
            of: find.byKey(const ValueKey('workout-search-type-toggle')),
            matching: find.text('Cardio'),
          ),
        );
        await tester.pumpAndSettle();

        expect(cubit.getWorkoutsCalls.last.type, ExerciseType.cardio);
        expect(cubit.getWorkoutsCalls.last.createdBy, CreatedBy.user);
        expect(cubit.getWorkoutsCalls.last.muscleGroup, isNull);
        expect(find.text('All Muscle Groups'), findsNothing);

        // Cardio card displays Rounds and Cardio badge
        expect(
          find.text('Total Rounds: 5', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.textContaining('Total Reps:', findRichText: true),
          findsNothing,
        );

        // FAB opens CreateWorkoutDialog pre-selected to Cardio
        await tester.tap(find.byKey(const ValueKey('workout-add')));
        await tester.pumpAndSettle();

        final editorDropdown = find.byKey(
          const ValueKey('workout-form-editor-type'),
        );
        expect(
          find.descendant(of: editorDropdown, matching: find.text('Cardio')),
          findsOneWidget,
        );
      },
    );
  });

  group('WorkoutEditScreen and CardioEditor', () {
    testWidgets(
      'renders CardioEditor, searches cardio exercises, switches to Interval + Units, and saves',
      (tester) async {
        final cardioWorkout = WorkoutDto(
          id: 55,
          name: 'Empty Cardio Workout',
          muscleGroups: const {},
          muscles: const TargetMuscles(primary: {}, secondary: {}),
          difficulty: Difficulty.beginner,
          version: 1,
          isFavorite: false,
          totalSets: 0,
          totalReps: 0,
          editorType: EditorType.cardio,
          createdBy: CreatedBy.user,
          cardioSets: const [],
        );
        final workoutCubit = _FakeWorkoutCubit(
          initialSelectedWorkout: cardioWorkout,
        );
        final exerciseCubit = _FakeExerciseCubit(
          cardioExercises: const [_runningExercise, _rowingExercise],
        );
        addTearDown(workoutCubit.close);
        addTearDown(exerciseCubit.close);

        final router = GoRouter(
          initialLocation: '/workouts/55',
          routes: [
            GoRoute(
              path: '/workouts/55',
              builder: (context, _) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => context.push('/workouts/55/edit'),
                  child: const Text('Go To Edit'),
                ),
              ),
            ),
            GoRoute(
              path: '/workouts/55/edit',
              builder: (_, _) => const WorkoutEditScreen(workoutId: 55),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WorkoutCubit>.value(value: workoutCubit),
              BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Go To Edit'));
        await tester.pumpAndSettle();

        expect(find.byType(CardioEditor), findsOneWidget);
        expect(exerciseCubit.requestedTypes, contains(ExerciseType.cardio));

        // Add a new cardio set
        await tester.tap(find.text('Add Set'));
        await tester.pumpAndSettle();

        // Switch Set Type from Constant -> Interval
        await tester.tap(find.text('Constant'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Interval').last);
        await tester.pumpAndSettle();

        // Add an exercise via CardioExerciseSearchModal
        final addExerciseButton = find.text('Add Exercise');
        await tester.ensureVisible(addExerciseButton);
        await tester.tap(addExerciseButton);
        await tester.pumpAndSettle();

        expect(
          exerciseCubit.requestedTypes.every((t) => t == ExerciseType.cardio),
          isTrue,
        );
        expect(find.text('Concept2 Rowing'), findsOneWidget);

        await tester.tap(find.text('Concept2 Rowing'));
        await tester.pumpAndSettle();

        // Concept2 Rowing defaults to Units (m); enter 500
        final unitField = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'm',
        );
        await tester.ensureVisible(unitField);
        await tester.enterText(unitField, '500');
        await tester.pumpAndSettle();

        // Save cardio sets
        final saveButton = find.text('SAVE');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(workoutCubit.savedCardioSets, hasLength(1));
        final saved = workoutCubit.savedCardioSets.first;
        expect(saved, hasLength(1));
        expect(saved.first.setType, CardioSetType.interval);
        expect(saved.first.position, 1);
        expect(saved.first.exercises, hasLength(1));
        expect(saved.first.exercises.first.exerciseId, _rowingExercise.id);
        expect(saved.first.exercises.first.mode, CardioBaseMode.units);
        expect(saved.first.exercises.first.quantity, 500);

        // Popped back after successful save
        expect(find.text('Go To Edit'), findsOneWidget);
      },
    );
  });

  group('WorkoutDetailScreen and responsiveness', () {
    testWidgets(
      'displays cardio sets, Cardio badge, Rounds, EDIT/DELETE, and omits Start Workout and History',
      (tester) async {
        final cardioWorkout = _buildSampleCardioWorkout();
        final cubit = _FakeWorkoutCubit(initialSelectedWorkout: cardioWorkout);
        addTearDown(cubit.close);

        final router = GoRouter(
          initialLocation: '/workouts/55',
          routes: [
            GoRoute(
              path: '/workouts/55',
              builder: (_, _) => const WorkoutDetailScreen(workoutId: 55),
            ),
            GoRoute(
              path: '/exercises/:id',
              builder: (_, state) => Scaffold(
                body: Text('Exercise ${state.pathParameters['id']}'),
              ),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          BlocProvider<WorkoutCubit>.value(
            value: cubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cardio'), findsOneWidget);
        expect(
          find.text('Total Rounds: 5', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.textContaining('Total Reps:', findRichText: true),
          findsNothing,
        );

        expect(find.text('Constant'), findsOneWidget);
        expect(find.text('Interval'), findsOneWidget);
        expect(find.text('Outdoor Running'), findsWidgets);
        expect(find.text('Concept2 Rowing'), findsOneWidget);
        expect(find.text(' 1h 1m 5s'), findsOneWidget);
        expect(find.text('500 m'), findsOneWidget);
        expect(find.text(' 4×'), findsOneWidget);

        expect(find.text('EDIT'), findsOneWidget);
        expect(find.text('DELETE'), findsOneWidget);
        expect(find.text('START WORKOUT'), findsNothing);
        expect(find.text('HISTORY'), findsNothing);
      },
    );

    testWidgets(
      'cardio detail, list, and edit screens render without overflow at 320px width and 200% text scaling',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final cardioWorkout = _buildSampleCardioWorkout();
        final workoutCubit = _FakeWorkoutCubit(
          initialSelectedWorkout: cardioWorkout,
          workoutsToEmit: [cardioWorkout],
          initialType: ExerciseType.cardio,
        );
        final exerciseCubit = _FakeExerciseCubit(
          cardioExercises: const [_runningExercise, _rowingExercise],
        );
        addTearDown(workoutCubit.close);
        addTearDown(exerciseCubit.close);

        Future<void> pumpAt200Scale(String path, Widget child) async {
          final router = GoRouter(
            initialLocation: path,
            routes: [GoRoute(path: path, builder: (_, _) => child)],
          );
          addTearDown(router.dispose);

          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<WorkoutCubit>.value(value: workoutCubit),
                BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
              ],
              child: MaterialApp.router(
                routerConfig: router,
                builder: (context, innerChild) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2.0)),
                  child: innerChild!,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await pumpAt200Scale(
          '/workouts/55',
          const WorkoutDetailScreen(workoutId: 55),
        );
        await pumpAt200Scale('/workouts', const WorkoutsScreen());
        await pumpAt200Scale(
          '/workouts/55/edit',
          const WorkoutEditScreen(workoutId: 55),
        );
      },
    );
  });
}
