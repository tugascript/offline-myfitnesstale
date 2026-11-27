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

import '../../../data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import '../../../data/repositories/workouts/dtos/workout_cardio_set_exercise_dto.dart';
import '../../../data/utils/enums.dart';
import '../../../data/utils/exercise_details.dart';
import '../../../data/utils/json_data.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/utils/converters.dart';
import '../../core/widgets/layout/app_elevated_button.dart';
import '../../core/widgets/layout/app_outlined_button.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../../workout_plans/view_models/workout_plan_record_cubit.dart';
import '../view_models/active_workout_cubit.dart';
import '../view_models/states/active_workout_state.dart';
import '../widgets/details/complete_modal.dart';
import '../widgets/progress/active_cardio_exercise_card.dart';
import '../widgets/progress/active_cardio_time_exercise.dart';
import '../widgets/progress/active_cardio_units_exercise.dart';
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

  int _loggedCardioQuantity = 0;
  int _loggedCardioDurationSecs = 0;
  int _loggedCardioRpe = WorkoutSetExerciseDifficultyType.rpe.defaultValue;
  bool _loggedCardioRoundCompleted = false;

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

  Future<void> _handleCompleteCardioExercise({
    required ActiveWorkoutState activeState,
    required WorkoutCardioSetDto currentCardioSet,
    required WorkoutCardioSetExerciseDto cardioExercise,
    required int quantity,
    required int durationSecs,
    required int rpe,
  }) async {
    final totalBlocks = activeState.workout?.cardioSets?.length ?? 0;
    final totalExercises = currentCardioSet.exercises?.length ?? 1;
    final isLastExerciseInRound =
        activeState.currentExercisePosition >= totalExercises - 1;
    final isLastRoundInBlock =
        activeState.currentSetNumber >= currentCardioSet.rounds;
    final isLastBlock = activeState.currentSetPosition >= totalBlocks - 1;
    final isFinalStepOfWorkout =
        isLastExerciseInRound && isLastRoundInBlock && isLastBlock;

    setState(() {
      _loggedCardioQuantity = quantity;
      _loggedCardioDurationSecs = durationSecs;
      _loggedCardioRpe = rpe;
      _loggedCardioRoundCompleted = isLastExerciseInRound;
    });

    final cubit = context.read<ActiveWorkoutCubit>();
    await cubit.logCardioExerciseSet(
      position: cardioExercise.position,
      mode: cardioExercise.mode,
      quantity: quantity,
      durationSecs: durationSecs,
      roundNumber: activeState.currentSetNumber,
      rpe: rpe,
      markRoundCompleted: isLastExerciseInRound,
    );

    if (!mounted || cubit.state.error != null) return;

    if (isFinalStepOfWorkout) {
      cubit.nextExercise();
      return;
    }

    if (!isLastExerciseInRound) {
      if (currentCardioSet.setType == CardioSetType.interval &&
          cardioExercise.restSecs > 0) {
        cubit.startRest(
          recommendedSecs: cardioExercise.restSecs,
          isRoundRest: false,
        );
      } else {
        cubit.nextExercise();
      }
      return;
    }

    if (currentCardioSet.restSecs > 0) {
      cubit.startRest(
        recommendedSecs: currentCardioSet.restSecs,
        isRoundRest: true,
      );
    } else if (!isLastRoundInBlock &&
        currentCardioSet.setType == CardioSetType.interval &&
        cardioExercise.restSecs > 0) {
      cubit.startRest(
        recommendedSecs: cardioExercise.restSecs,
        isRoundRest: false,
      );
    } else {
      cubit.nextExercise();
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
              final isCardio = activeState.isCardio;
              final workoutSetExercise = activeState.currentExercise;
              final exercise = workoutSetExercise?.exercise;
              final currentSet = activeState.currentSet;
              final previousRecord = activeState.latestMatchingExerciseRecord;

              final currentCardioSet = activeState.currentCardioSet;
              final currentCardioExercise = activeState.currentCardioExercise;
              final cardioExerciseDto = currentCardioExercise?.exercise;
              final previousCardioRecord =
                  activeState.latestMatchingCardioExerciseRecord;

              final isMissingStep = isCardio
                  ? (currentCardioSet == null ||
                        currentCardioExercise == null ||
                        cardioExerciseDto == null)
                  : (workoutSetExercise == null ||
                        exercise == null ||
                        currentSet == null);

              final totalBlocks = activeState.workout?.cardioSets?.length ?? 0;
              final totalCardioExercises =
                  currentCardioSet?.exercises?.length ?? 1;
              final isFinalCardioStep =
                  isCardio &&
                  currentCardioSet != null &&
                  activeState.currentExercisePosition >=
                      totalCardioExercises - 1 &&
                  activeState.currentSetNumber >= currentCardioSet.rounds &&
                  activeState.currentSetPosition >= totalBlocks - 1;

              return Padding(
                padding: EdgeInsets.all(sizes.viewPadding),
                child: Skeletonizer(
                  enabled: activeState.isLoading && isMissingStep,
                  child: Column(
                    children: [
                      ActiveProgressBar(
                        sizes: sizes,
                        theme: theme,
                        progress: activeState.progress,
                        totalSets: activeState.totalSets,
                        currentSet: activeState.totalCurrentSet,
                        unitLabel: isCardio ? 'Round' : 'Set',
                      ),
                      SizedBox(height: sizes.spacing),
                      if (activeState.isCompleted)
                        ActiveCompletedWorkout(
                          breakPoint: breakpoints,
                          sizes: sizes,
                          theme: theme,
                        )
                      else if (isMissingStep)
                        NotFoundActiveWorkout(
                          theme: theme,
                          breakPoint: breakpoints,
                          sizes: sizes,
                        )
                      else if (isCardio) ...[
                        ActiveCardioExerciseCard(
                          sizes: sizes,
                          theme: theme,
                          setType: currentCardioSet!.setType,
                          currentBlock: activeState.currentSetPosition + 1,
                          totalBlocks: totalBlocks,
                          currentRound: activeState.currentSetNumber,
                          totalRounds: currentCardioSet.rounds,
                          currentExercise:
                              activeState.currentExercisePosition + 1,
                          totalExercises: totalCardioExercises,
                          exerciseName: cardioExerciseDto!.name,
                          mode: currentCardioExercise!.mode,
                          targetQuantity: currentCardioExercise.quantity,
                          unit: cardioExerciseDto
                              .getDetails<CardioExerciseDetails>()
                              ?.unit,
                          exerciseRestSecs: currentCardioExercise.restSecs,
                          setRestSecs: currentCardioSet.restSecs,
                        ),
                        SizedBox(height: sizes.spacing),
                        if (activeState.isResting)
                          ActiveRestTimer(
                            breakPoint: breakpoints,
                            sizes: sizes,
                            theme: theme,
                            recommendedSecs:
                                (activeState.pendingRestSecs ??
                                        currentCardioSet.restSecs) >
                                    0
                                ? (activeState.pendingRestSecs ??
                                      currentCardioSet.restSecs)
                                : 1,
                            onNext: (int restTime) async {
                              final cubit = context.read<ActiveWorkoutCubit>();
                              await cubit.logCardioExerciseSet(
                                position: currentCardioExercise.position,
                                mode: currentCardioExercise.mode,
                                quantity: _loggedCardioQuantity,
                                durationSecs: _loggedCardioDurationSecs,
                                roundNumber: activeState.currentSetNumber,
                                rpe: _loggedCardioRpe,
                                exerciseRestSecs: activeState.isRoundRest
                                    ? 0
                                    : restTime,
                                roundRestSecs: activeState.isRoundRest
                                    ? restTime
                                    : null,
                                markRoundCompleted: _loggedCardioRoundCompleted,
                              );
                              if (!mounted || cubit.state.error != null) return;
                              cubit.nextExercise();
                            },
                          )
                        else if (currentCardioExercise.mode ==
                            CardioBaseMode.time)
                          ActiveCardioTimeExercise(
                            sizes: sizes,
                            theme: theme,
                            workoutCardioSetExerciseId:
                                currentCardioExercise.id,
                            roundNumber: activeState.currentSetNumber,
                            targetSecs: currentCardioExercise.quantity,
                            initialRpe:
                                previousCardioRecord?.rpe ??
                                WorkoutSetExerciseDifficultyType
                                    .rpe
                                    .defaultValue,
                            isLoading: activeState.isLoading,
                            completeLabel: isFinalCardioStep
                                ? 'Finish Workout'
                                : 'Complete & Next',
                            onComplete:
                                ({required int elapsedSecs, required int rpe}) {
                                  _handleCompleteCardioExercise(
                                    activeState: activeState,
                                    currentCardioSet: currentCardioSet,
                                    cardioExercise: currentCardioExercise,
                                    quantity: elapsedSecs,
                                    durationSecs: elapsedSecs,
                                    rpe: rpe,
                                  );
                                },
                          )
                        else
                          ActiveCardioUnitsExercise(
                            sizes: sizes,
                            theme: theme,
                            workoutCardioSetExerciseId:
                                currentCardioExercise.id,
                            roundNumber: activeState.currentSetNumber,
                            initialQuantity:
                                previousCardioRecord?.quantity ??
                                currentCardioExercise.quantity,
                            unit: cardioExerciseDto
                                .getDetails<CardioExerciseDetails>()
                                ?.unit,
                            initialRpe:
                                previousCardioRecord?.rpe ??
                                WorkoutSetExerciseDifficultyType
                                    .rpe
                                    .defaultValue,
                            isLoading: activeState.isLoading,
                            completeLabel: isFinalCardioStep
                                ? 'Finish Workout'
                                : 'Complete & Next',
                            onComplete:
                                ({
                                  required int quantity,
                                  required int elapsedSecs,
                                  required int rpe,
                                }) {
                                  _handleCompleteCardioExercise(
                                    activeState: activeState,
                                    currentCardioSet: currentCardioSet,
                                    cardioExercise: currentCardioExercise,
                                    quantity: quantity,
                                    durationSecs: elapsedSecs,
                                    rpe: rpe,
                                  );
                                },
                          ),
                      ] else ...[
                        ActiveExerciseCard(
                          sizes: sizes,
                          theme: theme,
                          minSets: currentSet!.minSets,
                          maxSets: currentSet.maxSets,
                          currentSet: activeState.currentSetNumber,
                          exercises: currentSet.exercises?.length ?? 0,
                          currentExercise:
                              activeState.currentExercisePosition + 1,
                          minReps: workoutSetExercise!.minReps,
                          maxReps: workoutSetExercise.maxReps,
                          toMaxReps: workoutSetExercise.toMaxReps,
                          exerciseName: exercise!.name,
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
                            child: AppOutlinedButton(
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
