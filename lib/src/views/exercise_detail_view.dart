import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/exercise_cubit.dart';
import '../cubits/states/exercise_state.dart';

import '../models/enums.dart';
import '../models/utilities.dart';
import '../widgets/layout/responsive_scaffold.dart';

class ExerciseDetailView extends StatefulWidget {
  static const routeName = "/exercises/:id";
  static const name = "exercise-detail";

  final int exerciseId;

  const ExerciseDetailView({
    super.key,
    required this.exerciseId,
  });

  @override
  State<ExerciseDetailView> createState() => _ExerciseDetailViewState();
}

class _ExerciseDetailViewState extends State<ExerciseDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseCubit>().getExercise(widget.exerciseId);
  }

  // TODO: fix me
  void _toggleFavorite() {
    context.read<ExerciseCubit>().updateExercise(
          id: widget.exerciseId,
          isFavorite: true,
        );
  }

  void _deleteExercise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: const Text(
          'Are you sure you want to delete this exercise? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ExerciseCubit>().deleteExercise(widget.exerciseId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getMuscleGroupName(MuscleGroup muscleGroup) {
    return EnumDisplayNames.getMuscleGroupDisplayName(muscleGroup);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: "Exercise Details",
      showBackButton: true,
      body: BlocConsumer<ExerciseCubit, ExerciseState>(
        listener: (context, state) {
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
              !state.isLoading) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Exercise deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Load related exercises when exercise is loaded
          if (state.selectedExercise != null &&
              state.relatedExercises.isEmpty) {
            // We check isEmpty to avoid infinite loop if it's already loaded or loading.
            // However, since we clear it on getExercise, it should be empty initially.
            // To be safe against potential loops if fetch fails and remains empty,
            // maybe check if we just loaded the exercise?
            // But relying on empty check is standard for "load once".
            context.read<ExerciseCubit>().getRelatedExercises(
                  muscleGroup: state.selectedExercise!.muscleGroup,
                );
          }
        },
        builder: (context, exerciseState) {
          if (exerciseState.isLoading &&
              exerciseState.selectedExercise == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final exercise = exerciseState.selectedExercise;
          if (exercise == null) {
            return const Center(
              child: Text('Exercise not found'),
            );
          }

          final muscleGroupName = _getMuscleGroupName(exercise.muscleGroup);

          // Show all muscles (primary and secondary)
          final allMuscles = <Muscle>{
            ...exercise.muscles.primaryMuscles,
            ...exercise.muscles.secondaryMuscles,
          };

          final equipments = exercise.equipments ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Name and Favorite
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        exercise.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: exercise.isFavorite ? Colors.red : null,
                      ),
                      onPressed: _toggleFavorite,
                      tooltip: exercise.isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Muscle Group and Difficulty
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(muscleGroupName),
                      avatar: const Icon(Icons.fitness_center, size: 18),
                    ),
                    if (exercise.difficulty != null)
                      Chip(
                        label: Text(_difficultyLabel(
                            Difficulty.fromValue(exercise.difficulty!))),
                        avatar: Icon(
                          Icons.trending_up,
                          size: 18,
                          color: _difficultyColor(
                              Difficulty.fromValue(exercise.difficulty!)),
                        ),
                        backgroundColor: _difficultyColor(
                                Difficulty.fromValue(exercise.difficulty!))
                            .withValues(alpha: 0.2),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Description
                if (exercise.description.isNotEmpty) ...[
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ],
                // Muscles Targeted
                if (allMuscles.isNotEmpty) ...[
                  const Text(
                    'Muscles Targeted',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allMuscles.map((muscle) {
                      return Chip(
                        label:
                            Text(EnumDisplayNames.getMuscleDisplayName(muscle)),
                        avatar: const Icon(Icons.accessibility_new, size: 18),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Video Placeholder
                if (exercise.video != null &&
                    exercise.video!.uri.isNotEmpty) ...[
                  const Text(
                    'Video',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video: ${exercise.video!.platform.value}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.video!.uri,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Equipment
                if (equipments.isNotEmpty) ...[
                  const Text(
                    'Equipment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: equipments.map((equipment) {
                      return Chip(
                        label: Text(equipment.name),
                        avatar: const Icon(Icons.build, size: 18),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () {
                          context.push('/exercises/${exercise.id}/edit');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: _deleteExercise,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Related Exercises (same muscle group)
                const Text(
                  'Related Exercises',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (exerciseState.relatedExercises.isEmpty)
                  const Text(
                    'No related exercises found',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Column(
                    children: exerciseState.relatedExercises
                        .where((e) => e.id != exercise.id)
                        .take(5)
                        .map((relatedExercise) {
                      return ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text(relatedExercise.name),
                        trailing: relatedExercise.isFavorite
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : null,
                        onTap: () {
                          // If we push to same route, we might need to update exerciseId.
                          // Since route is /exercises/:id, push will trigger new page?
                          // Or standard behavior.
                          // Better to use push (stack)
                          context.push('/exercises/${relatedExercise.id}');
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'Beginner-Intermediate';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'Intermediate-Advanced';
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
}
