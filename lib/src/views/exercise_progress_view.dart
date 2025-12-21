import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/exercise_model.dart';
import '../models/workout_set_exercise_record_model.dart';
import '../services/exercise_service.dart';
import '../services/workout_set_exercise_record_service.dart';
import '../widgets/layout/responsive_scaffold.dart';

class ExerciseProgressView extends StatefulWidget {
  static const routeName = '/exercises/progress';

  const ExerciseProgressView({super.key});

  @override
  State<ExerciseProgressView> createState() => _ExerciseProgressViewState();
}

class _ExerciseProgressViewState extends State<ExerciseProgressView> {
  final ExerciseService _exerciseService = ExerciseService();
  final WorkoutSetExerciseRecordService _exerciseRecordService =
      WorkoutSetExerciseRecordService();

  List<Exercise> _exercises = [];
  Map<int, List<WorkoutSetExerciseRecord>> _exerciseRecords = {};
  Map<int, ExerciseProgressData> _progressData = {};
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exercises = await _exerciseService.getExercises();
      final progressDataMap = <int, ExerciseProgressData>{};
      final exerciseRecordsMap = <int, List<WorkoutSetExerciseRecord>>{};

      for (final exercise in exercises) {
        if (exercise.id == null) continue;

        final records =
            await _exerciseRecordService.getWorkoutSetExerciseRecords(
          exerciseId: exercise.id,
        );

        if (records.isNotEmpty) {
          exerciseRecordsMap[exercise.id!] = records;
          progressDataMap[exercise.id!] = _calculateProgressData(records);
        }
      }

      setState(() {
        _exercises = exercises;
        _exerciseRecords = exerciseRecordsMap;
        _progressData = progressDataMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  ExerciseProgressData _calculateProgressData(
    List<WorkoutSetExerciseRecord> records,
  ) {
    if (records.isEmpty) {
      return ExerciseProgressData.empty();
    }

    final weights = records.map((r) => r.weightGrams / 1000.0).toList();
    final reps = records.map((r) => r.reps).toList();
    final volumes =
        records.map((r) => (r.weightGrams / 1000.0) * r.reps).toList();

    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final maxReps = reps.reduce((a, b) => a > b ? a : b);
    final maxVolume = volumes.reduce((a, b) => a > b ? a : b);
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
    final avgReps = reps.reduce((a, b) => a + b) / reps.length;
    final totalVolume = volumes.reduce((a, b) => a + b);

    // Find personal bests
    final pbWeight =
        records.reduce((a, b) => a.weightGrams > b.weightGrams ? a : b);
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

  List<Exercise> get _filteredExercises {
    if (_searchQuery.isEmpty) {
      return _exercises.where((e) => _progressData.containsKey(e.id)).toList();
    }

    return _exercises
        .where((e) =>
            _progressData.containsKey(e.id) &&
            e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Exercise Progress',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading exercises',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadExercises,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _filteredExercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center,
                              size: 64, color: Colors.grey[400]),
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
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
                            onRefresh: _loadExercises,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              itemCount: _filteredExercises.length,
                              itemBuilder: (context, index) {
                                final exercise = _filteredExercises[index];
                                final progress = _progressData[exercise.id];

                                if (progress == null) {
                                  return const SizedBox.shrink();
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {
                                      context.push(
                                        '/exercises/${exercise.id}/history',
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    '/exercises/${exercise.id}/history',
                                                  );
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
                                              color:
                                                  Colors.amber.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.amber
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.emoji_events,
                                                    color: Colors.amber[700],
                                                    size: 20),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Personal Best',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      Text(
                                                        '${(progress.pbWeight.weightGrams / 1000.0).toStringAsFixed(1)} kg × ${progress.pbReps.reps} reps',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.amber[900],
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
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
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
  final WorkoutSetExerciseRecord pbWeight;
  final WorkoutSetExerciseRecord pbReps;
  final List<WorkoutSetExerciseRecord> recentRecords;

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
    final emptyRecord = WorkoutSetExerciseRecord(
      workoutSetExerciseId: 0,
      workoutSetProgressId: 0,
      exerciseId: 0,
      reps: 0,
      weightGrams: 0,
      createdAt: 0,
      updatedAt: 0,
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
