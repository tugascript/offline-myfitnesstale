import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/equipment_cubit.dart';
import '../cubits/exercise_cubit.dart';
import '../cubits/muscle_group_cubit.dart';
import '../cubits/states/equipment_state.dart';
import '../cubits/states/exercise_state.dart';
import '../cubits/states/muscle_group_state.dart';
import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../models/muscle_group_model.dart';
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
  int? _selectedMuscleGroupId;
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
          muscleGroupId: _selectedMuscleGroupId,
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
          muscleGroupId: _selectedMuscleGroupId,
          difficulty: _selectedDifficulty?.value,
          limit: 20,
          offset: 0,
        );
  }

  void _onMuscleGroupFilterChanged(int? muscleGroupId) {
    setState(() {
      _selectedMuscleGroupId = muscleGroupId;
    });
    context.read<ExerciseCubit>().getExercises(
          name: _searchQuery,
          muscleGroupId: _selectedMuscleGroupId,
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
          muscleGroupId: _selectedMuscleGroupId,
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
          muscleGroupId: _selectedMuscleGroupId,
          difficulty: _selectedDifficulty?.value,
          limit: 20,
          offset: 0,
        );
  }

  String? _getMuscleGroupName(
    int muscleGroupId,
    List<MuscleGroup> muscleGroups,
  ) {
    return muscleGroups
        .firstWhere(
          (mg) => mg.id == muscleGroupId,
          orElse: () => MuscleGroup(
            id: muscleGroupId,
            name: 'Unknown',
            createdAt: 0,
            updatedAt: 0,
          ),
        )
        .name;
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
              return BlocBuilder<MuscleGroupCubit, MuscleGroupState>(
                builder: (context, muscleGroupState) {
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
                                  child: DropdownButtonFormField<int?>(
                                    initialValue: _selectedMuscleGroupId,
                                    decoration: InputDecoration(
                                      labelText: 'Muscle Group',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('All Muscle Groups'),
                                      ),
                                      ...muscleGroupState.muscleGroups.map(
                                        (mg) => DropdownMenuItem<int?>(
                                          value: mg.id,
                                          child: Text(mg.name),
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
                            BlocBuilder<EquipmentCubit, EquipmentState>(
                              builder: (context, equipmentState) {
                                return Row(
                                  children: [
                                    // Difficulty Filter
                                    Expanded(
                                      child:
                                          DropdownButtonFormField<Difficulty?>(
                                        initialValue: _selectedDifficulty,
                                        decoration: InputDecoration(
                                          labelText: 'Difficulty',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        items: [
                                          const DropdownMenuItem<Difficulty?>(
                                            value: null,
                                            child: Text('All Difficulties'),
                                          ),
                                          ...Difficulty.values.map(
                                            (d) =>
                                                DropdownMenuItem<Difficulty?>(
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
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
                        child: exerciseState.isLoading &&
                                exerciseState.exercises.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : exerciseState.exercises.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    ? _buildGridView(
                                        exerciseState.exercises,
                                        muscleGroupState.muscleGroups,
                                      )
                                    : _buildListView(
                                        exerciseState.exercises,
                                        muscleGroupState.muscleGroups,
                                      ),
                      ),
                    ],
                  );
                },
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

  Widget _buildGridView(
    List<Exercise> exercises,
    List<MuscleGroup> muscleGroups,
  ) {
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
          muscleGroupName: _getMuscleGroupName(
            exercise.muscleGroupId,
            muscleGroups,
          ),
          onTap: () {
            context.push('/exercises/${exercise.id}');
          },
        );
      },
    );
  }

  Widget _buildListView(
    List<Exercise> exercises,
    List<MuscleGroup> muscleGroups,
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
            muscleGroupName: _getMuscleGroupName(
              exercise.muscleGroupId,
              muscleGroups,
            ),
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
