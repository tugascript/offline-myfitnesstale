import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/equipment_cubit.dart';
import '../cubits/exercise_cubit.dart';
import '../cubits/muscle_cubit.dart';
import '../cubits/muscle_group_cubit.dart';
import '../cubits/states/exercise_state.dart';
import '../cubits/states/muscle_group_state.dart';
import '../models/enums.dart';
import '../widgets/exercise/equipment_selection_widget.dart';
import '../widgets/exercise/muscle_selection_widget.dart';
import '../widgets/layout/responsive_scaffold.dart';

class ExerciseFormView extends StatefulWidget {
  static const routeName = "/exercises/create";
  static const routeNameEdit = "/exercises/:id/edit";
  static const name = "exercise-form";

  final int? exerciseId;

  const ExerciseFormView({
    super.key,
    this.exerciseId,
  });

  @override
  State<ExerciseFormView> createState() => _ExerciseFormViewState();
}

class _ExerciseFormViewState extends State<ExerciseFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pictureUriController = TextEditingController();
  final _videoUriController = TextEditingController();

  int? _selectedMuscleGroupId;
  VideoPlatform? _selectedVideoPlatform;
  bool _isFavorite = false;
  List<(int, ExerciseMuscleCategory)> _selectedMuscles = [];
  List<int> _selectedEquipmentIds = [];
  Difficulty? _selectedDifficulty;
  bool _isLoading = false;

  bool get isEditMode => widget.exerciseId != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (isEditMode) {
      _loadExercise();
    }
  }

  void _loadInitialData() {
    context.read<MuscleGroupCubit>().getMuscleGroups();
    context.read<MuscleCubit>().getMuscles(limit: 1000);
    context.read<EquipmentCubit>().getEquipments(limit: 1000);
  }

  void _loadExercise() {
    context.read<ExerciseCubit>().getExercise(widget.exerciseId!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pictureUriController.dispose();
    _videoUriController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMuscleGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a muscle group'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isEditMode) {
        // Update existing exercise
        await context.read<ExerciseCubit>().updateExercise(
              id: widget.exerciseId!,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              muscleGroupId: _selectedMuscleGroupId,
              pictureUri: _pictureUriController.text.trim().isEmpty
                  ? null
                  : _pictureUriController.text.trim(),
              videoUri: _videoUriController.text.trim().isEmpty
                  ? null
                  : _videoUriController.text.trim(),
              isFavorite: _isFavorite,
              difficulty: _selectedDifficulty?.value,
            );

        // TODO: Update exercise muscles and equipment separately
        // For now, we'll need to handle this in the service layer
        // This is a limitation - we'd need to add methods to update exercise muscles and equipment
      } else {
        // Create new exercise
        (VideoPlatform, String)? videoData;
        if (_videoUriController.text.trim().isNotEmpty &&
            _selectedVideoPlatform != null) {
          videoData = (
            _selectedVideoPlatform!,
            _videoUriController.text.trim(),
          );
        }

        await context.read<ExerciseCubit>().createExercise(
              name: _nameController.text.trim(),
              muscleGroupId: _selectedMuscleGroupId!,
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              pictureUri: _pictureUriController.text.trim().isEmpty
                  ? null
                  : _pictureUriController.text.trim(),
              videoData: videoData,
              muscleIds: _selectedMuscles.isEmpty ? null : _selectedMuscles,
              equipmentIds:
                  _selectedEquipmentIds.isEmpty ? null : _selectedEquipmentIds,
              difficulty: _selectedDifficulty?.value,
              isFavorite: _isFavorite,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Exercise updated successfully!'
                  : 'Exercise created successfully!',
            ),
            backgroundColor: Colors.green,
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: isEditMode ? "Edit Exercise" : "Create Exercise",
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

          // Load exercise data when editing
          if (isEditMode &&
              state.selectedExercise != null &&
              _nameController.text.isEmpty) {
            final exercise = state.selectedExercise!;
            _nameController.text = exercise.name;
            _descriptionController.text = exercise.description ?? '';
            _pictureUriController.text = exercise.pictureUri ?? '';
            _videoUriController.text = exercise.videoUri ?? '';
            _selectedMuscleGroupId = exercise.muscleGroupId;
            _selectedVideoPlatform = exercise.videoPlatform;
            _isFavorite = exercise.isFavorite;
            _selectedDifficulty = exercise.difficulty != null
                ? Difficulty.fromValue(exercise.difficulty!)
                : null;

            // Load selected muscles (without categories for now)
            // TODO: Load with categories from exercise_muscles table
            _selectedMuscles = (state.selectedExerciseMuscles ?? [])
                .map((m) => (m.id!, ExerciseMuscleCategory.primary))
                .toList();

            // Load selected equipment
            _selectedEquipmentIds = (state.selectedExerciseEquipments ?? [])
                .map((e) => e.id)
                .whereType<int>()
                .toList();
          }
        },
        builder: (context, exerciseState) {
          return BlocBuilder<MuscleGroupCubit, MuscleGroupState>(
            builder: (context, muscleGroupState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Exercise Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an exercise name';
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
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                      const SizedBox(height: 16),
                      // Muscle Group
                      DropdownButtonFormField<int?>(
                        initialValue: _selectedMuscleGroupId,
                        decoration: const InputDecoration(
                          labelText: 'Muscle Group *',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Select a muscle group'),
                          ),
                          ...muscleGroupState.muscleGroups.map(
                            (mg) => DropdownMenuItem<int?>(
                              value: mg.id,
                              child: Text(mg.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMuscleGroupId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a muscle group';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Muscle Selection
                      MuscleSelectionWidget(
                        selectedMuscles: _selectedMuscles,
                        onSelectionChanged: (muscles) {
                          setState(() {
                            _selectedMuscles = muscles;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // Difficulty
                      DropdownButtonFormField<Difficulty?>(
                        initialValue: _selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<Difficulty?>(
                            value: null,
                            child: Text('Not specified'),
                          ),
                          ...Difficulty.values.map(
                            (difficulty) => DropdownMenuItem<Difficulty?>(
                              value: difficulty,
                              child: Text(_difficultyLabel(difficulty)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // Equipment Selection
                      EquipmentSelectionWidget(
                        selectedEquipmentIds: _selectedEquipmentIds,
                        onSelectionChanged: (equipmentIds) {
                          setState(() {
                            _selectedEquipmentIds = equipmentIds;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // Picture URI
                      TextFormField(
                        controller: _pictureUriController,
                        decoration: const InputDecoration(
                          labelText: 'Picture URI (placeholder)',
                          border: OutlineInputBorder(),
                          helperText: 'File picker coming soon',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Video Platform
                      DropdownButtonFormField<VideoPlatform?>(
                        initialValue: _selectedVideoPlatform,
                        decoration: const InputDecoration(
                          labelText: 'Video Platform',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<VideoPlatform?>(
                            value: null,
                            child: Text('None'),
                          ),
                          ...VideoPlatform.values.map(
                            (platform) => DropdownMenuItem<VideoPlatform?>(
                              value: platform,
                              child: Text(platform.value),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedVideoPlatform = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Video URI
                      TextFormField(
                        controller: _videoUriController,
                        decoration: const InputDecoration(
                          labelText: 'Video URI',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Favorite Toggle
                      SwitchListTile(
                        title: const Text('Favorite'),
                        subtitle: const Text('Add to favorites'),
                        value: _isFavorite,
                        onChanged: (value) {
                          setState(() {
                            _isFavorite = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveExercise,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEditMode
                                      ? 'Update Exercise'
                                      : 'Create Exercise',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
}
