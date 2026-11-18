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
import 'package:myfitnesstale/src/data/repositories/core/dtos/picture_dto.dart';
import 'package:myfitnesstale/src/data/repositories/core/dtos/video_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/equipment_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/exercise_input.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/core/widgets/video/app_video_player.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_detail_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercises_list_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/details/create_exercise_modal.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/details/edit_exercise_modal.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/fake_webview_platform.dart';

class _FakeExerciseCubit extends ExerciseCubit {
  final bool shouldFail;
  final List<ExerciseInput> createdInputs = [];
  final List<(int, ExerciseInput)> updatedCalls = [];

  _FakeExerciseCubit({this.shouldFail = false, ExerciseDto? initialExercise})
    : super(exerciseRepository: ExerciseRepository.create()) {
    emit(
      state.copyWith(
        equipmentSelection: const {1: 'Barbell', 2: 'Dumbbell'},
        exercises: initialExercise != null ? [initialExercise] : const [],
        exercisePagination: state.exercisePagination.copyWith(
          total: initialExercise != null ? 1 : 0,
        ),
        selectedExercise: Nullable(initialExercise),
      ),
    );
  }

  @override
  Future<void> getSelectionEquipments() async {}

  @override
  Future<void> getExercises({
    String? name,
    MuscleGroup? muscleGroup,
    Difficulty? difficulty,
    int? equipmentId,
    int? limit,
    int? offset,
    bool isFavourite = false,
  }) async {}

  @override
  Future<void> getExercise(int id) async {}

