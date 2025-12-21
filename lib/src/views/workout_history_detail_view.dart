import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/workout_cubit.dart';
import '../cubits/workout_record_cubit.dart';
import '../cubits/states/workout_state.dart';
import '../cubits/states/workout_record_state.dart';
import '../models/workout_set_record_model.dart';
import '../models/workout_set_exercise_record_model.dart';
import '../models/exercise_model.dart';
import '../services/workout_set_record_service.dart';
import '../services/workout_set_exercise_record_service.dart';
import '../services/exercise_service.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../utilities/converters.dart';

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
  final WorkoutSetRecordService _setRecordService = WorkoutSetRecordService();
  final WorkoutSetExerciseRecordService _exerciseRecordService =
      WorkoutSetExerciseRecordService();
  final ExerciseService _exerciseService = ExerciseService();

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
    setState(() => _isLoading = true);

    try {
      // Get workout record
      await context
          .read<WorkoutRecordCubit>()
          .getWorkoutRecord(widget.workoutRecordId);

      final state = context.read<WorkoutRecordCubit>().state;
      final workoutRecord = state.selectedWorkoutRecord;

      if (workoutRecord == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get workout details
      await context.read<WorkoutCubit>().getWorkout(workoutRecord.workoutId);

      // Get set records
      final setRecords = await _setRecordService.getWorkoutSetRecords(
        workoutProgressId: workoutRecord.id,
      );

      // Get exercise records for each set
      final exerciseRecordsMap = <int, List<WorkoutSetExerciseRecord>>{};
      final exerciseIds = <int>{};

      for (final setRecord in setRecords) {
        final exerciseRecords =
            await _exerciseRecordService.getWorkoutSetExerciseRecords(
          workoutSetProgressId: setRecord.id,
        );
        exerciseRecordsMap[setRecord.id!] = exerciseRecords;
        exerciseIds.addAll(exerciseRecords.map((e) => e.exerciseId));
      }

      // Get all exercises
      final exercisesMap = <int, Exercise>{};
      for (final exerciseId in exerciseIds) {
        final exercise = await _exerciseService.getExercise(exerciseId);
        if (exercise != null) {
          exercisesMap[exerciseId] = exercise;
        }
      }

      setState(() {
        _setRecords = setRecords;
        _exerciseRecords = exerciseRecordsMap;
        _exercises = exercisesMap;
        _isLoading = false;
      });
    } catch (e) {
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
              final workout = workoutState.selectedWorkout?.workout;

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
                                  'Started: ${_formatDate(workoutRecord.startedAt)}',
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
                                    'Completed: ${_formatDate(workoutRecord.completedAt!)}',
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
                                    'Duration: ${_formatDuration(workoutRecord.startedAt, workoutRecord.completedAt)}',
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
                                    final converters = Converters();

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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
