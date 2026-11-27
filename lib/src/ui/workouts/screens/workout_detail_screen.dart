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
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import '../../../data/repositories/workouts/dtos/workout_cardio_set_exercise_dto.dart';
import '../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../data/repositories/workouts/dtos/workout_set_dto.dart';
import '../../../data/repositories/workouts/dtos/workout_set_exercise_dto.dart';
import '../../../data/utils/enums.dart';
import '../../../data/utils/exercise_details.dart';
import '../../../data/utils/json_data.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/action_buttons.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../core/widgets/mutation_buttons.dart';
import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../widgets/details/empty_sets_card.dart';
import '../widgets/details/workout_block_strip.dart';
import '../widgets/details/workout_cardio_set_card.dart';
import '../widgets/details/workout_header_card.dart';
import '../widgets/details/workout_set_card.dart';
import '../widgets/details/workout_skeleton_placeholder.dart';
import './workout_history_screen.dart';

const _skeletonExercise = ExerciseDto(
  id: 0,
  name: 'Loading Exercise Name',
  description: '',
  details: StrengthExerciseDetails(
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    weightProgress: ExerciseWeightProgress.positive,
  ),
  createdBy: CreatedBy.system,
);

const _skeletonCardioExercise = ExerciseDto(
  id: 0,
  name: 'Loading Cardio Exercise',
  description: '',
  details: CardioExerciseDetails(
    defaultMode: CardioBaseMode.time,
    unitType: CardioUnitType.distance,
    unit: 'km',
  ),
  createdBy: CreatedBy.system,
);

const _skeletonCardioWorkout = WorkoutDto(
  id: 0,
  name: 'Loading Cardio Workout',
  description: 'Loading workout description placeholder...',
  muscleGroups: {},
  muscles: TargetMuscles(primary: {}, secondary: {}),
  difficulty: Difficulty.beginner,
  version: 1,
  isFavorite: false,
  totalSets: 4,
  totalReps: 0,
  editorType: EditorType.cardio,
  createdBy: CreatedBy.system,
  cardioSets: [
    WorkoutCardioSetDto(
      id: -1,
      position: 1,
      setType: CardioSetType.constant,
      restSecs: 60,
      rounds: 1,
      exercises: [
        WorkoutCardioSetExerciseDto(
          id: -1,
          position: 1,
          exerciseId: 0,
          restSecs: 0,
          mode: CardioBaseMode.time,
          quantity: 1200,
          exercise: _skeletonCardioExercise,
        ),
      ],
    ),
    WorkoutCardioSetDto(
      id: -2,
      position: 2,
      setType: CardioSetType.interval,
      restSecs: 90,
      rounds: 3,
      exercises: [
        WorkoutCardioSetExerciseDto(
          id: -2,
          position: 1,
          exerciseId: 0,
          restSecs: 30,
          mode: CardioBaseMode.time,
          quantity: 180,
          exercise: _skeletonCardioExercise,
        ),
      ],
    ),
  ],
);

const _skeletonWorkout = WorkoutDto(
  id: 0,
  name: 'Loading Workout Name',
  description: 'Loading workout description placeholder...',
  muscleGroups: {MuscleGroup.push},
  muscles: TargetMuscles(primary: {}, secondary: {}),
  difficulty: Difficulty.beginner,
  version: 1,
  isFavorite: false,
  totalSets: 9,
  totalReps: 90,
  editorType: EditorType.advanced,
  createdBy: CreatedBy.system,
  sets: [
    WorkoutSetDto(
      id: -1,
      position: 1,
      setType: WorkoutSetType.standard,
      minSets: 3,
      recommendedRestSecs: 90,
      totalExercises: 1,
      totalReps: 30,
      exercises: [
        WorkoutSetExerciseDto(
          id: -1,
          position: 1,
          minReps: 8,
          maxReps: 12,
          exerciseId: 0,
          toMaxReps: false,
          exercise: _skeletonExercise,
        ),
      ],
    ),
    WorkoutSetDto(
      id: -2,
      position: 2,
      setType: WorkoutSetType.standard,
      minSets: 3,
      recommendedRestSecs: 90,
      totalExercises: 1,
      totalReps: 30,
      exercises: [
        WorkoutSetExerciseDto(
          id: -2,
          position: 1,
          minReps: 8,
          maxReps: 12,
          exerciseId: 0,
          toMaxReps: false,
          exercise: _skeletonExercise,
        ),
      ],
    ),
    WorkoutSetDto(
      id: -3,
      position: 3,
      setType: WorkoutSetType.standard,
      minSets: 3,
      recommendedRestSecs: 90,
      totalExercises: 1,
      totalReps: 30,
      exercises: [
        WorkoutSetExerciseDto(
          id: -3,
          position: 1,
          minReps: 8,
          maxReps: 12,
          exerciseId: 0,
          toMaxReps: false,
          exercise: _skeletonExercise,
        ),
      ],
    ),
  ],
);

class WorkoutDetailScreen extends StatefulWidget {
  static const name = "workout-detail";

  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final Map<int, GlobalKey> _blockKeys = {};
  int? _selectedBlockIndex;

