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
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/strength_goal_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/exercise_input.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/strength_goal_input.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/utils/formatters.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/core/widgets/layout/app_text_button.dart';
import 'package:myfitnesstale/src/ui/core/widgets/layout/list_card.dart';
import 'package:myfitnesstale/src/ui/core/widgets/not_found_list.dart';
import 'package:myfitnesstale/src/ui/core/widgets/progress_status_badge.dart';
import 'package:myfitnesstale/src/ui/core/widgets/video/app_video_player.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_detail_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercises_list_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/strength_goals_list_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/states/exercise_record_state.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/details/create_exercise_modal.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/details/edit_exercise_modal.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/strength_goal/active_strength_goal_card.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/strength_goal/create_strength_goal_modal.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/strength_goal/edit_strength_goal_modal.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/strength_goal/strength_goal_history_list.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/fake_webview_platform.dart';

class _FakeExerciseCubit extends ExerciseCubit {
  final bool shouldFail;
  final List<ExerciseInput> createdInputs = [];
  final List<(int, ExerciseInput)> updatedCalls = [];
  int getExercisesCalls = 0;

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
    CreatedBy? createdBy,
  }) async {
    getExercisesCalls++;
  }

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

class _FakeProfileCubit extends ProfileCubit {
  _FakeProfileCubit({Units units = Units.metric})
    : super(profileRepository: ProfileRepository.create()) {
    emit(
      ProfileState(
        profile: ProfileDto(
          id: 1,
          name: 'Tester',
          height: 175,
          gender: Gender.other,
          birthdate: DateTime(1990),
        ),
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

class _FakeExerciseRecordCubit extends ExerciseRecordCubit {
  final bool shouldFail;
  final List<StrengthGoalInput> createdStrengthGoals = [];
  final List<(int, StrengthGoalInput)> updatedStrengthGoals = [];
  final List<(int, int)> getStrengthGoalsCalls = [];
  int getActiveStrengthGoalCalls = 0;

  _FakeExerciseRecordCubit({
    this.shouldFail = false,
    StrengthGoalDto? activeStrengthGoal,
    List<StrengthGoalDto> strengthGoals = const [],
    StrengthGoalPagination? strengthGoalPagination,
  }) : super(exerciseRecordRepository: ExerciseRecordRepository.create()) {
    emit(
      state.copyWith(
        activeStrengthGoal: Nullable(activeStrengthGoal),
        strengthGoals: strengthGoals,
        strengthGoalPagination: strengthGoalPagination,
      ),
    );
  }

  void emitError(String description) {
    emit(
      state.copyWith(
        error: Nullable(
          ErrorState(type: 'operationFailure', description: description),
        ),
        isLoading: false,
      ),
    );
  }

  void emitActiveGoalError(String description) {
    final errorState = ErrorState(
      type: 'operationFailure',
      description: description,
    );
    emit(
      state.copyWith(
        activeStrengthGoal: const Nullable(null),
        activeGoalError: Nullable(errorState),
        error: Nullable(errorState),
        isLoadingActiveGoal: false,
      ),
    );
  }

  @override
  Future<void> getActiveStrengthGoal({int? exerciseId}) async {
    getActiveStrengthGoalCalls++;
  }

  @override
  Future<void> getStrengthGoals({
    int? exerciseId,
    bool skipInProgress = false,
    int limit = 20,
    int offset = 0,
  }) async {
    getStrengthGoalsCalls.add((limit, offset));
  }

  @override
  Future<bool> createStrengthGoal(StrengthGoalInput input) async {
    createdStrengthGoals.add(input);
    if (shouldFail) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to create strength goal',
            ),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    emit(state.copyWith(isLoading: false, error: const Nullable(null)));
    return true;
  }

  @override
  Future<bool> updateStrengthGoal(int id, StrengthGoalInput input) async {
    updatedStrengthGoals.add((id, input));
    if (shouldFail) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to update strength goal',
            ),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    emit(state.copyWith(isLoading: false, error: const Nullable(null)));
    return true;
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
          matching: find.byType(DropdownButtonFormField<MuscleGroup?>),
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
          matching: find.byType(DropdownButtonFormField<MuscleGroup?>),
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
          matching: find.byType(DropdownButtonFormField<MuscleGroup?>),
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
      expect(
        find.text('Please enter a valid YouTube video URL'),
        findsOneWidget,
      );
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

  testWidgets('EditExerciseModal allows clearing existing YouTube URL', (
    tester,
  ) async {
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
  });

  testWidgets(
    'CreateExerciseModal adds primary and secondary muscles for Pull group and filters incompatible muscles when switching group',
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
        'Barbell Row',
      );

      final muscleGroupDropdown = find.descendant(
        of: find.byType(CreateExerciseModal),
        matching: find.byType(DropdownButtonFormField<MuscleGroup?>),
      );
      await tester.tap(muscleGroupDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pull').last);
      await tester.pumpAndSettle();

      // Tapping Add Muscle for primary and secondary should pick Pull muscles
      // (not Muscle.chest) and render without dropdown assertion errors.
      final addMuscleButtons = find.descendant(
        of: find.byType(CreateExerciseModal),
        matching: find.text('Add Muscle'),
      );
      expect(addMuscleButtons, findsNWidgets(2));

      await tester.ensureVisible(addMuscleButtons.at(0));
      await tester.tap(addMuscleButtons.at(0));
      await tester.pumpAndSettle();

      await tester.ensureVisible(addMuscleButtons.at(1));
      await tester.tap(addMuscleButtons.at(1));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<Muscle?>), findsNWidgets(2));

      // Switching MuscleGroup to Legs clears incompatible Pull muscles.
      await tester.ensureVisible(muscleGroupDropdown);
      await tester.tap(muscleGroupDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Legs').last);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<Muscle?>), findsNothing);

      // Re-add a Legs primary muscle and submit.
      await tester.ensureVisible(addMuscleButtons.at(0));
      await tester.tap(addMuscleButtons.at(0));
      await tester.pumpAndSettle();

      final createButton = find.text('CREATE EXERCISE');
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(cubit.createdInputs, hasLength(1));
      expect(cubit.createdInputs.first.muscleGroup, MuscleGroup.legs);
      expect(cubit.createdInputs.first.muscles.primary, {Muscle.quadriceps});
      expect(cubit.createdInputs.first.muscles.secondary, isEmpty);
    },
  );

  testWidgets(
    'EditExerciseModal renders exercises with secondary muscles outside MuscleGroup',
    (tester) async {
      final existing = ExerciseDto(
        id: 21,
        name: 'Barbell Deadlift',
        description: 'Lift bar from floor',
        muscleGroup: MuscleGroup.legs,
        muscles: const TargetMuscles(
          primary: {Muscle.hamstrings, Muscle.glutes},
          secondary: {Muscle.lowerBack, Muscle.forearms},
        ),
        equipments: const [],
        difficulty: Difficulty.intermediate,
        isFavorite: false,
        createdBy: CreatedBy.user,
      );
      final cubit = _FakeExerciseCubit(initialExercise: existing);
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: '/exercises/21',
        routes: [
          GoRoute(
            path: '/exercises/:id',
            builder: (_, _) => const ExerciseDetailScreen(exerciseId: 21),
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

      expect(find.byType(EditExerciseModal), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<Muscle?>), findsNWidgets(4));
    },
  );

  testWidgets(
    'ExerciseDetailScreen Create Goal button uses trophy icon, hides exercise dropdown, creates goal, and pushes to strength goals page',
    (tester) async {
      final exercise = _sampleExercise(id: 33, name: 'Overhead Press');
      final exerciseCubit = _FakeExerciseCubit(initialExercise: exercise);
      final recordCubit = _FakeExerciseRecordCubit();
      final profileCubit = _FakeProfileCubit();
      addTearDown(exerciseCubit.close);
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      final router = GoRouter(
        initialLocation: '/exercises/33',
        routes: [
          GoRoute(
            path: '/exercises/:id',
            builder: (_, _) => const ExerciseDetailScreen(exerciseId: 33),
          ),
          GoRoute(
            path: Routes.strengthGoals.name,
            builder: (_, _) =>
                const Scaffold(body: Text('Strength Goals Destination')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final createGoalBtn = find.byKey(
        const ValueKey('exercise-create-goal-button'),
      );
      expect(createGoalBtn, findsOneWidget);
      expect(
        find.descendant(
          of: createGoalBtn,
          matching: find.byIcon(Icons.emoji_events),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(createGoalBtn);
      await tester.tap(createGoalBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CreateStrengthGoalModal), findsOneWidget);
      expect(
        find.byKey(const ValueKey('strength-goal-exercise-dropdown')),
        findsNothing,
      );
      expect(exerciseCubit.getExercisesCalls, 0);

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-weight-input')),
        '80',
      );
      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-reps-input')),
        '5',
      );
      await tester.tap(
        find.byKey(const ValueKey('strength-goal-submit-button')),
      );
      await tester.pumpAndSettle();

      expect(recordCubit.createdStrengthGoals, hasLength(1));
      expect(recordCubit.createdStrengthGoals.first.exerciseId, 33);
      expect(recordCubit.createdStrengthGoals.first.targetWeight, 80000);
      expect(recordCubit.createdStrengthGoals.first.targetReps, 5);
      expect(recordCubit.createdStrengthGoals.first.targetMaxStrength, 93333);
      expect(find.byType(CreateStrengthGoalModal), findsNothing);
      expect(find.text('Strength Goals Destination'), findsOneWidget);
    },
  );

  testWidgets(
    'ExerciseDetailScreen cancelling CreateStrengthGoalModal does not push to strength goals page',
    (tester) async {
      final exercise = _sampleExercise(id: 34, name: 'Barbell Squat');
      final exerciseCubit = _FakeExerciseCubit(initialExercise: exercise);
      final recordCubit = _FakeExerciseRecordCubit();
      final profileCubit = _FakeProfileCubit();
      addTearDown(exerciseCubit.close);
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      final router = GoRouter(
        initialLocation: '/exercises/34',
        routes: [
          GoRoute(
            path: '/exercises/:id',
            builder: (_, _) => const ExerciseDetailScreen(exerciseId: 34),
          ),
          GoRoute(
            path: Routes.strengthGoals.name,
            builder: (_, _) =>
                const Scaffold(body: Text('Strength Goals Destination')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final createGoalBtn = find.byKey(
        const ValueKey('exercise-create-goal-button'),
      );
      await tester.ensureVisible(createGoalBtn);
      await tester.tap(createGoalBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CreateStrengthGoalModal), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(CreateStrengthGoalModal), findsNothing);
      expect(recordCubit.createdStrengthGoals, isEmpty);
      expect(find.text('Strength Goals Destination'), findsNothing);
      expect(find.byType(ExerciseDetailScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Failed strength goal creation keeps CreateStrengthGoalModal open and does not push to records page',
    (tester) async {
      final exercise = _sampleExercise(id: 35, name: 'Deadlift');
      final exerciseCubit = _FakeExerciseCubit(initialExercise: exercise);
      final recordCubit = _FakeExerciseRecordCubit(shouldFail: true);
      final profileCubit = _FakeProfileCubit();
      addTearDown(exerciseCubit.close);
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      final router = GoRouter(
        initialLocation: '/exercises/35',
        routes: [
          GoRoute(
            path: '/exercises/:id',
            builder: (_, _) => const ExerciseDetailScreen(exerciseId: 35),
          ),
          GoRoute(
            path: Routes.strengthGoals.name,
            builder: (_, _) =>
                const Scaffold(body: Text('Strength Goals Destination')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final createGoalBtn = find.byKey(
        const ValueKey('exercise-create-goal-button'),
      );
      await tester.ensureVisible(createGoalBtn);
      await tester.tap(createGoalBtn);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-weight-input')),
        '140',
      );
      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-reps-input')),
        '5',
      );
      await tester.tap(
        find.byKey(const ValueKey('strength-goal-submit-button')),
      );
      await tester.pumpAndSettle();

      expect(recordCubit.createdStrengthGoals, hasLength(1));
      expect(find.byType(CreateStrengthGoalModal), findsOneWidget);
      expect(find.text('Failed to create strength goal'), findsOneWidget);
      expect(find.text('Strength Goals Destination'), findsNothing);
    },
  );

  testWidgets(
    'CreateStrengthGoalModal without exerciseId displays and validates exercise dropdown',
    (tester) async {
      final exercise = _sampleExercise(id: 1, name: 'Bench Press');
      final exerciseCubit = _FakeExerciseCubit(initialExercise: exercise);
      final recordCubit = _FakeExerciseRecordCubit();
      final profileCubit = _FakeProfileCubit();
      addTearDown(exerciseCubit.close);
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: CreateStrengthGoalModal(
                  theme: Theme.of(context),
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.md),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('strength-goal-exercise-dropdown')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-weight-input')),
        '100',
      );
      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-reps-input')),
        '5',
      );
      await tester.tap(
        find.byKey(const ValueKey('strength-goal-submit-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Please select an exercise'), findsOneWidget);
      expect(recordCubit.createdStrengthGoals, isEmpty);
    },
  );

  testWidgets(
    'CreateStrengthGoalModal allows omitting name and submits Nullable(null)',
    (tester) async {
      final exercise = _sampleExercise(id: 1, name: 'Bench Press');
      final exerciseCubit = _FakeExerciseCubit(initialExercise: exercise);
      final recordCubit = _FakeExerciseRecordCubit();
      final profileCubit = _FakeProfileCubit();
      addTearDown(exerciseCubit.close);
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: CreateStrengthGoalModal(
                  theme: Theme.of(context),
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.md),
                  exerciseId: 1,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-weight-input')),
        '100',
      );
      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-reps-input')),
        '3',
      );
      await tester.tap(
        find.byKey(const ValueKey('strength-goal-submit-button')),
      );
      await tester.pumpAndSettle();

      expect(recordCubit.createdStrengthGoals, hasLength(1));
      expect(recordCubit.createdStrengthGoals.first.name.value, isNull);
      expect(recordCubit.createdStrengthGoals.first.targetMaxStrength, 105882);
    },
  );

  testWidgets(
    'CreateStrengthGoalModal has no starting values and auto-calculates read-only Target 1RM',
    (tester) async {
      final exercise = _sampleExercise(id: 1, name: 'Bench Press');
      final exerciseCubit = _FakeExerciseCubit(initialExercise: exercise);
      final recordCubit = _FakeExerciseRecordCubit();
      final profileCubit = _FakeProfileCubit();
      addTearDown(exerciseCubit.close);
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: CreateStrengthGoalModal(
                  theme: Theme.of(context),
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.md),
                  exerciseId: 1,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      TextField fieldOf(String key) => tester.widget<TextField>(
        find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(TextField),
        ),
      );

      expect(fieldOf('strength-goal-weight-input').controller!.text, isEmpty);
      expect(fieldOf('strength-goal-reps-input').controller!.text, isEmpty);
      expect(
        fieldOf('strength-goal-max-strength-input').controller!.text,
        isEmpty,
      );
      expect(fieldOf('strength-goal-name-input').controller!.text, isEmpty);
      expect(fieldOf('strength-goal-max-strength-input').readOnly, isTrue);

      await tester.tap(
        find.byKey(const ValueKey('strength-goal-submit-button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsNWidgets(2));
      expect(recordCubit.createdStrengthGoals, isEmpty);

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-weight-input')),
        '100',
      );
      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-reps-input')),
        '10',
      );
      await tester.pump();
      expect(
        fieldOf('strength-goal-max-strength-input').controller!.text,
        '133.3',
      );

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-reps-input')),
        '11',
      );
      await tester.pump();
      expect(
        fieldOf('strength-goal-max-strength-input').controller!.text,
        isEmpty,
      );

      await tester.tap(
        find.byKey(const ValueKey('strength-goal-submit-button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Must be between 1 and 10'), findsOneWidget);
      expect(recordCubit.createdStrengthGoals, isEmpty);

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-reps-input')),
        '1',
      );
      await tester.pump();
      expect(
        fieldOf('strength-goal-max-strength-input').controller!.text,
        '100.0',
      );
    },
  );

  testWidgets(
    'CreateStrengthGoalModal calculates Target 1RM in lbs for imperial units and stores grams',
    (tester) async {
      final exercise = _sampleExercise(id: 1, name: 'Squat');
      final exerciseCubit = _FakeExerciseCubit(initialExercise: exercise);
      final recordCubit = _FakeExerciseRecordCubit();
      final profileCubit = _FakeProfileCubit(units: Units.imperial);
      addTearDown(exerciseCubit.close);
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: CreateStrengthGoalModal(
                  theme: Theme.of(context),
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.md),
                  exerciseId: 1,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-weight-input')),
        '225',
      );
      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-reps-input')),
        '5',
      );
      await tester.pump();

      final maxStrengthField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('strength-goal-max-strength-input')),
          matching: find.byType(TextField),
        ),
      );
      expect(maxStrengthField.controller!.text, '262.5');
      expect(find.text('Target 1RM (lbs)'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('strength-goal-submit-button')),
      );
      await tester.pumpAndSettle();

      expect(recordCubit.createdStrengthGoals, hasLength(1));
      expect(recordCubit.createdStrengthGoals.first.targetWeight, 102058);
      expect(recordCubit.createdStrengthGoals.first.targetMaxStrength, 119068);
    },
  );

  testWidgets(
    'EditStrengthGoalModal allows clearing existing goal name and auto-calculates Target 1RM',
    (tester) async {
      final exerciseCubit = _FakeExerciseCubit();
      final recordCubit = _FakeExerciseRecordCubit();
      final profileCubit = _FakeProfileCubit();
      addTearDown(exerciseCubit.close);
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      final existingGoal = StrengthGoalDto(
        id: 7,
        name: 'Summer PR',
        targetReps: 5,
        targetWeight: 100000,
        targetMaxStrength: 116667,
        exerciseId: 1,
        status: ProgressStatus.inProgress,
        startDate: DateTime(2026, 10, 1),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: EditStrengthGoalModal(
                  theme: Theme.of(context),
                  sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.md),
                  existingGoal: existingGoal,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Summer PR'), findsOneWidget);
      final maxStrengthField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('strength-goal-max-strength-input')),
          matching: find.byType(TextField),
        ),
      );
      expect(maxStrengthField.controller!.text, '116.7');

      await tester.enterText(
        find.byKey(const ValueKey('strength-goal-name-input')),
        '   ',
      );
      await tester.tap(
        find.byKey(const ValueKey('strength-goal-submit-button')),
      );
      await tester.pumpAndSettle();

      expect(recordCubit.updatedStrengthGoals, hasLength(1));
      expect(recordCubit.updatedStrengthGoals.first.$1, 7);
      expect(recordCubit.updatedStrengthGoals.first.$2.name.value, isNull);
      expect(
        recordCubit.updatedStrengthGoals.first.$2.targetMaxStrength,
        116667,
      );
    },
  );

  testWidgets(
    'ActiveStrengthGoalCard and StrengthGoalHistoryList handle unnamed goals and display 1RM in user units',
    (tester) async {
      final activeGoal = StrengthGoalDto(
        id: 1,
        name: null,
        targetReps: 8,
        targetWeight: 90000,
        targetMaxStrength: 114000,
        exerciseId: 1,
        status: ProgressStatus.inProgress,
        startDate: DateTime(2025, 10, 10),
      );
      final pastUnnamedGoal = StrengthGoalDto(
        id: 2,
        name: null,
        targetReps: 5,
        targetWeight: 80000,
        targetMaxStrength: 93333,
        exerciseId: 1,
        status: ProgressStatus.completed,
        startDate: DateTime(2025, 9, 1),
        completedAt: DateTime(2025, 9, 20),
      );
      final pastNamedGoal = StrengthGoalDto(
        id: 3,
        name: 'Autumn Peak',
        targetReps: 3,
        targetWeight: 100000,
        targetMaxStrength: 105882,
        exerciseId: 1,
        status: ProgressStatus.abandoned,
        startDate: DateTime(2025, 8, 1),
      );

      final recordCubit = _FakeExerciseRecordCubit(
        activeStrengthGoal: activeGoal,
        strengthGoals: [activeGoal, pastUnnamedGoal, pastNamedGoal],
      );
      final profileCubit = _FakeProfileCubit();
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final sizes = DataDisplaySizes.getDataDisplaySizes(
                  ScreenSize.md,
                );
                final theme = Theme.of(context);
                return Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        ActiveStrengthGoalCard(theme: theme, sizes: sizes),
                        StrengthGoalHistoryList(
                          shrinkWrap: true,
                          theme: theme,
                          sizes: sizes,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Latest Active Goal'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('active-strength-goal-complete-btn')),
        findsNothing,
      );
      expect(find.text('Complete Goal'), findsNothing);
      expect(
        find.byKey(const ValueKey('active-strength-goal-delete-btn')),
        findsOneWidget,
      );
      expect(find.text(' 90.00 KG'), findsOneWidget);
      expect(find.text(' 114.00 KG'), findsOneWidget);
      expect(find.textContaining('Started: 10/10/2025'), findsOneWidget);
      expect(find.byType(ProgressStatusBadge), findsNWidgets(3));
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Abandoned'), findsOneWidget);
      expect(find.byType(ListCard), findsNWidgets(2));
      expect(
        find.text(
          ' ${Formatters.formatRelativeDate(Units.metric, DateTime(2025, 9, 20))}',
        ),
        findsOneWidget,
      );
      expect(find.text(' 80.00 KG'), findsOneWidget);
      expect(find.text(' 93.33 KG'), findsOneWidget);
      expect(find.text(' Autumn Peak'), findsOneWidget);
      expect(find.text(' 100.00 KG'), findsOneWidget);
      expect(find.text(' 105.88 KG'), findsOneWidget);

      final containers = tester.widgetList<Container>(find.byType(Container));
      for (final container in containers) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration) {
          expect(
            decoration.borderRadius == null ||
                decoration.borderRadius == BorderRadius.zero,
            isTrue,
          );
        }
      }
      expect(find.byIcon(Icons.sports_gymnastics), findsNothing);
    },
  );

