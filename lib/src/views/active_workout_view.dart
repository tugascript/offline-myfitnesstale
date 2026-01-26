import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/active_workout_cubit.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/states/active_workout_state.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/workouts/active/active_info_card.dart';
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

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
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
          body: BlocConsumer<ActiveWorkoutCubit, ActiveWorkoutState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Error: ${state.error?.toString() ?? 'Unknown error'}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              // If workout is completed, navigate back
              if (state.workoutRecord?.completedAt != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout completed!'),
                    backgroundColor: Colors.green,
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
              if (state.isLoading && state.workoutRecord == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.workoutRecord == null || state.workout == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        state.error?.toString() ?? 'Failed to load workout',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
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
                      const Icon(Icons.check_circle,
                          size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        'All exercises completed!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
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

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  '${(state.progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: state.progress,
                              backgroundColor: Colors.grey[300],
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Set ${state.currentSetIndex + 1} of ${state.totalSets}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Time: ${_formatDuration(DateTime.now().millisecondsSinceEpoch - (state.startedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch))}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Current Exercise
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (exercise.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                exercise.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ActiveInfoCard(
                                    label: 'Target Reps',
                                    value:
                                        '${workoutSetExercise.minReps}${workoutSetExercise.maxReps != null ? '-${workoutSetExercise.maxReps}' : '+'}',
                                    icon: Icons.repeat,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ActiveInfoCard(
                                    label: 'Rest Time',
                                    value: _formatRestTime(
                                      currentSet.recommendedRestSecs,
                                    ),
                                    icon: Icons.timer,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rest Timer
                    if (state.isResting && state.restTimerSeconds != null)
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Rest Time',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatRestTime(state.restTimerSeconds!),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ActiveWorkoutCubit>().stopRest();
                                },
                                child: const Text('Skip Rest'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (state.isResting && state.restTimerSeconds != null)
                      const SizedBox(height: 16),
                    // Input Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log Set',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _weightController,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Weight (${_units == Units.imperial ? 'lbs' : 'kg'})',
                                      border: const OutlineInputBorder(),
                                      prefixIcon:
                                          const Icon(Icons.fitness_center),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _repsController,
                                    decoration: const InputDecoration(
                                      labelText: 'Reps',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.repeat),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final cubit =
                                      context.read<ActiveWorkoutCubit>();
                                  final weight =
                                      _parseWeight(_weightController.text);
                                  final reps =
                                      int.tryParse(_repsController.text);

                                  if (weight <= 0 ||
                                      reps == null ||
                                      reps <= 0) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter valid weight and reps',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  await cubit.logExerciseSet(
                                    position: workoutSetExercise.position,
                                    reps: reps,
                                    weightKg: weight.toDouble(),
                                  );

                                  // Clear inputs
                                  _weightController.clear();
                                  _repsController.clear();

                                  // Start rest timer
                                  if (!mounted) return;
                                  cubit.startRest(
                                    currentSet.recommendedRestSecs,
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Log Set'),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Navigation Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: state.currentExerciseIndex > 0 ||
                                    state.currentSetIndex > 0
                                ? () {
                                    context
                                        .read<ActiveWorkoutCubit>()
                                        .previousExercise();
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<ActiveWorkoutCubit>().nextExercise();
                              _weightController.clear();
                              _repsController.clear();
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                                        foregroundColor: Colors.red,
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
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
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
