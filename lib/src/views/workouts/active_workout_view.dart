import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../cubits/active_workout_cubit.dart';
import '../../cubits/profile_cubit.dart';
import '../../cubits/states/active_workout_state.dart';
import '../../cubits/states/profile_state.dart';
import '../../models/enums.dart';
import '../../utilities/converters.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/mutation_button.dart';
import '../../widgets/layout/app_elevated_button.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workouts/progress/active_completed_workout.dart';
import '../../widgets/workouts/progress/active_exercise_card.dart';
import '../../widgets/workouts/progress/active_progress_bar.dart';
import '../../widgets/workouts/progress/active_rest_timer.dart';
import '../../widgets/workouts/progress/active_set_exercise_log.dart';
import '../../widgets/workouts/progress/not_found_active_workout.dart';

class ActiveWorkoutView extends StatefulWidget {
  final int workoutId;

  const ActiveWorkoutView({
    super.key,
    required this.workoutId,
  });

  @override
  State<ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends State<ActiveWorkoutView> {
  double _loggedWeight = 0.0;
  int _loggedReps = 0;
  WorkoutSetExerciseDifficultyType? _loggedDifficultyType;
  int? _loggedDifficultyValue;

  @override
  void initState() {
    super.initState();
    context.read<ActiveWorkoutCubit>().startWorkout(widget.workoutId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

    return BlocConsumer<ActiveWorkoutCubit, ActiveWorkoutState>(
      listenWhen: (previous, current) {
        return previous.isLoading != current.isLoading ||
            previous.error != current.error ||
            previous.isCompleted != current.isCompleted;
      },
      listener: (context, state) {
        if (!state.isLoading) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${state.error?.toString() ?? 'Unknown error'}',
                ),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
          if (state.isCompleted) {
            context.pop();
          }
        }
      },
      builder: (context, activeState) {
        return ResponsiveScaffold(
          title: activeState.isLoading && activeState.workout == null
              ? "Loading..."
              : activeState.workout?.name ?? "Active Workout",
          showBackButton: false,
          isEntity: true,
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final workoutSetExercise = activeState.currentExercise;
              final exercise = workoutSetExercise?.exercise;
              final currentSet = activeState.currentSet;

              return Skeletonizer(
                enabled: activeState.isLoading &&
                    (workoutSetExercise == null ||
                        exercise == null ||
                        currentSet == null),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.padding / 2,
                    vertical: sizes.padding,
                  ),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    ActiveProgressBar(
                      sizes: sizes,
                      theme: theme,
                      progress: activeState.progress,
                      totalSets: activeState.totalSets,
                      currentSet: activeState.totalCurrentSet,
                    ),
                    SizedBox(height: sizes.spacing),
                    if (activeState.isCompleted)
                      ActiveCompletedWorkout(
                        breakPoint: breakpoints,
                        sizes: sizes,
                        theme: theme,
                      )
                    else if (workoutSetExercise == null ||
                        exercise == null ||
                        currentSet == null)
                      NotFoundActiveWorkout(
                        theme: theme,
                        breakPoint: breakpoints,
                        sizes: sizes,
                      )
                    else ...[
                      ActiveExerciseCard(
                        sizes: sizes,
                        theme: theme,
                        minSets: currentSet.minSets,
                        maxSets: currentSet.maxSets,
                        currentSet: activeState.currentSetNumber,
                        exercises: currentSet.exercises?.length ?? 0,
                        currentExercise:
                            activeState.currentExercisePosition + 1,
                        minReps: workoutSetExercise.minReps,
                        maxReps: workoutSetExercise.maxReps,
                        exerciseName: exercise.name,
                        recommendedRestSecs: currentSet.recommendedRestSecs,
                        maxRestSecs: currentSet.maxRestSecs,
                        difficulty: workoutSetExercise.difficulty,
                      ),
                      SizedBox(height: sizes.spacing),
                      if (activeState.isResting)
                        ActiveRestTimer(
                          breakPoint: breakpoints,
                          sizes: sizes,
                          theme: theme,
                          recommendedSecs: currentSet.recommendedRestSecs,
                          maxSecs: currentSet.maxRestSecs,
                          onNext: (int restTime) async {
                            final cubit = context.read<ActiveWorkoutCubit>();

                            await cubit.logExerciseSet(
                              position: workoutSetExercise.position,
                              reps: _loggedReps,
                              weight: profileState.system?.units == Units.metric
                                  ? Converters.kgToGrams(_loggedWeight)
                                  : Converters.lbsToGrams(_loggedWeight),
                              setNumber: activeState.currentSetNumber,
                              restSecs: restTime,
                              difficulty: _loggedDifficultyType != null
                                  ? _loggedDifficultyValue
                                  : null,
                              difficultyType: _loggedDifficultyType?.value,
                            );

                            if (!mounted) return;
                            cubit.nextExercise();
                          },
                        )
                      else
                        // Log Set inputs
                        ActiveSetExerciseLog(
                          theme: theme,
                          sizes: sizes,
                          units: profileState.system?.units ?? Units.metric,
                          initialDifficulty: workoutSetExercise.difficulty,
                          workoutSetExerciseId: workoutSetExercise.id,
                          isLoading: activeState.isLoading,
                          onLogSet: ({
                            required weight,
                            required reps,
                            required difficultyType,
                            required difficultyValue,
                          }) async {
                            if (reps <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Please enter valid reps'),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _loggedWeight = weight;
                              _loggedReps = reps;
                              _loggedDifficultyType = difficultyType;
                              _loggedDifficultyValue = difficultyValue;
                            });

                            final isLastExercise =
                                activeState.currentExercisePosition ==
                                    (currentSet.exercises?.length ?? 1) - 1;

                            if (isLastExercise) {
                              context.read<ActiveWorkoutCubit>().startRest();
                            } else {
                              final cubit = context.read<ActiveWorkoutCubit>();
                              await cubit.logExerciseSet(
                                position: workoutSetExercise.position,
                                reps: reps,
                                weight:
                                    profileState.system?.units == Units.metric
                                        ? Converters.kgToGrams(weight)
                                        : Converters.lbsToGrams(weight),
                                setNumber: activeState.currentSetNumber,
                                difficulty: difficultyType != null
                                    ? difficultyValue
                                    : null,
                                difficultyType: difficultyType?.value,
                              );

                              if (mounted) {
                                cubit.nextExercise();
                              }
                            }
                          },
                          isOptional: currentSet.maxSets != null &&
                              activeState.currentSetNumber > currentSet.minSets,
                          onSkip: () {
                            context.read<ActiveWorkoutCubit>().skipToNextSet();
                          },
                        ),
                    ],
                    SizedBox(height: sizes.spacing),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: MutationButton(
                            theme: theme,
                            sizes: sizes,
                            label: "CANCEL",
                            icon: Icons.close,
                            isLoading: activeState.isLoading,
                            onPressed: () async {
                              if (!mounted) return;
                              final cubit = context.read<ActiveWorkoutCubit>();
                              final navigator = Navigator.of(context);
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Cancel Workout'),
                                  content: const Text(
                                    'Are you sure you want to cancel this workout? All progress will be lost.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.error,
                                      ),
                                      child: const Text('Yes, Cancel'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await cubit.cancelWorkout();
                                if (!mounted) return;
                                navigator.pop();
                              }
                            },
                          ),
                        ),
                        SizedBox(width: sizes.inputSpacing),
                        Expanded(
                          child: AppElevatedButton(
                            theme: theme,
                            isLoading: activeState.isLoading,
                            sizes: sizes,
                            onPressed: () async {
                              await context
                                  .read<ActiveWorkoutCubit>()
                                  .completeWorkout();
                            },
                            label: 'Complete',
                            icon: Icons.check,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
