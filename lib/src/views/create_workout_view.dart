import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/exercise_cubit.dart';
import '../cubits/muscle_group_cubit.dart';
import '../cubits/workout_cubit.dart';
import '../cubits/workout_set_cubit.dart';
import '../models/enums.dart';
import '../services/exercise_service.dart';
import '../services/workout_set_service.dart';
import '../widgets/exercise/exercise_selection_widget.dart';
import '../widgets/layout/responsive_scaffold.dart';

class CreateWorkoutView extends StatefulWidget {
  final int? workoutId; // If provided, we're editing

  const CreateWorkoutView({
    super.key,
    this.workoutId,
  });

  @override
  State<CreateWorkoutView> createState() => _CreateWorkoutViewState();
}

class _CreateWorkoutViewState extends State<CreateWorkoutView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Difficulty _selectedDifficulty = Difficulty.beginner;

  // Workout sets data
  final List<WorkoutSetData> _workoutSets = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.workoutId != null) {
      _loadWorkoutForEditing();
    }
  }

  Future<void> _loadWorkoutForEditing() async {
    final workoutCubit = context.read<WorkoutCubit>();
    final setCubit = context.read<WorkoutSetCubit>();

    await workoutCubit.getWorkout(widget.workoutId!);
    await setCubit.getWorkoutSets(widget.workoutId!);

    if (mounted) {
      final workout = workoutCubit.state.selectedWorkout;
      if (workout != null) {
        _nameController.text = workout.name;
        _descriptionController.text = workout.description ?? '';
        _selectedDifficulty = workout.difficulty;
      }

      final sets = setCubit.state.workoutSets;
      _workoutSets.clear();
      for (final set in sets) {
        _workoutSets.add(WorkoutSetData(
          minSets: set.workoutSet.minSets,
          maxSets: set.workoutSet.maxSets,
          recommendedRestSecs: set.workoutSet.recommendedRestSecs,
          maxRestSecs: set.workoutSet.maxRestSecs,
          exercises: set.exercises
              .map((e) => ExerciseData(
                    exerciseId: e.exercise.id!,
                    exerciseName: e.exercise.name,
                    minReps: e.workoutSetExercise.minReps,
                    maxReps: e.workoutSetExercise.maxReps,
                  ))
              .toList(),
        ));
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  void _addWorkoutSet() {
    setState(() {
      _workoutSets.add(WorkoutSetData());
    });
  }

  void _removeWorkoutSet(int index) {
    setState(() {
      _workoutSets.removeAt(index);
    });
  }

  void _moveSetUp(int index) {
    if (index > 0) {
      setState(() {
        final set = _workoutSets.removeAt(index);
        _workoutSets.insert(index - 1, set);
      });
    }
  }

  void _moveSetDown(int index) {
    if (index < _workoutSets.length - 1) {
      setState(() {
        final set = _workoutSets.removeAt(index);
        _workoutSets.insert(index + 1, set);
      });
    }
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_workoutSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one workout set'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate all sets have exercises
    for (int i = 0; i < _workoutSets.length; i++) {
      if (_workoutSets[i].exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Set ${i + 1} must have at least one exercise'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final workoutCubit = context.read<WorkoutCubit>();
      final setCubit = context.read<WorkoutSetCubit>();

      int workoutId;
      if (widget.workoutId != null) {
        // Update existing workout
        await workoutCubit.updateWorkout(
          widget.workoutId!,
          name: _nameController.text.trim(),
          difficulty: _selectedDifficulty,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
        workoutId = widget.workoutId!;

        // Delete existing sets and recreate them
        final existingSets = setCubit.state.workoutSets;
        for (final set in existingSets) {
          await setCubit.deleteWorkoutSet(set.workoutSet.id!);
        }
      } else {
        // Create new workout
        await workoutCubit.createWorkout(
          name: _nameController.text.trim(),
          difficulty: _selectedDifficulty,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
        workoutId = workoutCubit.state.selectedWorkout?.id ?? 0;
      }

      // Create all sets
      for (final setData in _workoutSets) {
        final exerciseInputs = setData.exercises.map((e) {
          return WorkoutSetExerciseInput(
            exerciseId: e.exerciseId,
            minReps: e.minReps,
            maxReps: e.maxReps,
          );
        }).toList();

        await setCubit.createWorkoutSet(
          workoutId: workoutId,
          minSets: setData.minSets,
          recommendedRestSecs: setData.recommendedRestSecs,
          exerciseInputs: exerciseInputs,
          maxSets: setData.maxSets,
          maxRestSecs: setData.maxRestSecs,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.workoutId != null
                ? 'Workout updated successfully'
                : 'Workout created successfully'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: widget.workoutId != null ? 'Edit Workout' : 'Create Workout',
      body: MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutCubit>(
            create: (_) => WorkoutCubit(),
          ),
          BlocProvider<WorkoutSetCubit>(
            create: (_) => WorkoutSetCubit(),
          ),
          BlocProvider<ExerciseCubit>(
            create: (_) => ExerciseCubit(),
          ),
          BlocProvider<MuscleGroupCubit>(
            create: (_) => MuscleGroupCubit(),
          ),
        ],
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Workout Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a workout name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Difficulty
              DropdownButtonFormField<Difficulty>(
                initialValue: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty *',
                  border: OutlineInputBorder(),
                ),
                items: Difficulty.values
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(_difficultyLabel(d)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              // Workout Sets Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workout Sets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addWorkoutSet,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Set'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Workout Sets List
              if (_workoutSets.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No sets added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first set to get started',
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
                ..._workoutSets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final setData = entry.value;
                  return _buildWorkoutSetCard(index, setData);
                }),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveWorkout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.workoutId != null
                          ? 'Update Workout'
                          : 'Create Workout'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutSetCard(int index, WorkoutSetData setData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
        title: Text('Set ${index + 1}'),
        subtitle: Text(
          '${setData.exercises.length} exercise${setData.exercises.length != 1 ? 's' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: index > 0 ? () => _moveSetUp(index) : null,
              tooltip: 'Move up',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: index < _workoutSets.length - 1
                  ? () => _moveSetDown(index)
                  : null,
              tooltip: 'Move down',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeWorkoutSet(index),
              tooltip: 'Remove set',
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Set Configuration
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: setData.minSets.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Min Sets *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final intValue = int.tryParse(value);
                          if (intValue != null && intValue > 0) {
                            setData.minSets = intValue;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: setData.maxSets?.toString() ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Max Sets (optional)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setData.maxSets = null;
                          } else {
                            final intValue = int.tryParse(value);
                            if (intValue != null && intValue > 0) {
                              setData.maxSets = intValue;
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: setData.recommendedRestSecs.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Rest (seconds) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final intValue = int.tryParse(value);
                          if (intValue != null && intValue >= 0) {
                            setData.recommendedRestSecs = intValue;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: setData.maxRestSecs?.toString() ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Max Rest (optional)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setData.maxRestSecs = null;
                          } else {
                            final intValue = int.tryParse(value);
                            if (intValue != null && intValue >= 0) {
                              setData.maxRestSecs = intValue;
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Exercises Section
                Text(
                  'Exercises',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                // Exercise List
                if (setData.exercises.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No exercises added. Tap "Add Exercises" to add exercises to this set.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...setData.exercises.asMap().entries.map((entry) {
                    final exerciseIndex = entry.key;
                    final exercise = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text(exercise.exerciseName),
                        subtitle: Text(
                          '${exercise.minReps}${exercise.maxReps != null ? '-${exercise.maxReps}' : '+'} reps',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _editExercise(index, exerciseIndex),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  setData.exercises.removeAt(exerciseIndex);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _addExercisesToSet(index),
                  icon: const Icon(Icons.add),
                  label: Text(setData.exercises.isEmpty
                      ? 'Add Exercises'
                      : 'Add More Exercises'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addExercisesToSet(int setIndex) async {
    final setData = _workoutSets[setIndex];
    final currentExerciseIds =
        setData.exercises.map((e) => e.exerciseId).toList();
    List<int> selectedIds = List.from(currentExerciseIds);

    final result = await showDialog<List<int>>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Select Exercises'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, selectedIds),
                  child: const Text('Done'),
                ),
              ],
            ),
            body: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<ExerciseCubit>()),
                BlocProvider.value(value: context.read<MuscleGroupCubit>()),
              ],
              child: ExerciseSelectionWidget(
                initialSelections: currentExerciseIds,
                allowMultiSelect: true,
                onSelectionChanged: (ids) {
                  selectedIds = ids;
                },
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Get exercise names using service directly
      final exerciseService = ExerciseService();
      final exercises = await exerciseService.getExercisesByIdsLoader(result);

      setState(() {
        // Clear existing and add all selected
        setData.exercises.clear();
        for (final exerciseId in result) {
          final exercise = exercises[exerciseId];
          if (exercise != null) {
            // Check if this exercise was already in the set to preserve reps
            final existing = currentExerciseIds.contains(exerciseId)
                ? setData.exercises.firstWhere(
                    (e) => e.exerciseId == exerciseId,
                    orElse: () => ExerciseData(
                      exerciseId: exerciseId,
                      exerciseName: exercise.name,
                      minReps: 10,
                      maxReps: null,
                    ),
                  )
                : null;

            setData.exercises.add(ExerciseData(
              exerciseId: exerciseId,
              exerciseName: exercise.name,
              minReps: existing?.minReps ?? 10,
              maxReps: existing?.maxReps,
            ));
          }
        }
      });
    }
  }

  Future<void> _editExercise(int setIndex, int exerciseIndex) async {
    final exercise = _workoutSets[setIndex].exercises[exerciseIndex];

    final minRepsController = TextEditingController(
      text: exercise.minReps.toString(),
    );
    final maxRepsController = TextEditingController(
      text: exercise.maxReps?.toString() ?? '',
    );

    final result = await showDialog<ExerciseData>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${exercise.exerciseName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: minRepsController,
              decoration: const InputDecoration(
                labelText: 'Min Reps *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: maxRepsController,
              decoration: const InputDecoration(
                labelText: 'Max Reps (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final minReps = int.tryParse(minRepsController.text);
              if (minReps != null && minReps > 0) {
                final maxReps = maxRepsController.text.isEmpty
                    ? null
                    : int.tryParse(maxRepsController.text);
                Navigator.pop(
                  context,
                  ExerciseData(
                    exerciseId: exercise.exerciseId,
                    exerciseName: exercise.exerciseName,
                    minReps: minReps,
                    maxReps: maxReps,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _workoutSets[setIndex].exercises[exerciseIndex] = result;
      });
    }
  }
}

// Helper classes for managing workout set data
class WorkoutSetData {
  int minSets;
  int? maxSets;
  int recommendedRestSecs;
  int? maxRestSecs;
  List<ExerciseData> exercises;

  WorkoutSetData({
    this.minSets = 3,
    this.maxSets,
    this.recommendedRestSecs = 60,
    this.maxRestSecs,
    List<ExerciseData>? exercises,
  }) : exercises = exercises ?? [];
}

class ExerciseData {
  final int exerciseId;
  final String exerciseName;
  int minReps;
  int? maxReps;

  ExerciseData({
    required this.exerciseId,
    required this.exerciseName,
    this.minReps = 10,
    this.maxReps,
  });
}
