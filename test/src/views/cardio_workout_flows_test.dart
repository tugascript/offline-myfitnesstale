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
import 'package:skeletonizer/skeletonizer.dart';

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
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/core/widgets/cardio_set_type_badge.dart';
import 'package:myfitnesstale/src/ui/core/widgets/created_by_checkbox.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/editor/workout_search/workout_plan_workout_search_modal.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_detail_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_edit_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workouts_list_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/states/workout_state.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/cardio_editor/cardio_duration_input.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/cardio_editor/cardio_editor.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/cardio_editor/cardio_exercise_search_modal.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/cardio_editor/cardio_rounds_input.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/cardio_editor/cardio_set_editor.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/create_workout_modal.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/workout_base_form.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/workout_cardio_set_card.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/workout_set_card.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/workout_skeleton_placeholder.dart';
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
  final bool keepLoadingOnGetWorkout;
  final ErrorState? batchUpsertCardioError;
  final ErrorState? createWorkoutError;
  final List<WorkoutCardioSetDto>? refreshedCardioSetsOnSave;

  _FakeWorkoutCubit({
    WorkoutDto? initialSelectedWorkout,
    this.workoutsToEmit = const [],
    List<WorkoutDto>? initialWorkouts,
    ExerciseType initialType = ExerciseType.strength,
    this.keepLoadingOnGetWorkout = false,
    this.batchUpsertCardioError,
    this.createWorkoutError,
    this.refreshedCardioSetsOnSave,
  }) : super(workoutRepository: WorkoutRepository.create()) {
    final seedWorkouts =
        initialWorkouts ??
        (initialType == ExerciseType.cardio ? workoutsToEmit : const []);
    if (initialSelectedWorkout != null ||
        initialType != ExerciseType.strength ||
        seedWorkouts.isNotEmpty) {
      emit(
        state.copyWith(
          selectedWorkout: Nullable(initialSelectedWorkout),
          workouts: seedWorkouts,
          pagination: state.pagination.copyWith(
            type: initialType,
            total: seedWorkouts.length,
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
    if (keepLoadingOnGetWorkout) {
      emit(state.copyWith(isLoading: true, error: const Nullable(null)));
      return;
    }
    emit(state.copyWith(isLoading: false, error: const Nullable(null)));
  }

  @override
  Future<void> createWorkout(WorkoutInput input) async {
    createdInputs.add(input);
    if (createWorkoutError != null) {
      emit(state.copyWith(isLoading: true, error: const Nullable(null)));
      emit(
        state.copyWith(isLoading: false, error: Nullable(createWorkoutError)),
      );
      return;
    }
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
  Future<void> updateWorkout(int id, WorkoutInput input) async {
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));
    final current = state.selectedWorkout;
    if (current != null && current.id == id) {
      emit(
        state.copyWith(
          selectedWorkout: Nullable(
            current.copyWith(
              name: input.name,
              description: input.description,
              difficulty: input.difficulty,
              isFavorite: input.isFavorite,
              editorType: input.editorType,
            ),
          ),
          isLoading: false,
          error: const Nullable(null),
        ),
      );
      return;
    }
    emit(state.copyWith(isLoading: false, error: const Nullable(null)));
  }

  final List<ExerciseType> selectionTypes = [];

  @override
  Future<void> batchUpsertCardioWorkoutSets({
    required int workoutId,
    required List<WorkoutCardioSetUpsertInput> sets,
  }) async {
    savedCardioSets.add(sets);
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));
    if (batchUpsertCardioError != null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: Nullable(batchUpsertCardioError),
        ),
      );
      return;
    }

    final current = state.selectedWorkout;
    final updatedWorkout = current != null && refreshedCardioSetsOnSave != null
        ? current.copyWith(cardioSets: Nullable(refreshedCardioSetsOnSave))
        : current;
    emit(
      state.copyWith(
        selectedWorkout: Nullable(updatedWorkout),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  @override
  Future<void> getSelectionWorkouts({
    ExerciseType type = ExerciseType.strength,
    MuscleGroup? muscleGroup,
    String name = '',
    bool isFavorite = false,
  }) async {
    selectionTypes.add(type);
    emit(
      state.copyWith(
        workoutSelection: workoutsToEmit,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}

class _FakeExerciseCubit extends ExerciseCubit {
  final List<ExerciseType?> requestedTypes = [];
  final List<ExerciseDto> cardioExercises;
  final bool keepLoadingOnSearch;

  _FakeExerciseCubit({
    required this.cardioExercises,
    List<ExerciseDto>? initialSelection,
    this.keepLoadingOnSearch = false,
  }) : super(exerciseRepository: ExerciseRepository.create()) {
    if (initialSelection != null) {
      emit(state.copyWith(exerciseSelection: initialSelection));
    }
  }

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
    if (keepLoadingOnSearch) {
      emit(state.copyWith(isLoading: true, error: const Nullable(null)));
      return;
    }
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

    testWidgets(
      'WorkoutEditScreen shows neutral Skeletonizer on cold load and cardio Skeletonizer when cached',
      (tester) async {
        // Cold load (not in state.workouts, default strength pagination) uses neutral placeholder
        final coldCubit = _FakeWorkoutCubit(
          initialType: ExerciseType.strength,
          keepLoadingOnGetWorkout: true,
        );
        final exerciseCubit = _FakeExerciseCubit(
          cardioExercises: const [_runningExercise],
        );
        addTearDown(coldCubit.close);
        addTearDown(exerciseCubit.close);

        final coldRouter = GoRouter(
          initialLocation: '/workouts/55/edit',
          routes: [
            GoRoute(
              path: '/workouts/55/edit',
              builder: (_, _) => const WorkoutEditScreen(workoutId: 55),
            ),
          ],
        );
        addTearDown(coldRouter.dispose);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WorkoutCubit>.value(value: coldCubit),
              BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            ],
            child: MaterialApp.router(routerConfig: coldRouter),
          ),
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(WorkoutSkeletonPlaceholder), findsOneWidget);
        expect(find.text('Cardio'), findsNothing);
        expect(find.text('Push'), findsNothing);

        // Cached cardio workout uses cardio header skeleton
        final cachedCubit = _FakeWorkoutCubit(
          initialWorkouts: [_buildSampleCardioWorkout(id: 55)],
          keepLoadingOnGetWorkout: true,
        );
        addTearDown(cachedCubit.close);

        final cachedRouter = GoRouter(
          initialLocation: '/workouts/55/edit',
          routes: [
            GoRoute(
              path: '/workouts/55/edit',
              builder: (_, _) => const WorkoutEditScreen(workoutId: 55),
            ),
          ],
        );
        addTearDown(cachedRouter.dispose);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WorkoutCubit>.value(value: cachedCubit),
              BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            ],
            child: MaterialApp.router(routerConfig: cachedRouter),
          ),
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
          findsOneWidget,
        );
        expect(find.text('Cardio'), findsOneWidget);
      },
    );

    testWidgets(
      'WorkoutEditScreen displays error description in a single SnackBar without duplicate toasts on cardio save failure',
      (tester) async {
        final cardioWorkout = _buildSampleCardioWorkout();
        final workoutCubit = _FakeWorkoutCubit(
          initialSelectedWorkout: cardioWorkout,
          batchUpsertCardioError: const ErrorState(
            type: 'invalidInput',
            description: 'At least one cardio set is required',
          ),
        );
        final exerciseCubit = _FakeExerciseCubit(
          cardioExercises: const [_runningExercise, _rowingExercise],
        );
        addTearDown(workoutCubit.close);
        addTearDown(exerciseCubit.close);

        final router = GoRouter(
          initialLocation: '/workouts/55/edit',
          routes: [
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

        final saveButton = find.text('SAVE');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('At least one cardio set is required'),
          findsOneWidget,
        );
        expect(find.textContaining('ErrorState('), findsNothing);

        // Dismiss the active SnackBar and confirm no duplicate SnackBar is queued.
        ScaffoldMessenger.of(tester.element(find.byType(CardioEditor)))
            .hideCurrentSnackBar();
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'CardioEditor syncs displayed sets with persisted IDs when cannot pop after save',
      (tester) async {
        final emptyCardioWorkout = WorkoutDto(
          id: 55,
          name: 'Root Route Cardio',
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
        final persistedSets = const [
          WorkoutCardioSetDto(
            id: 701,
            position: 1,
            setType: CardioSetType.constant,
            restSecs: 60,
            rounds: 1,
            exercises: [
              WorkoutCardioSetExerciseDto(
                id: 801,
                position: 1,
                exerciseId: 102,
                restSecs: 0,
                mode: CardioBaseMode.units,
                quantity: 500,
                exercise: _rowingExercise,
              ),
            ],
          ),
        ];

        final workoutCubit = _FakeWorkoutCubit(
          initialSelectedWorkout: emptyCardioWorkout,
          refreshedCardioSetsOnSave: persistedSets,
        );
        final exerciseCubit = _FakeExerciseCubit(
          cardioExercises: const [_runningExercise, _rowingExercise],
        );
        addTearDown(workoutCubit.close);
        addTearDown(exerciseCubit.close);

        // Mounted as root route so context.canPop() is false.
        final router = GoRouter(
          initialLocation: '/workouts/55/edit',
          routes: [
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

        await tester.tap(find.text('Add Set'));
        await tester.pumpAndSettle();

        final addExerciseButton = find.text('Add Exercise');
        await tester.ensureVisible(addExerciseButton);
        await tester.tap(addExerciseButton);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Concept2 Rowing'));
        await tester.pumpAndSettle();

        final unitField = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'm',
        );
        await tester.ensureVisible(unitField);
        await tester.enterText(unitField, '500');
        await tester.pumpAndSettle();

        // First save: newly created set/exercise have null IDs.
        final saveButton = find.text('SAVE');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(workoutCubit.savedCardioSets, hasLength(1));
        expect(workoutCubit.savedCardioSets.first.first.id, isNull);
        expect(
          workoutCubit.savedCardioSets.first.first.exercises.first.id,
          isNull,
        );

        // Second save without leaving the screen must use synced persisted IDs.
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(workoutCubit.savedCardioSets, hasLength(2));
        expect(workoutCubit.savedCardioSets.last.first.id, 701);
        expect(workoutCubit.savedCardioSets.last.first.exercises.first.id, 801);
      },
    );

    testWidgets(
      'CardioEditor preserves unsaved draft edits when saving the workout header',
      (tester) async {
        final cardioWorkout = _buildSampleCardioWorkout();
        final workoutCubit = _FakeWorkoutCubit(
          initialSelectedWorkout: cardioWorkout,
        );
        final exerciseCubit = _FakeExerciseCubit(
          cardioExercises: const [_runningExercise, _rowingExercise],
        );
        addTearDown(workoutCubit.close);
        addTearDown(exerciseCubit.close);

        final router = GoRouter(
          initialLocation: '/workouts/55/edit',
          routes: [
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

        expect(find.byType(CardioSetEditor), findsNWidgets(2));

        // Add a new unsaved cardio set (goes from 2 sets -> 3 sets)
        final addSetButton = find.text('Add Set');
        await tester.ensureVisible(addSetButton);
        await tester.tap(addSetButton);
        await tester.pumpAndSettle();
        expect(find.byType(CardioSetEditor), findsNWidgets(3));

        // Open header edit form, rename the workout, and save header
        final editHeaderIcon = find.byKey(
          const ValueKey('workout-header-edit'),
        );
        await tester.ensureVisible(editHeaderIcon);
        await tester.tap(editHeaderIcon);
        await tester.pumpAndSettle();

        final nameField = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        );
        await tester.ensureVisible(nameField);
        await tester.enterText(nameField, 'Renamed Cardio Workout');
        await tester.pumpAndSettle();

        final updateHeaderButton = find.text('UPDATE WORKOUT');
        await tester.ensureVisible(updateHeaderButton);
        await tester.tap(updateHeaderButton);
        await tester.pumpAndSettle();

        // Header updated while unsaved 3rd cardio set remains intact
        expect(
          workoutCubit.state.selectedWorkout?.name,
          'Renamed Cardio Workout',
        );
        expect(find.byType(CardioSetEditor), findsNWidgets(3));
      },
    );

    testWidgets(
      'CardioDurationInput and CardioRoundsInput picker sheets fit 320x480 viewport at 100% and 200% text scaling',
      (tester) async {
        tester.view.physicalSize = const Size(320, 480);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

        for (final scale in [1.0, 2.0]) {
          int durationValue = 3665;
          int restValue = 90;
          int roundsValue = 4;

          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Builder(
                    builder: (context) => Column(
                      children: [
                        CardioDurationInput(
                          theme: Theme.of(context),
                          sizes: sizes,
                          seconds: durationValue,
                          labelText: 'Duration',
                          sheetTitle: 'Duration',
                          allowHours: true,
                          minSeconds: 1,
                          onChanged: (v) => durationValue = v,
                        ),
                        CardioDurationInput(
                          theme: Theme.of(context),
                          sizes: sizes,
                          seconds: restValue,
                          labelText: 'Rest',
                          sheetTitle: 'Rest Between Sets',
                          allowHours: false,
                          minSeconds: 0,
                          onChanged: (v) => restValue = v,
                        ),
                        CardioRoundsInput(
                          theme: Theme.of(context),
                          sizes: sizes,
                          initialRounds: roundsValue,
                          onChanged: (v) => roundsValue = v,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Open and confirm Duration (hours/min/sec) sheet
          await tester.tap(find.text('1h 1m 5s'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Confirm'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Open and confirm Rest (min/sec) sheet
          await tester.tap(find.text('1m 30s'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Confirm'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Open and confirm Rounds sheet
          await tester.tap(find.text('4'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Confirm'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'CardioExerciseSearchModal filters out cached strength exercises and blocks selection while loading',
      (tester) async {
        const strengthExercise = ExerciseDto(
          id: 201,
          name: 'Barbell Bench Press',
          description: 'Strength press',
          details: StrengthExerciseDetails(
            muscleGroup: MuscleGroup.push,
            muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
            weightProgress: ExerciseWeightProgress.positive,
          ),
          createdBy: CreatedBy.system,
        );

        final exerciseCubit = _FakeExerciseCubit(
          cardioExercises: const [_runningExercise],
          initialSelection: const [strengthExercise, _runningExercise],
          keepLoadingOnSearch: true,
        );
        addTearDown(exerciseCubit.close);

        final selected = <ExerciseDto>[];
        await tester.pumpWidget(
          BlocProvider<ExerciseCubit>.value(
            value: exerciseCubit,
            child: MaterialApp(
              home: Scaffold(
                body: CardioExerciseSearchModal(
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm),
                  isLoading: false,
                  onExerciseSelected: selected.add,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Stale strength exercise is hidden; only cardio exercise is listed
        expect(find.text('Barbell Bench Press'), findsNothing);
        expect(find.text('Outdoor Running'), findsOneWidget);

        // While loading is in flight, tapping cached cardio exercise does nothing
        await tester.tap(find.text('Outdoor Running'), warnIfMissed: false);
        await tester.pump();
        expect(selected, isEmpty);

        // Once search finishes, cardio exercise becomes selectable
        exerciseCubit.emit(
          exerciseCubit.state.copyWith(
            isLoading: false,
            exerciseSelection: const [strengthExercise, _runningExercise],
          ),
        );
        await tester.pump();

        expect(find.text('Barbell Bench Press'), findsNothing);
        await tester.tap(find.text('Outdoor Running'));
        await tester.pump();
        expect(selected, const [_runningExercise]);
      },
    );

    testWidgets(
      'CardioSetTypeBadge uses contrasting theme onSurface foreground on light and dark themes',
      (tester) async {
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm);

        for (final theme in [ThemeData.light(), ThemeData.dark()]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Row(
                  children: [
                    CardioSetTypeBadge(
                      sizes: sizes,
                      setType: CardioSetType.constant,
                    ),
                    CardioSetTypeBadge(
                      sizes: sizes,
                      setType: CardioSetType.interval,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final constantText = tester.widget<Text>(find.text('Constant'));
          final intervalText = tester.widget<Text>(find.text('Interval'));
          expect(constantText.style?.color, theme.colorScheme.onSurface);
          expect(intervalText.style?.color, theme.colorScheme.onSurface);
        }
      },
    );
  });

  group('WorkoutDetailScreen and responsiveness', () {
    testWidgets(
      'renders cardio skeleton structure while loading a cardio workout',
      (tester) async {
        final cachedCardio = _buildSampleCardioWorkout(id: 55);
        final cubit = _FakeWorkoutCubit(
          initialWorkouts: [cachedCardio],
          keepLoadingOnGetWorkout: true,
        );
        addTearDown(cubit.close);

        final router = GoRouter(
          initialLocation: '/workouts/55',
          routes: [
            GoRoute(
              path: '/workouts/55',
              builder: (_, _) => const WorkoutDetailScreen(workoutId: 55),
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
        await tester.pump();

        expect(
          find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
          findsOneWidget,
        );
        expect(find.byType(WorkoutCardioSetCard), findsNWidgets(2));
        expect(find.byType(WorkoutSetCard), findsNothing);
        expect(find.text('START WORKOUT'), findsNothing);
        expect(find.text('HISTORY'), findsNothing);
      },
    );

    testWidgets(
      'renders neutral skeleton without strength cards or actions on cold navigation when workout type is unknown',
      (tester) async {
        final cubit = _FakeWorkoutCubit(
          initialType: ExerciseType.strength,
          keepLoadingOnGetWorkout: true,
        );
        addTearDown(cubit.close);

        final router = GoRouter(
          initialLocation: '/workouts/55',
          routes: [
            GoRoute(
              path: '/workouts/55',
              builder: (_, _) => const WorkoutDetailScreen(workoutId: 55),
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
        await tester.pump();

        expect(
          find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled),
          findsOneWidget,
        );
        expect(find.byType(WorkoutSkeletonPlaceholder), findsOneWidget);
        expect(find.byType(WorkoutSetCard), findsNothing);
        expect(find.byType(WorkoutCardioSetCard), findsNothing);
        expect(find.text('START WORKOUT'), findsNothing);
        expect(find.text('HISTORY'), findsNothing);
      },
    );

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

    testWidgets(
      'WorkoutPlanWorkoutSearchModal restricts plan workout selection searches to strength workouts',
      (tester) async {
        final cubit = _FakeWorkoutCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(
          BlocProvider<WorkoutCubit>.value(
            value: cubit,
            child: MaterialApp(
              home: Scaffold(
                body: WorkoutPlanWorkoutSearchModal(
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm),
                  isLoading: false,
                  onWorkoutSelected: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.search).last);
        await tester.pumpAndSettle();

        expect(cubit.selectionTypes, [ExerciseType.strength]);
      },
    );

    testWidgets(
      'CardioDurationInput displays stored rest durations beyond picker limit without clamping',
      (tester) async {
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm);
        int restSeconds = 3600;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => CardioDurationInput(
                  theme: Theme.of(context),
                  sizes: sizes,
                  seconds: restSeconds,
                  labelText: 'Rest',
                  sheetTitle: 'Rest Between Sets',
                  allowHours: false,
                  minSeconds: 0,
                  onChanged: (v) => restSeconds = v,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('1h'), findsOneWidget);
        expect(find.text('59m 59s'), findsNothing);

        // Opening and cancelling the picker preserves the unclamped value
        await tester.tap(find.text('1h'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(restSeconds, 3600);
        expect(find.text('1h'), findsOneWidget);
      },
    );

    testWidgets(
      'CardioRoundsInput displays stored interval rounds beyond picker limit without clamping',
      (tester) async {
        final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm);
        int rounds = 60;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => CardioRoundsInput(
                  theme: Theme.of(context),
                  sizes: sizes,
                  initialRounds: rounds,
                  onChanged: (v) => rounds = v,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('60'), findsOneWidget);
        expect(find.text('50'), findsNothing);

        // Opening and cancelling the picker preserves the unclamped rounds
        await tester.tap(find.text('60'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(rounds, 60);
        expect(find.text('60'), findsOneWidget);
      },
    );

    testWidgets(
      'Failed cardio save shows a single SnackBar across stacked Workouts -> Detail -> Edit routes',
      (tester) async {
        final cardioWorkout = _buildSampleCardioWorkout(id: 55);
        final workoutCubit = _FakeWorkoutCubit(
          initialSelectedWorkout: cardioWorkout,
          initialWorkouts: [cardioWorkout],
          workoutsToEmit: [cardioWorkout],
          initialType: ExerciseType.cardio,
          batchUpsertCardioError: const ErrorState(
            type: 'operationFailure',
            description: 'Failed to save cardio sets',
          ),
        );
        final exerciseCubit = _FakeExerciseCubit(
          cardioExercises: const [_runningExercise, _rowingExercise],
        );
        addTearDown(workoutCubit.close);
        addTearDown(exerciseCubit.close);

        final router = GoRouter(
          initialLocation: '/workouts',
          routes: [
            GoRoute(
              path: '/workouts',
              builder: (_, _) => const WorkoutsScreen(),
            ),
            GoRoute(
              path: '/workouts/:id',
              builder: (_, state) => WorkoutDetailScreen(
                workoutId: int.parse(state.pathParameters['id']!),
              ),
            ),
            GoRoute(
              path: '/workouts/:id/edit',
              builder: (_, state) => WorkoutEditScreen(
                workoutId: int.parse(state.pathParameters['id']!),
              ),
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

        // Push Detail then Edit so all three routes remain mounted in the stack
        router.push('/workouts/55');
        await tester.pumpAndSettle();
        router.push('/workouts/55/edit');
        await tester.pumpAndSettle();

        final saveButton = find.text('SAVE');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Failed to save cardio sets'), findsOneWidget);

        // Dismiss the active SnackBar and confirm no duplicate SnackBars were queued
        final editContext = tester.element(find.byType(WorkoutEditScreen));
        ScaffoldMessenger.of(editContext).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'Failed workout creation from CreateWorkoutDialog still shows a single error SnackBar',
      (tester) async {
        final workoutCubit = _FakeWorkoutCubit(
          createWorkoutError: const ErrorState(
            type: 'operationFailure',
            description: 'Could not create workout',
          ),
        );
        addTearDown(workoutCubit.close);

        final router = GoRouter(
          initialLocation: '/workouts',
          routes: [
            GoRoute(
              path: '/workouts',
              builder: (_, _) => const WorkoutsScreen(),
            ),
            GoRoute(
              path: '/workouts/:id/edit',
              builder: (_, state) =>
                  Scaffold(body: Text('Edit ${state.pathParameters['id']}')),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          BlocProvider<WorkoutCubit>.value(
            value: workoutCubit,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('workout-add')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Name',
          ),
          'Evening Run',
        );
        await tester.tap(find.text('CREATE WORKOUT'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Could not create workout'), findsOneWidget);

        // Dismiss the active SnackBar and confirm no duplicate was queued
        final listContext = tester.element(find.byType(WorkoutsScreen));
        ScaffoldMessenger.of(listContext).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsNothing);
      },
    );
  });
}
