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
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_set_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_set_exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_detail_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/workout_set_card.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _FakeWorkoutCubit extends WorkoutCubit {
  final WorkoutDto _workout;

  _FakeWorkoutCubit(this._workout)
    : super(workoutRepository: WorkoutRepository.create());

  @override
  Future<void> getWorkout(int id, {int? version, bool refresh = false}) async {
    emit(state.copyWith(selectedWorkout: Nullable(_workout), isLoading: false));
  }
}

void main() {
  const sizes = DataDisplaySizesList(
    viewPadding: 16,
    subtitleFontSize: 14,
    titleFontSize: 20,
    fontSize: 12,
    smallFontSize: 10,
    buttonIconSize: 18,
    buttonSize: 40,
    margins: 16,
    padding: 12,
    spacing: 12,
    inputSpacing: 8,
    elevation: 1,
  );

  const benchPress = ExerciseDto(
    id: 101,
    name: 'Bench Press',
    description: 'Flat barbell bench press',
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {Muscle.chest},
      secondary: {Muscle.triceps},
    ),
    difficulty: Difficulty.intermediate,
    createdBy: CreatedBy.system,
  );

  const dumbbellFly = ExerciseDto(
    id: 102,
    name: 'Dumbbell Fly',
    description: 'Flat dumbbell fly',
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
    difficulty: Difficulty.beginner,
    createdBy: CreatedBy.system,
  );

  const lateralRaise = ExerciseDto(
    id: 103,
    name: 'Lateral Raise',
    description: 'Side dumbbell lateral raise',
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(primary: {Muscle.sideDelts}, secondary: {}),
    difficulty: Difficulty.beginner,
    createdBy: CreatedBy.system,
  );

  final standardSet = WorkoutSetDto(
    id: 1,
    position: 1,
    setType: WorkoutSetType.standard,
    minSets: 3,
    recommendedRestSecs: 90,
    totalExercises: 1,
    totalReps: 30,
    exercises: const [
      WorkoutSetExerciseDto(
        id: 11,
        position: 1,
        exerciseId: 101,
        minReps: 8,
        maxReps: 12,
        toMaxReps: false,
        exercise: benchPress,
      ),
    ],
  );

  final superSet = WorkoutSetDto(
    id: 2,
    position: 2,
    setType: WorkoutSetType.superSet,
    minSets: 4,
    recommendedRestSecs: 60,
    totalExercises: 2,
    totalReps: 48,
    exercises: const [
      WorkoutSetExerciseDto(
        id: 21,
        position: 1,
        exerciseId: 101,
        minReps: 10,
        maxReps: 12,
        toMaxReps: false,
        exercise: benchPress,
      ),
      WorkoutSetExerciseDto(
        id: 22,
        position: 2,
        exerciseId: 102,
        minReps: 12,
        maxReps: 15,
        toMaxReps: false,
        exercise: dumbbellFly,
      ),
    ],
  );

  final dropSet = WorkoutSetDto(
    id: 3,
    position: 3,
    setType: WorkoutSetType.drop,
    minSets: 3,
    recommendedRestSecs: 90,
    totalExercises: 1,
    totalReps: 36,
    exercises: const [
      WorkoutSetExerciseDto(
        id: 31,
        position: 1,
        exerciseId: 103,
        minReps: 12,
        toMaxReps: false,
        exercise: lateralRaise,
      ),
    ],
  );

  group('WorkoutSetCard dense prescription layout', () {
    testWidgets(
      'renders standard single-exercise set as dense one-liner without ExpansionTile',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkoutSetCard(
                theme: ThemeData.light(),
                isDarkTheme: false,
                sizes: sizes,
                set: standardSet,
                setNumber: 1,
              ),
            ),
          ),
        );

        // ExpansionTile should not exist
        expect(find.byType(ExpansionTile), findsNothing);

        // Exercise name and prescription are visible immediately
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.textContaining('3×8–12'), findsOneWidget);
        expect(find.textContaining('1m 30s'), findsOneWidget);
        expect(find.text('Standard'), findsOneWidget);
      },
    );

    testWidgets('renders superset as header with stacked A/B rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutSetCard(
              theme: ThemeData.light(),
              isDarkTheme: false,
              sizes: sizes,
              set: superSet,
              setNumber: 2,
            ),
          ),
        ),
      );

      expect(find.byType(ExpansionTile), findsNothing);

      // Header
      expect(find.text('Super'), findsOneWidget);
      expect(find.textContaining('4×'), findsOneWidget);
      expect(find.textContaining('1m'), findsOneWidget);

      // Stacked lettered exercises
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Dumbbell Fly'), findsOneWidget);
      expect(find.text('10–12 reps'), findsOneWidget);
      expect(find.text('12–15 reps'), findsOneWidget);
    });

    testWidgets('renders drop set with progression badge in header', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutSetCard(
              theme: ThemeData.light(),
              isDarkTheme: false,
              sizes: sizes,
              set: dropSet,
              setNumber: 3,
            ),
          ),
        ),
      );

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text('Drop'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Lateral Raise'), findsOneWidget);
      expect(find.text('12 reps'), findsOneWidget);
    });
  });

  group('WorkoutDetailScreen structure and overview strip', () {
    testWidgets(
      'renders Workout Structure title and scrubber chips for multi-block workouts',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.platformDispatcher.clearAllTestValues();
        });

        final workout = WorkoutDto(
          id: 1,
          name: 'Hypertrophy Upper',
          version: 1,
          isFavorite: false,
          totalSets: 10,
          totalReps: 114,
          editorType: EditorType.advanced,
          createdBy: CreatedBy.user,
          difficulty: Difficulty.intermediate,
          muscleGroups: const {MuscleGroup.push},
          muscles: const TargetMuscles(primary: {Muscle.chest}, secondary: {}),
          sets: [standardSet, superSet, dropSet],
        );

        final cubit = _FakeWorkoutCubit(workout);
        addTearDown(cubit.close);

        final router = GoRouter(
          initialLocation: '/workouts/1',
          routes: [
            GoRoute(
              path: '/workouts/:id',
              builder: (context, state) => WorkoutDetailScreen(
                workoutId: int.parse(state.pathParameters['id']!),
              ),
            ),
            GoRoute(
              path: '/exercises/:id',
              builder: (context, state) => Scaffold(
                body: Text('Exercise Detail ${state.pathParameters['id']}'),
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

        // Clear section title
        expect(find.text('Workout Structure'), findsOneWidget);
        expect(find.text('Sets'), findsNothing);

        // Horizontal scrubber chips
        expect(
          find.widgetWithText(ActionChip, '1 Standard · 3×'),
          findsOneWidget,
        );
        expect(find.widgetWithText(ActionChip, '2 Super · 4×'), findsOneWidget);
        expect(find.widgetWithText(ActionChip, '3 Drop · 3×'), findsOneWidget);

        // Tapping a scrubber chip focuses/selects it
        await tester.tap(find.widgetWithText(ActionChip, '2 Super · 4×'));
        await tester.pumpAndSettle();

        // Tapping an exercise navigates to exercise detail
        await tester.tap(find.text('Dumbbell Fly'));
        await tester.pumpAndSettle();

        expect(find.text('Exercise Detail 102'), findsOneWidget);
      },
    );
  });
}
