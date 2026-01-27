import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/states/workout_state.dart';
import '../cubits/workout_cubit.dart';
import '../models/enums.dart';
import '../widgets/layout/responsive_scaffold.dart';

class WorkoutDetailView extends StatefulWidget {
  static const routeName = "workout-detail";
  static const routePath = "/workouts/:id";

  final int workoutId;

  const WorkoutDetailView({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutCubit>().getWorkout(widget.workoutId);
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'Beginner / Intermediate';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'Intermediate / Advanced';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.beginnerIntermediate:
        return Colors.lightGreen;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.intermediateAdvanced:
        return Colors.deepOrange;
      case Difficulty.advanced:
        return Colors.red;
    }
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

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Workout Details',
      body: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, workoutState) {
          if (workoutState.isLoading && workoutState.selectedWorkout == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final selectedWorkout = workoutState.selectedWorkout;
          if (selectedWorkout == null) {
            return Center(
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
            );
          }

          final workout = selectedWorkout;
          final difficultyColor = _difficultyColor(workout.difficulty);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                workout.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Difficulty Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: difficultyColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: difficultyColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _difficultyLabel(workout.difficulty),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: difficultyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (workout.description != null &&
                            workout.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            workout.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                        // Muscle Groups
                        if (selectedWorkout.muscleGroups.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedWorkout.muscleGroups.map((mg) {
                              return Chip(
                                label: Text(mg.name),
                                avatar: const Icon(
                                  Icons.fitness_center,
                                  size: 18,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/workouts/${workout.id}/active');
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Workout'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/workouts/${workout.id}/edit');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Workout Sets
                Text(
                  'Workout Sets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                if (workoutState.isLoading &&
                    workoutState.selectedWorkout == null)
                  const Center(child: CircularProgressIndicator())
                else if (workoutState.selectedWorkout != null &&
                    workoutState.selectedWorkout!.sets != null &&
                    workoutState.selectedWorkout!.sets!.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sets configured',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add sets and exercises to this workout',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...workoutState.selectedWorkout!.sets!
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final workoutSet = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'Set ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${workoutSet.minSets}${workoutSet.maxSets != null ? '-${workoutSet.maxSets}' : '+'} sets',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (workoutSet.recommendedRestSecs > 0)
                              Text(
                                'Rest: ${_formatRestTime(workoutSet.recommendedRestSecs)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                        children: [
                          if (workoutSet.exercises?.isEmpty ?? true)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No exercises in this set',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            ...workoutSet.exercises!
                                .map((exerciseWithExercise) {
                              final exercise = exerciseWithExercise.exercise!;
                              return ListTile(
                                leading: const Icon(Icons.fitness_center),
                                title: Text(exercise.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${exerciseWithExercise.minReps}${exerciseWithExercise.maxReps != null ? '-${exerciseWithExercise.maxReps}' : '+'} reps',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (exerciseWithExercise
                                            .options?.isNotEmpty ??
                                        false)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Wrap(
                                          spacing: 4,
                                          children: [
                                            Text(
                                              'Alternatives:',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                            ...exerciseWithExercise.options!
                                                .map((opt) => Text(
                                                      opt.exercise!.name,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey[500],
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    )),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  context.push('/exercises/${exercise.id}');
                                },
                              );
                            }),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                // Workout History (Placeholder for Phase 5)
                Text(
                  'Workout History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Workout history will be displayed here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