  testWidgets(
    'ActiveStrengthGoalCard and StrengthGoalHistoryList display exercise names only when populated',
    (tester) async {
      final bench = _sampleExercise(id: 1, name: 'Bench Press');
      final squat = _sampleExercise(id: 2, name: 'Back Squat');
      final incline = _sampleExercise(id: 3, name: 'Incline Press');

      final activeGoal = StrengthGoalDto(
        id: 1,
        name: 'Summer Goal',
        targetReps: 5,
        targetWeight: 100000,
        targetMaxStrength: 116667,
        exerciseId: 1,
        status: ProgressStatus.inProgress,
        startDate: DateTime(2025, 10, 10),
        exercise: bench,
      );
      final pastUnnamedGoal = StrengthGoalDto(
        id: 2,
        name: null,
        targetReps: 5,
        targetWeight: 140000,
        targetMaxStrength: 163333,
        exerciseId: 2,
        status: ProgressStatus.completed,
        startDate: DateTime(2025, 9, 1),
        completedAt: DateTime(2025, 9, 20),
        exercise: squat,
      );
      final pastNamedGoal = StrengthGoalDto(
        id: 3,
        name: 'Autumn Peak',
        targetReps: 3,
        targetWeight: 90000,
        targetMaxStrength: 95294,
        exerciseId: 3,
        status: ProgressStatus.abandoned,
        startDate: DateTime(2025, 8, 1),
        exercise: incline,
      );

      final recordCubit = _FakeExerciseRecordCubit(
        activeStrengthGoal: activeGoal,
        strengthGoals: [activeGoal, pastUnnamedGoal, pastNamedGoal],
      );
      final profileCubit = _FakeProfileCubit();
      addTearDown(recordCubit.close);
      addTearDown(profileCubit.close);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final sizes = DataDisplaySizes.getDataDisplaySizes(
                  ScreenSize.md,
                );
                final theme = Theme.of(context);
                return Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        ActiveStrengthGoalCard(theme: theme, sizes: sizes),
                        StrengthGoalHistoryList(
                          shrinkWrap: true,
                          theme: theme,
                          sizes: sizes,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sports_gymnastics), findsNWidgets(3));
      expect(find.text(' Bench Press'), findsOneWidget);
      expect(find.text('Summer Goal'), findsOneWidget);
      expect(find.text(' Back Squat'), findsOneWidget);
      expect(find.text(' Incline Press'), findsOneWidget);
      expect(find.text('Autumn Peak'), findsOneWidget);
    },
  );

  testWidgets(
    'StrengthGoalsListScreen uses core empty widgets, displays error SnackBar, and paginates history on scroll',
    (tester) async {
      final pastGoals = List.generate(
        10,
        (i) => StrengthGoalDto(
          id: i + 10,
          name: 'Past Goal ${i + 1}',
          targetReps: 5,
          targetWeight: 80000 + (i * 2500),
          targetMaxStrength: 93333 + (i * 2500),
          exerciseId: 1,
          status: ProgressStatus.completed,
          startDate: DateTime(2025, 1, 1 + i),
          completedAt: DateTime(2025, 2, 1 + i),
        ),
      );
      final emptyRecordCubit = _FakeExerciseRecordCubit();
      final profileCubit = _FakeProfileCubit();
      addTearDown(emptyRecordCubit.close);
      addTearDown(profileCubit.close);

      final emptyRouter = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const StrengthGoalsListScreen(),
          ),
        ],
      );
      addTearDown(emptyRouter.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseRecordCubit>.value(value: emptyRecordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp.router(routerConfig: emptyRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No active strength goal'), findsOneWidget);
      expect(find.byType(AppTextButton), findsOneWidget);
      expect(find.text('Goal History'), findsOneWidget);
      expect(find.byType(NotFoundList), findsOneWidget);
      expect(find.text('Empty history'), findsOneWidget);

      emptyRecordCubit.emitError('Failed to load goals');
      await tester.pumpAndSettle();
      expect(find.text('Failed to load goals'), findsOneWidget);

      final paginatedCubit = _FakeExerciseRecordCubit(
        strengthGoals: pastGoals,
        strengthGoalPagination: const StrengthGoalPagination(
          total: 25,
          limit: 10,
          offset: 0,
        ),
      );
      addTearDown(paginatedCubit.close);

      final paginatedRouter = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const StrengthGoalsListScreen(),
          ),
        ],
      );
      addTearDown(paginatedRouter.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseRecordCubit>.value(value: paginatedCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp.router(routerConfig: paginatedRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListCard), findsWidgets);
      final historyListView = find.descendant(
        of: find.byType(StrengthGoalHistoryList),
        matching: find.byType(ListView),
      );
      await tester.drag(historyListView, const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(
        paginatedCubit.getStrengthGoalsCalls.any((call) => call.$2 == 10),
        isTrue,
      );
    },
  );

  testWidgets(
    'ActiveStrengthGoalCard shows error and retry action on activeGoalError instead of stale or empty goal',
    (tester) async {
      final profileCubit = _FakeProfileCubit();
      final recordCubit = _FakeExerciseRecordCubit(
        activeStrengthGoal: StrengthGoalDto(
          id: 11,
          name: 'Bench 100kg',
          targetReps: 5,
          targetWeight: 100000,
          targetMaxStrength: 116667,
          exerciseId: 1,
          status: ProgressStatus.inProgress,
          startDate: DateTime(2026, 1, 1),
        ),
      );
      addTearDown(profileCubit.close);
      addTearDown(recordCubit.close);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ExerciseRecordCubit>.value(value: recordCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ActiveStrengthGoalCard(
                theme: ThemeData.light(),
                sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs),
                units: Units.metric,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bench 100kg'), findsOneWidget);
      expect(find.text('Could not load active strength goal'), findsNothing);

      recordCubit.emitActiveGoalError('Failed to load active strength goal');
      await tester.pumpAndSettle();

      expect(find.text('Could not load active strength goal'), findsOneWidget);
      expect(find.text('Bench 100kg'), findsNothing);
      expect(find.text('No active strength goal'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('active-strength-goal-retry')),
      );
      await tester.pump();

      expect(recordCubit.getActiveStrengthGoalCalls, 1);
    },
  );
}
