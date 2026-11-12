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

import '../../../data/utils/enums.dart';
import '../../../data/utils/json_data.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/utils/converters.dart';
import '../../core/widgets/layout/app_elevated_button.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../core/widgets/mutation_button.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../../workout_plans/view_models/workout_plan_record_cubit.dart';
import '../view_models/active_workout_cubit.dart';
import '../view_models/states/active_workout_state.dart';
import '../widgets/details/complete_modal.dart';
import '../widgets/progress/active_completed_workout.dart';
import '../widgets/progress/active_exercise_card.dart';
import '../widgets/progress/active_progress_bar.dart';
import '../widgets/progress/active_rest_timer.dart';
import '../widgets/progress/active_set_exercise_log.dart';
import '../widgets/progress/not_found_active_workout.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final int workoutId;
  final int? workoutPlanRecordId;
  final int? week;
  final int? day;
  final int? workoutPosition;

  const ActiveWorkoutScreen({
    super.key,
    required this.workoutId,
    this.workoutPlanRecordId,
    this.week,
    this.day,
    this.workoutPosition,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  double _loggedWeight = 0.0;
  int _loggedReps = 0;
  WorkoutSetExerciseDifficultyType _loggedDifficultyType =
      WorkoutSetExerciseDifficultyType.rir;
  int _loggedDifficultyValue = 2;

  void _leaveActiveWorkout() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
        Routes.workoutDetail.name.replaceFirst(
          ':id',
          widget.workoutId.toString(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ActiveWorkoutCubit>().startWorkout(
      widget.workoutId,
      workoutPlanRecordId: widget.workoutPlanRecordId,
      week: widget.week,
      day: widget.day,
      workoutPosition: widget.workoutPosition,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<ActiveWorkoutCubit, ActiveWorkoutState>(
      listenWhen: (previous, current) {
        return previous.isLoading != current.isLoading ||
            previous.error != current.error ||
            previous.isCompleted != current.isCompleted;
      },
      listener: (context, state) async {
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
            if (widget.workoutPlanRecordId != null) {
              await context
                  .read<WorkoutPlanRecordCubit>()
                  .getLatestActivePlanRecord();
              if (!context.mounted) return;
            }
            _leaveActiveWorkout();
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
              final previousRecord = activeState.latestMatchingExerciseRecord;

              return Padding(
                padding: EdgeInsets.all(sizes.viewPadding),
                child: Skeletonizer(
                  enabled:
                      activeState.isLoading &&
                      (workoutSetExercise == null ||
                          exercise == null ||
                          currentSet == null),
                  child: Column(
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
                          toMaxReps: workoutSetExercise.toMaxReps,
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
                                weight:
                                    profileState.system?.units == Units.metric
                                    ? Converters.kgToGrams(_loggedWeight)
                                    : Converters.lbsToGrams(_loggedWeight),
                                setNumber: activeState.currentSetNumber,
                                restSecs: restTime,
                                difficulty: WorkoutSetExerciseDifficulty.create(
                                  value: _loggedDifficultyValue,
                                  type: _loggedDifficultyType,
                                ),
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
                            initialDifficultyType:
                                workoutSetExercise.difficulty?.type ??
                                WorkoutSetExerciseDifficultyType.rir,
                            initialDifficultyValue:
                                workoutSetExercise.difficulty?.value ?? 2,
                            workoutSetExerciseId: workoutSetExercise.id,
                            setNumber: activeState.currentSetNumber,
                            initialWeight:
                                profileState.system?.units == Units.imperial
                                ? Converters.gramsToLbs(
                                    previousRecord?.weightGrams ?? 0,
                                  )
                                : Converters.gramsToKg(
                                    previousRecord?.weightGrams ?? 0,
                                  ),
                            initialReps: previousRecord?.reps ?? 0,
                            isLoading: activeState.isLoading,
                            onLogSet:
                                ({
                                  required weight,
                                  required reps,
                                  required difficulty,
                                }) async {
                                  if (reps <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Please enter valid reps',
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.error,
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _loggedWeight = weight;
                                    _loggedReps = reps;
                                    _loggedDifficultyType = difficulty.type;
                                    _loggedDifficultyValue = difficulty.value;
                                  });

                                  final isLastExercise =
                                      activeState.currentExercisePosition ==
                                      (currentSet.exercises?.length ?? 1) - 1;

                                  final cubit = context
                                      .read<ActiveWorkoutCubit>();
                                  await cubit.logExerciseSet(
                                    position: workoutSetExercise.position,
                                    reps: reps,
                                    weight:
                                        profileState.system?.units ==
                                            Units.metric
                                        ? Converters.kgToGrams(weight)
                                        : Converters.lbsToGrams(weight),
                                    setNumber: activeState.currentSetNumber,
                                    difficulty:
                                        WorkoutSetExerciseDifficulty.create(
                                          value: difficulty.value,
                                          type: difficulty.type,
                                        ),
                                  );

                                  if (mounted) {
                                    final isLastSetOfWorkout =
                                        activeState.currentSetPosition ==
                                            (activeState
                                                        .workout
                                                        ?.sets
                                                        ?.length ??
                                                    0) -
                                                1 &&
                                        activeState.currentSetNumber ==
                                            (currentSet.maxSets ??
                                                currentSet.minSets);

                                    if (isLastExercise && !isLastSetOfWorkout) {
                                      cubit.startRest();
                                    } else {
                                      cubit.nextExercise();
                                    }
                                  }
                                },
                            isOptional:
                                currentSet.maxSets != null &&
                                activeState.currentSetNumber >
                                    currentSet.minSets,
                            onSkip: () {
                              context
                                  .read<ActiveWorkoutCubit>()
                                  .skipToNextSet();
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
                                final cubit = context
                                    .read<ActiveWorkoutCubit>();
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
                                  if (!context.mounted) return;
                                  if (widget.workoutPlanRecordId != null) {
                                    await context
                                        .read<WorkoutPlanRecordCubit>()
                                        .getLatestActivePlanRecord();
                                    if (!context.mounted) return;
                                  }
                                  _leaveActiveWorkout();
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
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (_) => CompleteWorkoutDialog(
                                    workoutName: activeState.workout != null
                                        ? '"${activeState.workout!.name}"'
                                        : "this",
                                  ),
                                );
                              },
                              label: 'Complete',
                              icon: Icons.check,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
