import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/exercise_record_cubit.dart';
import '../cubits/states/exercise_record_state.dart';
import '../services/dtos/exercise_dto.dart';
import '../services/dtos/exercise_record_dto.dart';
import '../widgets/layout/responsive_scaffold.dart';

class ExerciseProgressView extends StatefulWidget {
  static const routeName = '/exercises/progress';

  const ExerciseProgressView({super.key});

  @override
  State<ExerciseProgressView> createState() => _ExerciseProgressViewState();
}

class _ExerciseProgressViewState extends State<ExerciseProgressView> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load all records to calculate stats.
    // Assuming 1000 is enough for now, or implement infinite scroll later if needed for this view specifically.
    // But since we need to aggregate stats for 'progress', fetching all might be necessary or a dedicated 'stats' endpoint.
    // For now, using getExerciseRecords with a large limit as per plan.
    context.read<ExerciseRecordCubit>().getExerciseRecords(limit: 1000);
  }

  Map<int, List<ExerciseRecordDto>> _groupRecordsByExercise(
    List<ExerciseRecordDto> records,
  ) {
    final Map<int, List<ExerciseRecordDto>> grouped = {};
    for (final record in records) {
      if (!grouped.containsKey(record.exerciseId)) {
        grouped[record.exerciseId] = [];
      }
      grouped[record.exerciseId]!.add(record);
    }
    return grouped;
  }

  ExerciseProgressData _calculateProgressData(List<ExerciseRecordDto> records) {
    if (records.isEmpty) {
      return ExerciseProgressData.empty();
    }

    // records are likely ordered by date DESC from the API/Cubit
    final weights = records.map((r) => r.weight / 1000.0).toList();
    final reps = records.map((r) => r.reps).toList();
    final volumes = weights.asMap().entries.map((entry) {
      return entry.value * reps[entry.key];
    }).toList();

    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final maxReps = reps.reduce((a, b) => a > b ? a : b);
    final maxVolume = volumes.reduce((a, b) => a > b ? a : b);

    final sumWeight = weights.fold(0.0, (a, b) => a + b);
    final avgWeight = sumWeight / weights.length;

    final sumReps = reps.fold(0, (a, b) => a + b);
    final avgReps = sumReps / reps.length;

    final totalVolume = volumes.fold(0.0, (a, b) => a + b);

    // Find personal bests
    final pbWeight = records.reduce((a, b) => a.weight > b.weight ? a : b);
    final pbReps = records.reduce((a, b) => a.reps > b.reps ? a : b);

    return ExerciseProgressData(
      totalSessions: records.length,
      maxWeight: maxWeight,
      maxReps: maxReps,
      maxVolume: maxVolume,
      avgWeight: avgWeight,
      avgReps: avgReps,
      totalVolume: totalVolume,
      pbWeight: pbWeight,
      pbReps: pbReps,
      recentRecords: records.take(10).toList(),
    );
  }

  List<ExerciseDto> _getFilteredExercises(
    Map<int, List<ExerciseRecordDto>> groupedRecords,
  ) {
    // Extract unique exercises from records
    final exercises = <int, ExerciseDto>{};
    for (final records in groupedRecords.values) {
      if (records.isNotEmpty && records.first.exercise != null) {
        exercises[records.first.exerciseId] = records.first.exercise!;
      }
    }

    final exerciseList = exercises.values.toList();

    if (_searchQuery.isEmpty) {
      return exerciseList;
    }

    return exerciseList
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Exercise Progress',
      body: BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
        builder: (context, state) {
          if (state.isLoading && state.exerciseRecords.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.exerciseRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading exercises',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error!.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ExerciseRecordCubit>()
                          .getExerciseRecords(limit: 1000);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final groupedRecords = _groupRecordsByExercise(state.exerciseRecords);
          final filteredExercises = _getFilteredExercises(groupedRecords);

          if (filteredExercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No Exercise Progress'
                        : 'No exercises found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Complete workouts with exercises to see progress here'
                        : 'Try a different search term',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              // Exercise List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context
                        .read<ExerciseRecordCubit>()
                        .getExerciseRecords(limit: 1000);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      final records = groupedRecords[exercise.id] ?? [];
                      final progress = _calculateProgressData(records);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            context.push('/exercises/${exercise.id}/history');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        exercise.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        context.push(
                                            '/exercises/${exercise.id}/history');
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress Stats
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildProgressStat(
                                        'Sessions',
                                        '${progress.totalSessions}',
                                        Icons.event,
                                        Colors.blue,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildProgressStat(
                                        'Max Weight',
                                        '${progress.maxWeight.toStringAsFixed(1)} kg',
                                        Icons.fitness_center,
                                        Colors.orange,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildProgressStat(
                                        'Max Reps',
                                        '${progress.maxReps}',
                                        Icons.repeat,
                                        Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Personal Bests
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          Colors.amber.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.emoji_events,
                                          color: Colors.amber[700], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Personal Best',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              '${(progress.pbWeight.weight / 1000.0).toStringAsFixed(1)} kg × ${progress.pbReps.reps} reps',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber[900],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class ExerciseProgressData {
  final int totalSessions;
  final double maxWeight;
  final int maxReps;
  final double maxVolume;
  final double avgWeight;
  final double avgReps;
  final double totalVolume;
  final ExerciseRecordDto pbWeight;
  final ExerciseRecordDto pbReps;
  final List<ExerciseRecordDto> recentRecords;

  ExerciseProgressData({
    required this.totalSessions,
    required this.maxWeight,
    required this.maxReps,
    required this.maxVolume,
    required this.avgWeight,
    required this.avgReps,
    required this.totalVolume,
    required this.pbWeight,
    required this.pbReps,
    required this.recentRecords,
  });

  factory ExerciseProgressData.empty() {
    // Placeholder empty record
    final emptyRecord = ExerciseRecordDto(
      id: 0,
      exerciseId: 0,
      weight: 0,
      reps: 0,
      maxStrength: 0,
      recordDate: DateTime.now(),
    );

    return ExerciseProgressData(
      totalSessions: 0,
      maxWeight: 0,
      maxReps: 0,
      maxVolume: 0,
      avgWeight: 0,
      avgReps: 0,
      totalVolume: 0,
      pbWeight: emptyRecord,
      pbReps: emptyRecord,
      recentRecords: [],
    );
  }
}
