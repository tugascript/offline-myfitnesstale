import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/workout_plan_cubit.dart';
import '../cubits/states/workout_plan_state.dart';
import '../models/enums.dart';
import '../services/dtos/workout_plan_dto.dart';
import '../widgets/layout/responsive_scaffold.dart';

class WorkoutPlanListView extends StatefulWidget {
  static const routeName = '/workout-plans';

  const WorkoutPlanListView({super.key});

  @override
  State<WorkoutPlanListView> createState() => _WorkoutPlanListViewState();
}

class _WorkoutPlanListViewState extends State<WorkoutPlanListView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;
  Difficulty? _selectedDifficulty;
  String? _searchQuery;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    context.read<WorkoutPlanCubit>().getWorkoutPlans(
          name: null,
          difficulty: _selectedDifficulty,
          limit: 20,
          offset: 0,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;

    final state = context.read<WorkoutPlanCubit>().state;
    if (state.isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    context.read<WorkoutPlanCubit>().getWorkoutPlans(
          name: _searchQuery,
          difficulty: _selectedDifficulty,
          limit: 20,
          offset: state.workoutPlans.length,
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
    context.read<WorkoutPlanCubit>().getWorkoutPlans(
          name: _searchQuery,
          difficulty: _selectedDifficulty,
          limit: 20,
          offset: 0,
        );
  }

  void _onDifficultyFilterChanged(Difficulty? difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    context.read<WorkoutPlanCubit>().getWorkoutPlans(
          name: _searchQuery,
          difficulty: _selectedDifficulty,
          limit: 20,
          offset: 0,
        );
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Workout Plans',
      body: BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
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
        builder: (context, state) {
          final plans = state.workoutPlans;

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
                        hintText: 'Search workout plans...',
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 12),
                    // Filters Row
                    Row(
                      children: [
                        // Difficulty Filter
                        Expanded(
                          child: DropdownButtonFormField<Difficulty?>(
                            initialValue: _selectedDifficulty,
                            decoration: InputDecoration(
                              labelText: 'Difficulty',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<Difficulty?>(
                                value: null,
                                child: Text('All Difficulties'),
                              ),
                              ...Difficulty.values.map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(_difficultyLabel(d)),
                                  )),
                            ],
                            onChanged: _onDifficultyFilterChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // View Toggle
                        IconButton(
                          icon: Icon(
                            _isGridView ? Icons.list : Icons.grid_view,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                          tooltip: _isGridView ? 'List View' : 'Grid View',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Plans List/Grid
              Expanded(
                child: state.isLoading && plans.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : plans.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No workout plans found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery != null ||
                                          _selectedDifficulty != null
                                      ? 'Try adjusting your filters'
                                      : 'No workout plans available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _isGridView
                            ? _buildGridView(plans, state)
                            : _buildListView(plans, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<WorkoutPlanDto> plans, WorkoutPlanState state) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: plans.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= plans.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildPlanCard(plans[index]);
      },
    );
  }

  Widget _buildListView(List<WorkoutPlanDto> plans, WorkoutPlanState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: plans.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= plans.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildPlanCard(plans[index], isList: true),
        );
      },
    );
  }

  Widget _buildPlanCard(WorkoutPlanDto plan, {bool isList = false}) {
    final difficulty = Difficulty.fromValue(plan.difficulty);
    final difficultyLabel = _difficultyLabel(difficulty);
    final difficultyColor = _difficultyColor(difficulty);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/workout-plans/${plan.id}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: isList ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Difficulty Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: difficultyColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  difficultyLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: difficultyColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Duration
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.totalWeeks} ${plan.totalWeeks == 1 ? 'week' : 'weeks'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (plan.description != null &&
                  plan.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  plan.description!,
                  style: TextStyle(
                    fontSize: isList ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: isList ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/workout-plans/${plan.id}');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

