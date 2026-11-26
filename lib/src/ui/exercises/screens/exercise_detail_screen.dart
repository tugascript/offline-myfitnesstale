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
import '../../../data/utils/enums.dart';
import '../../../data/utils/exercise_details.dart';
import '../../../data/utils/json_data.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_elevated_button.dart';
import '../../core/widgets/layout/app_outlined_button.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../core/widgets/video/app_video_player.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/details/edit_exercise_modal.dart';
import '../widgets/details/exercise_header_card.dart';
import '../widgets/strength_goal/create_strength_goal_modal.dart';

const _skeletonExercise = ExerciseDto(
  id: 0,
  name: 'Loading Exercise Name',
  description: 'Loading exercise description placeholder...',
  details: StrengthExerciseDetails(
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    weightProgress: ExerciseWeightProgress.positive,
  ),
  difficulty: Difficulty.beginner,
  createdBy: CreatedBy.system,
);

class ExerciseDetailScreen extends StatefulWidget {
  static const name = "exercise-detail";

  final int exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseCubit>().getExercise(widget.exerciseId);
  }

  void _toggleFavorite(bool isFavorite) {
    final cubit = context.read<ExerciseCubit>();
    if (cubit.state.isLoading) return;
    cubit.updateExerciseFavorite(widget.exerciseId, !isFavorite);
  }

  void _deleteExercise() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Exercise',
        content: 'Are you sure you want to delete this exercise? This action cannot be undone.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          context.read<ExerciseCubit>().deleteExercise(widget.exerciseId);
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(Routes.exercises.name);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<ExerciseCubit, ExerciseState>(
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Navigate back if exercise was deleted
        if (state.selectedExercise == null &&
            state.exercises.isEmpty &&
            !state.isLoading &&
            state.error == null) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exercise deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, exerciseState) {
        final isSkeletonLoading =
            exerciseState.isLoading &&
            (exerciseState.selectedExercise == null ||
                exerciseState.selectedExercise!.id != widget.exerciseId);

        if (!isSkeletonLoading &&
            (exerciseState.selectedExercise == null ||
                exerciseState.selectedExercise!.id != widget.exerciseId)) {
          return AppScaffold(
            title: "Exercise Not Found",
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    exerciseState.error?.description ?? 'Exercise not found',
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

        final exercise = isSkeletonLoading
            ? _skeletonExercise
            : exerciseState.selectedExercise!;

        return ResponsiveScaffold(
          title: isSkeletonLoading ? "Exercise Details" : exercise.name,
          isEntity: !isSkeletonLoading,
          showBackButton: true,
          body: Skeletonizer(
            enabled: isSkeletonLoading,
            child: Padding(
              padding: EdgeInsets.all(sizes.viewPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Header
                  ExerciseHeaderCard(
                    theme: theme,
                    sizes: sizes,
                    exerciseDto: exercise,
                    onFavoriteToggle: () =>
                        _toggleFavorite(exercise.isFavorite),
                  ),

                  SizedBox(height: sizes.spacing * 1.25),

                  // Video Player
                  if (exercise.video != null &&
                      exercise.video!.uri.isNotEmpty) ...[
                    AppVideoPlayer(
                      video: exercise.video!,
                      sizes: sizes,
                      theme: theme,
                    ),
                    SizedBox(height: sizes.spacing * 1.25),
                  ],

                  // Action Buttons (Strength-only progress & goal tracking)
                  if (isSkeletonLoading ||
                      exercise.type == ExerciseType.strength) ...[
                    Row(
                      children: [
                        Expanded(
                          child: AppElevatedButton(
                            theme: theme,
                            isLoading: exerciseState.isLoading,
                            sizes: sizes,
                            onPressed: () {
                              context.push(
                                Routes.exerciseRecords.name.replaceFirst(
                                  ":id",
                                  exercise.id.toString(),
                                ),
                              );
                            },
                            label: 'Log Progress',
                            icon: Icons.history,
                          ),
                        ),
                        SizedBox(width: sizes.spacing),
                        Expanded(
                          child: AppElevatedButton(
                            key: const ValueKey('exercise-create-goal-button'),
                            theme: theme,
                            isLoading: exerciseState.isLoading,
                            isSecondary: true,
                            sizes: sizes,
                            onPressed: () async {
                              final created = await showDialog<bool>(
                                context: context,
                                builder: (context) => CreateStrengthGoalModal(
                                  theme: theme,
                                  sizes: sizes,
                                  exerciseId: exercise.id,
                                ),
                              );
                              if (created == true && context.mounted) {
                                context.push(Routes.strengthGoals.name);
                              }
                            },
                            label: 'Create Goal',
                            icon: Icons.emoji_events,
                          ),
                        ),
                      ],
                    ),
                    if (exercise.createdBy == CreatedBy.user)
                      SizedBox(height: sizes.spacing),
                  ],
                  if (exercise.createdBy == CreatedBy.user) ...[
                    Row(
                      children: [
                        Expanded(
                          child: AppOutlinedButton(
                            isLoading: exerciseState.isLoading,
                            theme: theme,
                            sizes: sizes,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditExerciseModal(
                                  theme: theme,
                                  sizes: sizes,
                                  exercise: exercise,
                                ),
                              );
                            },
                            label: 'EDIT',
                            icon: Icons.edit,
                          ),
                        ),
                        SizedBox(width: sizes.spacing),
                        Expanded(
                          child: AppOutlinedButton(
                            isLoading: exerciseState.isLoading,
                            theme: theme,
                            sizes: sizes,
                            onPressed: _deleteExercise,
                            label: 'DELETE',
                            icon: Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: sizes.spacing * 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
