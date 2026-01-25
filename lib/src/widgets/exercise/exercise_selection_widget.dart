import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/equipment_cubit.dart';
import '../../cubits/exercise_cubit.dart';
import '../../cubits/muscle_group_cubit.dart';
import '../../cubits/states/equipment_state.dart';
import '../../cubits/states/exercise_state.dart';
import '../../cubits/states/muscle_group_state.dart';
import '../../models/enums.dart';
import '../../models/utilities.dart';
import '../../services/dtos/exercise_dto.dart';
import 'exercise_card_widget.dart';

class ExerciseSelectionWidget extends StatefulWidget {
  final List<int> initialSelections;
  final Function(List<int>) onSelectionChanged;
  final bool allowMultiSelect;
  final String? title;

  const ExerciseSelectionWidget({
    super.key,
    this.initialSelections = const [],
    required this.onSelectionChanged,
    this.allowMultiSelect = true,
    this.title,
  });

  @override
  State<ExerciseSelectionWidget> createState() =>
      _ExerciseSelectionWidgetState();
}

class _ExerciseSelectionWidgetState extends State<ExerciseSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Set<int> _selectedExerciseIds;
  bool _isGridView = true;
  MuscleGroup? _selectedMuscleGroup;
  Difficulty? _selectedDifficulty;
  int? _selectedEquipmentId;
  String? _searchQuery;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _selectedExerciseIds = Set.from(widget.initialSelections);
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    context.read<ExerciseCubit>().getExercises(limit: 20, offset: 0);
    context.read<MuscleGroupCubit>().getMuscleGroups();
    context.read<EquipmentCubit>().getEquipments(limit: 1000);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;

    final state = context.read<ExerciseCubit>().state;
    if (state.isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    context.read<ExerciseCubit>().getExercises(
          name: _searchQuery,
          muscleGroup: _selectedMuscleGroup,
          difficulty: _selectedDifficulty?.value,
          limit: 20,
          offset: state.exercises.length,
        );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
    context.read<ExerciseCubit>().getExercises(
          name: _searchQuery,
          muscleGroup: _selectedMuscleGroup,
          difficulty: _selectedDifficulty?.value,
          limit: 20,
          offset: 0,
        );
  }

  void _onMuscleGroupFilterChanged(MuscleGroup? muscleGroup) {
    setState(() {
      _selectedMuscleGroup = muscleGroup;
    });
    context.read<ExerciseCubit>().getExercises(
          name: _searchQuery,
          muscleGroup: _selectedMuscleGroup,
          difficulty: _selectedDifficulty?.value,
          limit: 20,
          offset: 0,
        );
  }

  void _onDifficultyFilterChanged(Difficulty? difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    context.read<ExerciseCubit>().getExercises(
          name: _searchQuery,
          muscleGroup: _selectedMuscleGroup,
          difficulty: _selectedDifficulty?.value,
          limit: 20,
          offset: 0,
        );
  }

  void _onEquipmentFilterChanged(int? equipmentId) {
    setState(() {
      _selectedEquipmentId = equipmentId;
    });
    // Note: Equipment filtering would require a more complex query
    // For now, we'll just reset the filter
    // TODO: Implement equipment filtering in ExerciseService
    context.read<ExerciseCubit>().getExercises(
          name: _searchQuery,
          muscleGroup: _selectedMuscleGroup,
          difficulty: _selectedDifficulty?.value,
          limit: 20,
          offset: 0,
        );
  }

  void _toggleSelection(int exerciseId) {
    setState(() {
      if (_selectedExerciseIds.contains(exerciseId)) {
        _selectedExerciseIds.remove(exerciseId);
      } else {
        if (widget.allowMultiSelect) {
          _selectedExerciseIds.add(exerciseId);
        } else {
          _selectedExerciseIds.clear();
          _selectedExerciseIds.add(exerciseId);
        }
      }
      widget.onSelectionChanged(_selectedExerciseIds.toList());
    });
  }

  String _formatMuscleGroupName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.full:
        return 'Full Body';
      case MuscleGroup.push:
        return 'Push';
      case MuscleGroup.pull:
        return 'Pull';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.core:
        return 'Core';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Selected Count
        if (widget.allowMultiSelect && _selectedExerciseIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${_selectedExerciseIds.length} exercise(s) selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        // Search and Filters
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 8),
              // Filters Row 1
              Row(
                children: [
                  // Muscle Group Filter
                  Expanded(
                    child: DropdownButtonFormField<MuscleGroup?>(
                      initialValue: _selectedMuscleGroup,
                      decoration: InputDecoration(
                        labelText: 'Muscle Group',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      items: [
                        const DropdownMenuItem<MuscleGroup?>(
                          value: null,
                          child: Text('All Muscle Groups'),
                        ),
                        ...context
                            .read<MuscleGroupCubit>()
                            .state
                            .muscleGroups
                            .map(
                              (group) => DropdownMenuItem<MuscleGroup?>(
                                value: group,
                                child: Text(_formatMuscleGroupName(group)),
                              ),
                            ),
                      ],
                      onChanged: _onMuscleGroupFilterChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // View Toggle
                  IconButton(
                    icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    tooltip: _isGridView
                        ? 'Switch to List View'
                        : 'Switch to Grid View',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Filters Row 2
              BlocBuilder<EquipmentCubit, EquipmentState>(
                builder: (context, equipmentState) {
                  return Row(
                    children: [
                      // Difficulty Filter
                      Expanded(
                        child: DropdownButtonFormField<Difficulty?>(
                          initialValue: _selectedDifficulty,
                          decoration: InputDecoration(
                            labelText: 'Difficulty',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          items: [
                            const DropdownMenuItem<Difficulty?>(
                              value: null,
                              child: Text('All Difficulties'),
                            ),
                            ...Difficulty.values.map(
                              (d) => DropdownMenuItem<Difficulty?>(
                                value: d,
                                child: Text(_difficultyLabel(d)),
                              ),
                            ),
                          ],
                          onChanged: _onDifficultyFilterChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Equipment Filter
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: _selectedEquipmentId,
                          decoration: InputDecoration(
                            labelText: 'Equipment',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Equipment'),
                            ),
                            ...equipmentState.equipments.map(
                              (e) => DropdownMenuItem<int?>(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            ),
                          ],
                          onChanged: _onEquipmentFilterChanged,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        // Exercises List/Grid
        Expanded(
          child: BlocBuilder<ExerciseCubit, ExerciseState>(
            builder: (context, exerciseState) {
              return BlocBuilder<MuscleGroupCubit, MuscleGroupState>(
                builder: (context, muscleGroupState) {
                  if (exerciseState.isLoading &&
                      exerciseState.exercises.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (exerciseState.exercises.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _isGridView
                      ? _buildGridView(
                          exerciseState.exercises,
                          muscleGroupState.muscleGroups,
                        )
                      : _buildListView(
                          exerciseState.exercises,
                          muscleGroupState.muscleGroups,
                        );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(
    List<ExerciseDto> exercises,
    List<MuscleGroup> muscleGroups,
  ) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: exercises.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= exercises.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final exercise = exercises[index];
        final isSelected = _selectedExerciseIds.contains(exercise.id);
        return GestureDetector(
          onTap: () => _toggleSelection(exercise.id),
          child: Stack(
            children: [
              ExerciseCardWidget(
                exercise: exercise,
                muscleGroupName: EnumDisplayNames.getMuscleGroupDisplayName(
                    exercise.muscleGroup),
                compact: true,
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(
    List<ExerciseDto> exercises,
    List<MuscleGroup> muscleGroups,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: exercises.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= exercises.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final exercise = exercises[index];
        final isSelected = _selectedExerciseIds.contains(exercise.id);
        return GestureDetector(
          onTap: () => _toggleSelection(exercise.id),
          child: Stack(
            children: [
              ExerciseCardWidget(
                exercise: exercise,
                muscleGroupName: EnumDisplayNames.getMuscleGroupDisplayName(
                    exercise.muscleGroup),
                compact: true,
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
