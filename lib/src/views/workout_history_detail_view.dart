import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/workout_cubit.dart';
import '../cubits/workout_record_cubit.dart';
import '../cubits/states/workout_state.dart';
import '../cubits/states/workout_record_state.dart';
import '../models/db.dart';
import '../models/exercise_model.dart';
import '../models/repository.dart';
import '../models/workout_set_exercise_record_model.dart';
import '../models/workout_set_record_model.dart';
import '../widgets/layout/responsive_scaffold.dart';

class WorkoutHistoryDetailView extends StatefulWidget {
  final int workoutRecordId;

  const WorkoutHistoryDetailView({
    super.key,
    required this.workoutRecordId,
  });

  @override
  State<WorkoutHistoryDetailView> createState() =>
      _WorkoutHistoryDetailViewState();
}

class _WorkoutHistoryDetailViewState extends State<WorkoutHistoryDetailView> {

  List<WorkoutSetRecord>? _setRecords;
  Map<int, List<WorkoutSetExerciseRecord>>? _exerciseRecords;
  Map<int, Exercise>? _exercises;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutRecordDetails();
  }

  Future<void> _loadWorkoutRecordDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Store cubit references before async operations
      final workoutRecordCubit = context.read<WorkoutRecordCubit>();
      final workoutCubit = context.read<WorkoutCubit>();
      
      // Get workout record
      await workoutRecordCubit.getWorkoutRecord(widget.workoutRecordId);

      if (!mounted) return;
      final state = workoutRecordCubit.state;
      final workoutRecord = state.selectedWorkoutRecord;

      if (workoutRecord == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      // Get workout details
      await workoutCubit.getWorkout(workoutRecord.workoutId);

      if (!mounted) return;
      
      // Get set records directly from repository
      final setRecordRepository = Repository<WorkoutSetRecord>(
        databaseHelper: DatabaseHelper(),
        tableName: WorkoutSetRecord.table,
        fromMap: (map) => WorkoutSetRecord.fromMap(map),
      );
      final setRecords = await setRecordRepository.selectMany(
        where: 'workout_progress_id = ?',
        whereArgs: [workoutRecord.id],
        orderBy: 'set_number ASC',
      );

      if (!mounted) return;

      // Get exercise records for each set
      final exerciseRecordsMap = <int, List<WorkoutSetExerciseRecord>>{};
      final exerciseIds = <int>{};
      final exerciseRecordRepository = Repository<WorkoutSetExerciseRecord>(
        databaseHelper: DatabaseHelper(),
        tableName: WorkoutSetExerciseRecord.table,
        fromMap: (map) => WorkoutSetExerciseRecord.fromMap(map),
      );

      for (final setRecord in setRecords) {
        if (!mounted) return;
        final exerciseRecords = await exerciseRecordRepository.selectMany(
          where: 'workout_set_progress_id = ?',
          whereArgs: [setRecord.id],
        );
        exerciseRecordsMap[setRecord.id!] = exerciseRecords;
        exerciseIds.addAll(exerciseRecords.map((e) => e.exerciseId));
      }

      if (!mounted) return;

      // Get all exercises directly from repository
      final exerciseRepository = Repository<Exercise>(
        databaseHelper: DatabaseHelper(),
        tableName: Exercise.table,
        fromMap: (map) => Exercise.fromMap(map),
      );
      final exercisesMap = <int, Exercise>{};
      for (final exerciseId in exerciseIds) {
        if (!mounted) return;
        final exercise = await exerciseRepository.selectOne(exerciseId);
        if (exercise != null) {
          exercisesMap[exerciseId] = exercise;
        }
      }

      if (!mounted) return;
      setState(() {
        _setRecords = setRecords;
        _exerciseRecords = exerciseRecordsMap;
        _exercises = exercisesMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading workout details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int? startedAt, int? completedAt) {
    if (startedAt == null || completedAt == null) {
      return 'N/A';
    }

    final duration = Duration(
      milliseconds: (completedAt - startedAt) * 1000,
    );
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Workout Details',
      body: BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
        builder: (context, recordState) {
          final workoutRecord = recordState.selectedWorkoutRecord;

          if (_isLoading || workoutRecord == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<WorkoutCubit, WorkoutState>(
            builder: (context, workoutState) {
              final workout = workoutState.selectedWorkout;

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
                            Text(
                              workout?.name ?? 'Unknown Workout',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Started: ${_formatDate(workoutRecord.startedAt.millisecondsSinceEpoch ~/ 1000)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            if (workoutRecord.completedAt != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 16, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Completed: ${_formatDate(workoutRecord.completedAt!.millisecondsSinceEpoch ~/ 1000)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.timer,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Duration: ${_formatDuration(workoutRecord.startedAt.millisecondsSinceEpoch ~/ 1000, workoutRecord.completedAt != null ? workoutRecord.completedAt!.millisecondsSinceEpoch ~/ 1000 : null)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Performance Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Performance Summary',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Total Sets',
                                    '${workoutRecord.totalSets}',
                                    Icons.repeat,
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Total Reps',
                                    '${workoutRecord.totalReps}',
                                    Icons.fitness_center,
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Rest Time',
                                    _formatDuration(
                                      null,
                                      workoutRecord.totalRestSecs,
                                    ),
                                    Icons.timer,
                                    Colors.purple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Status',
                                    workoutRecord.completedAt != null
                                        ? 'Completed'
                                        : 'In Progress',
                                    workoutRecord.completedAt != null
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    workoutRecord.completedAt != null
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sets and Exercises
                    Text(
                      'Sets & Exercises',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (_setRecords == null || _setRecords!.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No sets recorded',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      ..._setRecords!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final setRecord = entry.value;
                        final exerciseRecords =
                            _exerciseRecords?[setRecord.id] ?? [];

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
                            title: Text('Set ${index + 1}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Completed: ${_formatDate(setRecord.completedAt ?? setRecord.startedAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            children: exerciseRecords.isEmpty
                                ? [
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No exercises in this set',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ]
                                : exerciseRecords.map((exerciseRecord) {
                                    final exercise =
                                        _exercises?[exerciseRecord.exerciseId];
                                    final weightKg =
                                        exerciseRecord.weightGrams / 1000.0;

                                    return ListTile(
                                      leading: const Icon(Icons.fitness_center),
                                      title: Text(
                                        exercise?.name ?? 'Unknown Exercise',
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${exerciseRecord.reps} reps × ${weightKg.toStringAsFixed(2)} kg',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          if (exerciseRecord.difficulty != null)
                                            Text(
                                              'Difficulty: ${exerciseRecord.difficulty}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                      onTap: exercise != null
                                          ? () {
                                              context.push(
                                                '/exercises/${exercise.id}',
                                              );
                                            }
                                          : null,
                                    );
                                  }).toList(),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
