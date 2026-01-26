import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/exercise_cubit.dart';
import '../cubits/states/exercise_state.dart';
import '../models/enums.dart';
import '../services/dtos/exercise_dto.dart';
import '../models/utilities.dart';
import '../widgets/exercise/exercise_card_widget.dart';
import '../widgets/layout/responsive_scaffold.dart';

class ExerciseLibraryView extends StatefulWidget {
  static const routeName = "/exercises";
  static const name = "exercises";

  const ExerciseLibraryView({super.key});

  @override
  State<ExerciseLibraryView> createState() => _ExerciseLibraryViewState();
}

class _ExerciseLibraryViewState extends State<ExerciseLibraryView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;
  MuscleGroup? _selectedMuscleGroup;
  Difficulty? _selectedDifficulty;
  int? _selectedEquipmentId;
  String? _searchQuery;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    final exerciseCubit = context.read<ExerciseCubit>();
    exerciseCubit.getExercises(limit: 20, offset: 0);
    exerciseCubit.getEquipments(limit: 1000, offset: 0);
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

  String _getMuscleGroupName(MuscleGroup muscleGroup) {
    return EnumDisplayNames.getMuscleGroupDisplayName(muscleGroup);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: "Exercise Library",
      showBackButton: true,
      body: Stack(
        children: [
          BlocConsumer<ExerciseCubit, ExerciseState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, exerciseState) {
              return Column(
                children: [
                  // Search and Filters
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                          ),
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 12),
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
                                ),
                                items: [
                                  const DropdownMenuItem<MuscleGroup?>(
                                    value: null,
                                    child: Text('All Muscle Groups'),
                                  ),
                                  ...MuscleGroup.values.map(
                                    (mg) => DropdownMenuItem<MuscleGroup?>(
                                      value: mg,
                                      child: Text(EnumDisplayNames
                                          .getMuscleGroupDisplayName(mg)),
                                    ),
                                  ),
                                ],
                                onChanged: _onMuscleGroupFilterChanged,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // View Toggle
                            IconButton(
                              icon: Icon(
                                _isGridView ? Icons.list : Icons.grid_view,
                              ),
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
                        const SizedBox(height: 12),
                        // Filters Row 2
                        Row(
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
                            const SizedBox(width: 12),
                            // Equipment Filter
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                initialValue: _selectedEquipmentId,
                                decoration: InputDecoration(
                                  labelText: 'Equipment',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('All Equipment'),
                                  ),
                                  ...exerciseState.equipments.map(
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
                        ),
                      ],
                    ),
                  ),
                  // Exercises List/Grid
                  Expanded(
                    child: exerciseState.isLoading &&
                            exerciseState.exercises.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : exerciseState.exercises.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No exercises found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _isGridView
                                ? _buildGridView(exerciseState.exercises)
                                : _buildListView(exerciseState.exercises),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                context.push('/exercises/create');
              },
              tooltip: 'Add Exercise',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<ExerciseDto> exercises) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: exercises.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= exercises.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final exercise = exercises[index];
        return ExerciseCardWidget(
          exercise: exercise,
          muscleGroupName: _getMuscleGroupName(exercise.muscleGroup),
          onTap: () {
            context.push('/exercises/${exercise.id}');
          },
        );
      },
    );
  }

  Widget _buildListView(
    List<ExerciseDto> exercises,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: exercises.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= exercises.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final exercise = exercises[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ExerciseCardWidget(
            exercise: exercise,
            muscleGroupName: _getMuscleGroupName(exercise.muscleGroup),
            compact: true,
            onTap: () {
              context.push('/exercises/${exercise.id}');
            },
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
