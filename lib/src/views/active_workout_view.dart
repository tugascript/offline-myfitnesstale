import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/active_workout_cubit.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/states/active_workout_state.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../models/workout_set_exercise_model.dart';
import '../utilities/sizes/data_display_sizes.dart';
import '../utilities/sizes/screen_size.dart';
import '../widgets/layout/app_dropdown.dart';
import '../widgets/layout/app_number_wheel.dart';
import '../widgets/layout/app_text_form_field.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/workouts/progress/active_exercise_card.dart';
import '../widgets/workouts/progress/active_info_card.dart';
import '../widgets/workouts/progress/active_progress_bar.dart';
import '../widgets/workouts/progress/active_rest_timer.dart';
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
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  WorkoutSetExerciseDifficultyType? _difficultyType;
  int _difficultyValue = 2;

  String get _units => 'kg'; // Default to kg for now, or fetch from profile

  @override
  void initState() {
    super.initState();
    context.read<ActiveWorkoutCubit>().startWorkout(widget.workoutId);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  String _formatRestTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remainingSeconds}s';
  }

  int _parseWeight(String value) {
    return int.tryParse(value) ?? 0;
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
                        final weight = _parseWeight(_weightController.text);
                        final reps = int.tryParse(_repsController.text);

                        if (weight <= 0 || reps == null || reps <= 0) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Please enter valid weight and reps',
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                          return;
                        }

                        await cubit.logExerciseSet(
                          position: workoutSetExercise.position,
                          reps: reps,
                          weightKg: weight.toDouble(),
                          setNumber: state.currentSetNumber,
                          restSecs: restTime,
                          difficulty:
                              _difficultyType != null ? _difficultyValue : null,
                          difficultyType: _difficultyType?.value,
                        );

                        _weightController.clear();
                        _repsController.clear();

                        if (!mounted) return;
                        cubit.nextExercise();
                      },
                    )
                  else
                    // Log Set inputs
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(sizes.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log Set',
                              style: TextStyle(
                                fontSize: sizes.subtitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: sizes.spacing),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _weightController,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Weight (${_units == Units.imperial.value ? 'lbs' : 'kg'})',
                                      border: const OutlineInputBorder(),
                                      prefixIcon:
                                          const Icon(Icons.fitness_center),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: sizes.subtitleFontSize,
                                    ),
                                  ),
                                ),
                                SizedBox(width: sizes.inputSpacing),
                                Expanded(
                                  child: TextFormField(
                                    controller: _repsController,
                                    decoration: const InputDecoration(
                                      labelText: 'Reps',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.repeat),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: sizes.subtitleFontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: sizes.spacing),
                            _LogSetDifficultyInput(
                              key: ValueKey(workoutSetExercise.id),
                              initialDifficulty: workoutSetExercise.difficulty,
                              theme: theme,
                              sizes: sizes,
                              onChanged: (type, value) {
                                _difficultyType = type;
                                _difficultyValue = value;
                              },
                            ),
                            SizedBox(height: sizes.spacing),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context
                                      .read<ActiveWorkoutCubit>()
                                      .startRest();
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Log Set'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: sizes.padding,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          _weightController.clear();
                          _repsController.clear();
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
                        child: OutlinedButton.icon(
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
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                        ),
                      ),
                      SizedBox(width: sizes.inputSpacing),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await context
                                .read<ActiveWorkoutCubit>()
                                .completeWorkout();
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
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

class _LogSetDifficultyInput extends StatefulWidget {
  final WorkoutSetExerciseDifficulty? initialDifficulty;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final void Function(
    WorkoutSetExerciseDifficultyType? type,
    int value,
  ) onChanged;

  const _LogSetDifficultyInput({
    super.key,
    required this.initialDifficulty,
    required this.theme,
    required this.sizes,
    required this.onChanged,
  });

  @override
  State<_LogSetDifficultyInput> createState() => _LogSetDifficultyInputState();
}

class _LogSetDifficultyInputState extends State<_LogSetDifficultyInput> {
  late WorkoutSetExerciseDifficultyType _type;
  late int _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _type =
        widget.initialDifficulty?.type ?? WorkoutSetExerciseDifficultyType.rir;
    _value = widget.initialDifficulty?.value ?? _type.defaultValue;
    _controller = TextEditingController(text: _formatValue(_value));
    widget.onChanged(_type, _value);
  }

  @override
  void didUpdateWidget(covariant _LogSetDifficultyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDifficulty != widget.initialDifficulty) {
      _type = widget.initialDifficulty?.type ??
          WorkoutSetExerciseDifficultyType.rir;
      _value = widget.initialDifficulty?.value ?? _type.defaultValue;
      _controller.text = _formatValue(_value);
      widget.onChanged(_type, _value);
    }
  }

  String _formatValue(int v) {
    if (_type == WorkoutSetExerciseDifficultyType.rmp) return '$v%';
    return '$v';
  }

  (int, int) get _range => (_type.minValue, _type.maxValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openWheel() {
    final (minVal, maxVal) = _range;
    int initial = _value.clamp(minVal, maxVal);
    final controller = FixedExtentScrollController(
      initialItem: initial - minVal,
    );
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(widget.sizes.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  Text('Difficulty (${_type.value})',
                      style: TextStyle(
                          fontSize: widget.sizes.subtitleFontSize,
                          fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      final idx = controller.selectedItem;
                      final val = minVal + idx;
                      setState(() {
                        _value = val;
                        _controller.text = _formatValue(val);
                      });
                      widget.onChanged(_type, val);
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.sizes.subtitleFontSize * 3 * 5,
              child: AppNumberWheel(
                minValue: minVal,
                maxValue: maxVal,
                scrollController: controller,
                itemExtent: widget.sizes.subtitleFontSize * 3,
                fontSize: widget.sizes.subtitleFontSize,
              ),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: AppTextFormField(
            theme: widget.theme,
            controller: _controller,
            readOnly: true,
            onTap: _openWheel,
            labelText: 'Difficulty',
            hintText: 'Value',
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding,
            isLoading: false,
            filled: true,
            prefixIcon: Icon(Icons.bolt, size: widget.sizes.fontSize * 1.2),
          ),
        ),
        SizedBox(width: widget.sizes.spacing / 2),
        Expanded(
          flex: 3,
          child: AppDropdown<WorkoutSetExerciseDifficultyType>(
            value: _type,
            emptyLabel: 'None',
            items: WorkoutSetExerciseDifficultyType.values,
            labelBuilder: (t) => t.value,
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _type = v;
                _value = _value.clamp(v.minValue, v.maxValue);
                _controller.text = _formatValue(_value);
              });
              widget.onChanged(_type, _value);
            },
            onSaved: (_) {},
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding * 0.4,
            filled: true,
          ),
        ),
      ],
    );
  }
}
