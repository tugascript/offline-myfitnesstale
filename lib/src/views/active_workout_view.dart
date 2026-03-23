import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/widgets/common/mutation_button.dart';
import 'package:myfitnesstale/src/widgets/layout/app_primary_button.dart';

import '../cubits/active_workout_cubit.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/states/active_workout_state.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../utilities/sizes/data_display_sizes.dart';
import '../utilities/sizes/screen_size.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/workouts/progress/active_exercise_card.dart';
import '../widgets/workouts/progress/active_progress_bar.dart';
import '../widgets/workouts/progress/active_rest_timer.dart';
import '../widgets/workouts/progress/active_set_exercise_log.dart';
import 'loading_view.dart';
import 'onboarding_view.dart';

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

  String get _units => 'kg'; // Default to kg for now, or fetch from profile

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
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        if (profileState.isLoading) {
          return const LoadingView();
        }

        return ResponsiveScaffold(
          title: 'Active Workout',
          showBackButton: false,
          isEntity: true,
          body: BlocConsumer<ActiveWorkoutCubit, ActiveWorkoutState>(
            listener: (context, state) {
              final theme = Theme.of(context);
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Error: ${state.error?.toString() ?? 'Unknown error'}'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }

              // If workout is completed, navigate back
              if (state.workoutRecord?.completedAt != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Workout completed!'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
                final navigator = Navigator.of(context);
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    navigator.pop();
                  }
                });
              }
            },
            builder: (context, state) {
              final theme = Theme.of(context);
              final breakpoints = BreakPoint.fromContext(context);
              final sizes = DataDisplaySizes.getDataDisplaySizes(
                breakpoints.screenSize,
              );

              if (state.isLoading && state.workoutRecord == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.workoutRecord == null || state.workout == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: theme.colorScheme.outline),
                      SizedBox(height: sizes.spacing),
                      Text(
                        state.error?.toString() ?? 'Failed to load workout',
                        style: TextStyle(
                          fontSize: sizes.subtitleFontSize,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      SizedBox(height: sizes.spacing),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              final workoutSetExercise = state.currentExercise;
              if (workoutSetExercise == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          size: 64, color: theme.colorScheme.primary),
                      SizedBox(height: sizes.spacing),
                      Text(
                        'All exercises completed!',
                        style: TextStyle(
                          fontSize: sizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: sizes.spacing * 1.5),
                      ElevatedButton(
                        onPressed: () async {
                          await context
                              .read<ActiveWorkoutCubit>()
                              .completeWorkout();
                        },
                        child: const Text('Complete Workout'),
                      ),
                    ],
                  ),
                );
              }

              final exercise = workoutSetExercise.exercise!;
              final currentSet = state.currentSet!;

              return ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: sizes.padding / 2,
                  vertical: sizes.padding,
                ),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  // Progress
                  // TODO: fix progress calculation
                  ActiveProgressBar(
                    sizes: sizes,
                    theme: theme,
                    progress: state.progress,
                    totalSets: state.totalSets,
                    currentSet: state.currentSetNumber,
                    startedAt: state.startedAt ?? DateTime.now(),
                  ),
                  SizedBox(height: sizes.spacing),
                  // Current Exercise
                  ActiveExerciseCard(
                    sizes: sizes,
                    theme: theme,
                    minSets: currentSet.minSets,
                    maxSets: currentSet.maxSets,
                    currentSet: state.currentSetNumber,
                    exercises: currentSet.exercises?.length ?? 0,
                    currentExercise: state.currentExercisePosition + 1,
                    minReps: workoutSetExercise.minReps,
                    maxReps: workoutSetExercise.maxReps,
                    exerciseName: exercise.name,
                    recommendedRestSecs: currentSet.recommendedRestSecs,
                    maxRestSecs: currentSet.maxRestSecs,
                    difficulty: workoutSetExercise.difficulty,
                  ),
                  SizedBox(height: sizes.spacing),
                  // Rest Timer (ascending, green -> yellow -> red)
                  if (state.isResting)
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
                          weightKg: _loggedWeight,
                          setNumber: state.currentSetNumber,
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
                      units: _units == Units.imperial.value ? 'lbs' : 'kg',
                      initialDifficulty: workoutSetExercise.difficulty,
                      workoutSetExerciseId: workoutSetExercise.id,
                      onLogSet: (
                          {required weight,
                          required reps,
                          required difficultyType,
                          required difficultyValue}) {
                        if (reps <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please enter valid reps'),
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
                        context.read<ActiveWorkoutCubit>().startRest();
                      },
                    ),
                  SizedBox(height: sizes.spacing),
                  if (currentSet.maxSets != null &&
                      state.currentSetNumber > currentSet.minSets) ...[
                    SizedBox(height: sizes.spacing),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<ActiveWorkoutCubit>().skipToNextSet();
                        },
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Complete Set & Continue Workout'),
                      ),
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
                          isLoading: state.isLoading,
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
                                      foregroundColor: theme.colorScheme.error,
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
                        child: AppPrimaryButton(
                          theme: theme,
                          isLoading: state.isLoading,
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
              );
            },
          ),
        );
      },
      listener: (context, profileState) {
        if (!profileState.isLoading) {
          if (profileState.profile == null) {
            context.go(OnboardingView.routeName);
          }
          if (profileState.system == null) {
            context.read<ProfileCubit>().loadSystem();
          }
        }
      },
    );
  }
}