  @override
  Future<void> createExercise(
    ExerciseInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    createdInputs.add(input);
    if (shouldFail) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to create exercise',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final created = ExerciseDto(
      id: 99,
      name: input.name,
      description: input.description.value ?? '',
      video: input.video.value != null
          ? VideoDto(
              uri: input.video.value!.uri,
              platform: input.video.value!.platform,
            )
          : null,
      muscleGroup: input.muscleGroup,
      muscles: input.muscles,
      difficulty: input.difficulty.value,
      weightProgress: input.weightProgress,
      isFavorite: input.isFavorite,
      equipments: input.equipmentIds
          .map(
            (id) => EquipmentDto(
              id: id,
              name: state.equipmentSelection[id] ?? 'Equipment $id',
              createdBy: CreatedBy.system,
            ),
          )
          .toList(),
      createdBy: createdBy,
    );
    emit(
      state.copyWith(
        exercises: [...state.exercises, created],
        exercisePagination: state.exercisePagination.copyWith(
          total: state.exercises.length + 1,
        ),
        selectedExercise: Nullable(created),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  @override
  Future<void> updateExercise(int id, ExerciseInput input) async {
    updatedCalls.add((id, input));
    if (shouldFail) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to update exercise',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final updated = ExerciseDto(
      id: id,
      name: input.name,
      description: input.description.value ?? '',
      picture: input.picture.value != null
          ? PictureDto(
              storage: input.picture.value!.storage,
              uri: input.picture.value!.uri,
            )
          : null,
      video: input.video.value != null
          ? VideoDto(
              uri: input.video.value!.uri,
              platform: input.video.value!.platform,
            )
          : null,
      muscleGroup: input.muscleGroup,
      muscles: input.muscles,
      difficulty: input.difficulty.value,
      weightProgress: input.weightProgress,
      isFavorite: input.isFavorite,
      equipments: input.equipmentIds
          .map(
            (eid) => EquipmentDto(
              id: eid,
              name: state.equipmentSelection[eid] ?? 'Equipment $eid',
              createdBy: CreatedBy.system,
            ),
          )
          .toList(),
      createdBy: CreatedBy.user,
    );
    emit(
      state.copyWith(
        exercises: state.exercises
            .map((e) => e.id == id ? updated : e)
            .toList(),
        selectedExercise: Nullable(updated),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}

ExerciseDto _sampleExercise({
  int id = 1,
  String name = 'Bench Press',
  CreatedBy createdBy = CreatedBy.system,
  PictureDto? picture,
  VideoDto? video,
}) {
  return ExerciseDto(
    id: id,
    name: name,
    description: 'Press bar upward',
    picture: picture,
    video: video,
    muscleGroup: MuscleGroup.push,
    muscles: const TargetMuscles(
      primary: {Muscle.chest},
      secondary: {Muscle.triceps},
    ),
    equipments: const [
      EquipmentDto(id: 1, name: 'Barbell', createdBy: CreatedBy.system),
    ],
    difficulty: Difficulty.intermediate,
    isFavorite: true,
    createdBy: createdBy,
  );
}

void main() {
  setUpAll(setUpFakeWebViewPlatform);

  testWidgets(
    'ExercisesListScreen FAB opens CreateExerciseModal, creates exercise, and closes modal',
    (tester) async {
      final cubit = _FakeExerciseCubit(initialExercise: _sampleExercise());
      addTearDown(cubit.close);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: const MaterialApp(home: ExercisesListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('exercise-add')));
      await tester.pumpAndSettle();

      expect(find.byType(CreateExerciseModal), findsOneWidget);
      expect(find.text('CREATE EXERCISE'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(CreateExerciseModal),
          matching: find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Name',
          ),
        ),
        'Incline Dumbbell Press',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(CreateExerciseModal),
          matching: find.text('Muscle Group'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push').last);
      await tester.pumpAndSettle();

      final createButton = find.text('CREATE EXERCISE');
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(cubit.createdInputs, hasLength(1));
      expect(cubit.createdInputs.first.name, 'Incline Dumbbell Press');
      expect(cubit.createdInputs.first.muscleGroup, MuscleGroup.push);
      expect(find.byType(CreateExerciseModal), findsNothing);
      expect(find.text('Incline Dumbbell Press'), findsOneWidget);
    },
  );

  testWidgets(
    'Failed exercise creation keeps CreateExerciseModal open and displays error',
    (tester) async {
      final cubit = _FakeExerciseCubit(
        shouldFail: true,
        initialExercise: _sampleExercise(),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: const MaterialApp(home: ExercisesListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('exercise-add')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(CreateExerciseModal),
          matching: find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Name',
          ),
        ),
        'Incline Dumbbell Press',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(CreateExerciseModal),
          matching: find.text('Muscle Group'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push').last);
      await tester.pumpAndSettle();

      final createButton = find.text('CREATE EXERCISE');
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.byType(CreateExerciseModal), findsOneWidget);
      expect(find.text('Failed to create exercise'), findsOneWidget);
    },
  );

  testWidgets(
    'ExerciseDetailScreen edit button opens EditExerciseModal, updates exercise preserving media, and closes modal',
    (tester) async {
      final existing = _sampleExercise(
        id: 12,
        name: 'Larsen Press',
        createdBy: CreatedBy.user,
        picture: const PictureDto(
          storage: PictureStorage.files,
          uri: 'larsen.png',
        ),
        video: const VideoDto(
          uri: 'https://youtu.be/dQw4w9WgXcQ',
          platform: VideoPlatform.youtube,
        ),
      );
      final cubit = _FakeExerciseCubit(initialExercise: existing);
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: '/exercises/12',
        routes: [
          GoRoute(
            path: '/exercises/:id',
            builder: (_, _) => const ExerciseDetailScreen(exerciseId: 12),
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
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppVideoPlayer), findsOneWidget);

      final editButton = find.text('EDIT');
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EditExerciseModal), findsOneWidget);
      expect(find.text('UPDATE EXERCISE'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(EditExerciseModal),
          matching: find.text('Larsen Press'),
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.descendant(
          of: find.byType(EditExerciseModal),
          matching: find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Name',
          ),
        ),
        'Spoto Press',
      );
      final updateButton = find.text('UPDATE EXERCISE');
      await tester.ensureVisible(updateButton);
      await tester.tap(updateButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cubit.updatedCalls, hasLength(1));
      final (updatedId, updatedInput) = cubit.updatedCalls.first;
      expect(updatedId, 12);
      expect(updatedInput.name, 'Spoto Press');
      expect(updatedInput.muscleGroup, MuscleGroup.push);
      expect(updatedInput.isFavorite, isTrue);
      expect(updatedInput.picture.value?.uri, 'larsen.png');
      expect(updatedInput.picture.value?.storage, PictureStorage.files);
      expect(updatedInput.video.value?.uri, 'https://youtu.be/dQw4w9WgXcQ');
      expect(updatedInput.video.value?.platform, VideoPlatform.youtube);
      expect(find.byType(EditExerciseModal), findsNothing);
      expect(find.textContaining('SPOTO PRESS'), findsOneWidget);
    },
  );

  testWidgets(
    'Failed exercise update keeps EditExerciseModal open and displays error',
    (tester) async {
      final existing = _sampleExercise(
        id: 12,
        name: 'Larsen Press',
        createdBy: CreatedBy.user,
      );
      final cubit = _FakeExerciseCubit(
        shouldFail: true,
        initialExercise: existing,
      );
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: '/exercises/12',
        routes: [
          GoRoute(
            path: '/exercises/:id',
            builder: (_, _) => const ExerciseDetailScreen(exerciseId: 12),
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

      final editButton = find.text('EDIT');
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(EditExerciseModal),
          matching: find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Name',
          ),
        ),
        'Spoto Press',
      );
      final updateButton = find.text('UPDATE EXERCISE');
      await tester.ensureVisible(updateButton);
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      expect(find.byType(EditExerciseModal), findsOneWidget);
      expect(find.textContaining('Failed to update exercise'), findsOneWidget);
    },
  );

  testWidgets(
    'CreateExerciseModal validates YouTube URL and saves valid VideoData',
    (tester) async {
      final cubit = _FakeExerciseCubit(initialExercise: _sampleExercise());
      addTearDown(cubit.close);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: const MaterialApp(home: ExercisesListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('exercise-add')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(CreateExerciseModal),
          matching: find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Name',
          ),
        ),
        'Overhead Press',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(CreateExerciseModal),
          matching: find.text('Muscle Group'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push').last);
      await tester.pumpAndSettle();

      final videoField = find.descendant(
        of: find.byType(CreateExerciseModal),
        matching: find.byWidgetPredicate(
          (w) =>
              w is TextField && w.decoration?.labelText == 'YouTube Video URL',
        ),
      );

      // Invalid URL blocks submission
      await tester.enterText(videoField, 'https://vimeo.com/123456');
      final createButton = find.text('CREATE EXERCISE');
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(cubit.createdInputs, isEmpty);
      expect(find.text('Please enter a valid YouTube video URL'), findsOneWidget);
      expect(find.byType(CreateExerciseModal), findsOneWidget);

      // Valid YouTube URL succeeds
      await tester.enterText(
        videoField,
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(cubit.createdInputs, hasLength(1));
      expect(
        cubit.createdInputs.first.video.value?.uri,
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(
        cubit.createdInputs.first.video.value?.platform,
        VideoPlatform.youtube,
      );
      expect(find.byType(CreateExerciseModal), findsNothing);
    },
  );

  testWidgets(
    'EditExerciseModal allows clearing existing YouTube URL',
    (tester) async {
      final existing = _sampleExercise(
        id: 15,
        name: 'Romanian Deadlift',
        createdBy: CreatedBy.user,
        video: const VideoDto(
          uri: 'https://youtu.be/dQw4w9WgXcQ',
          platform: VideoPlatform.youtube,
        ),
      );
      final cubit = _FakeExerciseCubit(initialExercise: existing);
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: '/exercises/15',
        routes: [
          GoRoute(
            path: '/exercises/:id',
            builder: (_, _) => const ExerciseDetailScreen(exerciseId: 15),
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
      await tester.pump(const Duration(milliseconds: 300));

      final editButton = find.text('EDIT');
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final clearButton = find.byTooltip('Clear video URL');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      final updateButton = find.text('UPDATE EXERCISE');
      await tester.ensureVisible(updateButton);
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      expect(cubit.updatedCalls, hasLength(1));
      expect(cubit.updatedCalls.first.$2.video.value, isNull);
      expect(find.byType(AppVideoPlayer), findsNothing);
    },
  );
}