  GlobalKey _getBlockKey(int setId) {
    return _blockKeys.putIfAbsent(setId, () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    context.read<WorkoutCubit>().getWorkout(widget.workoutId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    final route = ModalRoute.of(context);

    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          (route?.isCurrent ?? true) &&
          ((previous.selectedWorkout != current.selectedWorkout &&
                  previous.isLoading != current.isLoading) ||
              (previous.error != current.error && current.error != null)),
      listener: (context, workoutState) {
        if (workoutState.isLoading) {
          return;
        }

        if (workoutState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(workoutState.error!.description)),
          );
          return;
        }
      },
      builder: (context, workoutState) {
        final isSkeletonLoading =
            workoutState.isLoading &&
            (workoutState.selectedWorkout == null ||
                workoutState.selectedWorkout!.id != widget.workoutId);

        if (!isSkeletonLoading &&
            (workoutState.selectedWorkout == null ||
                workoutState.selectedWorkout!.id != widget.workoutId)) {
          return AppScaffold(
            title: "Unknown Workout",
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    workoutState.error?.description ?? 'Workout not found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        WorkoutDto? cachedWorkout;
        for (final item in workoutState.workouts) {
          if (item.id == widget.workoutId) {
            cachedWorkout = item;
            break;
          }
        }

        if (isSkeletonLoading && cachedWorkout == null) {
          return ResponsiveScaffold(
            title: "Workout details",
            isEntity: false,
            body: Skeletonizer(
              enabled: true,
              child: WorkoutSkeletonPlaceholder(
                theme: theme,
                sizes: sizes,
                sectionTitle: 'Workout Structure',
              ),
            ),
          );
        }

        final workout = isSkeletonLoading
            ? (cachedWorkout!.isCardio
                  ? _skeletonCardioWorkout
                  : _skeletonWorkout)
            : workoutState.selectedWorkout!;
        final sets = workout.sets ?? const [];
        final cardioSets = workout.cardioSets ?? const [];

        void showDeleteDialog() {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Delete Workout',
              content: 'Are you sure you want to delete this workout? This action cannot be undone.',
              confirmLabel: 'Delete',
              isDestructive: true,
              onConfirm: () {
                final cubit = context.read<WorkoutCubit>();
                context.pop();
                cubit.deleteWorkout(widget.workoutId);
              },
            ),
          );
        }

        return ResponsiveScaffold(
          title: isSkeletonLoading ? "Workout details" : workout.name,
          isEntity: !isSkeletonLoading,
          body: Skeletonizer(
            enabled: isSkeletonLoading,
            child: Padding(
              padding: EdgeInsets.all(sizes.viewPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout Header
                  WorkoutHeaderCard(
                    sizes: sizes,
                    workoutDto: workout,
                    actionButtonPress: () {
                      if (workoutState.isLoading) return;
                      context.read<WorkoutCubit>().updateWorkoutFavorite(
                        workout.id,
                        !workout.isFavorite,
                      );
                    },
                  ),
                  SizedBox(height: sizes.spacing * 1.25),
                  // Workout Structure
                  Text(
                    'Workout Structure',
                    style: TextStyle(
                      fontSize: sizes.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  if (workout.isCardio) ...[
                    if (cardioSets.isEmpty)
                      EmptySetsCard(sizes: sizes)
                    else
                      ...cardioSets.asMap().entries.map((entry) {
                        final index = entry.key;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < cardioSets.length - 1
                                ? sizes.spacing
                                : 0,
                          ),
                          child: WorkoutCardioSetCard(
                            theme: theme,
                            sizes: sizes,
                            set: entry.value,
                            setNumber: index + 1,
                          ),
                        );
                      }),
                    SizedBox(height: sizes.spacing),
                    if (!isSkeletonLoading &&
                        workout.createdBy == CreatedBy.user)
                      MutationButtons(
                        theme: theme,
                        sizes: sizes,
                        isLoading: workoutState.isLoading,
                        onEdit: () =>
                            context.push('/workouts/${workout.id}/edit'),
                        onDelete: showDeleteDialog,
                      ),
                  ] else ...[
                    if (sets.length >= 4) ...[
                      WorkoutBlockStrip(
                        sets: sets,
                        selectedBlockIndex: _selectedBlockIndex,
                        sizes: sizes,
                        theme: theme,
                        onSelectBlock: (index) {
                          setState(() {
                            _selectedBlockIndex = index;
                          });
                          final blockContext = _getBlockKey(sets[index].id)
                              .currentContext;
                          if (blockContext != null) {
                            Scrollable.ensureVisible(
                              blockContext,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: 0.1,
                            );
                          }
                        },
                      ),
                      SizedBox(height: sizes.spacing),
                    ],
                    if (sets.isEmpty)
                      EmptySetsCard(sizes: sizes)
                    else
                      ...sets.asMap().entries.map((entry) {
                        final index = entry.key;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < sets.length - 1 ? sizes.spacing : 0,
                          ),
                          child: WorkoutSetCard(
                            key: _getBlockKey(entry.value.id),
                            theme: theme,
                            isDarkTheme: isDarkTheme,
                            sizes: sizes,
                            set: entry.value,
                            setNumber: index + 1,
                            isSelected:
                                sets.length >= 4 &&
                                _selectedBlockIndex == index,
                          ),
                        );
                      }),
                    SizedBox(height: sizes.spacing),
                    ActionButtons(
                      isLoading: workoutState.isLoading,
                      theme: theme,
                      sizes: sizes,
                      showMutationBtns: workout.createdBy == CreatedBy.user,
                      onStart: () =>
                          context.push("/workouts/${workout.id}/active"),
                      startLabel: 'Start Workout',
                      onEdit: () =>
                          context.push('/workouts/${workout.id}/edit'),
                      onHistory: () => context.push(
                        WorkoutHistoryScreen.location(
                          workoutId: workout.id,
                          version: workout.version,
                        ),
                      ),
                      historyLabel: 'History',
                      onDelete: showDeleteDialog,
                    ),
                  ],
                  SizedBox(height: sizes.spacing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
