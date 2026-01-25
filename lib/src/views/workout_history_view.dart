import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/workout_record_cubit.dart';
import '../cubits/states/workout_record_state.dart';
import '../services/dtos/workout_record_dto.dart';
import '../services/dtos/workout_dto.dart';
import '../services/workout_service.dart';
import '../widgets/layout/responsive_scaffold.dart';

class WorkoutHistoryView extends StatefulWidget {
  static const routeName = '/workouts/history';

  const WorkoutHistoryView({super.key});

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  final Map<int, WorkoutDto> _workoutCache = {};
  final WorkoutService _workoutService = WorkoutService();

  @override
  void initState() {
    super.initState();
    context.read<WorkoutRecordCubit>().getWorkoutRecords(
          limit: 50,
          offset: 0,
        );
  }

  Future<WorkoutDto?> _getWorkout(int workoutId) async {
    if (_workoutCache.containsKey(workoutId)) {
      return _workoutCache[workoutId];
    }

    final workoutResult = await _workoutService.getWorkout(workoutId);
    if (workoutResult.isOk()) {
      _workoutCache[workoutId] = workoutResult.value;
      return workoutResult.value;
    }
    return null;
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
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

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Workout History',
      body: BlocConsumer<WorkoutRecordCubit, WorkoutRecordState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.workoutRecords.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.workoutRecords.isEmpty) {
            return Center(
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
                    'No Workout History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete some workouts to see your history here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate personal records
          final personalRecords =
              _calculatePersonalRecords(state.workoutRecords);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WorkoutRecordCubit>().getWorkoutRecords(
                    limit: 50,
                    offset: 0,
                  );
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Personal Records Section
                if (personalRecords.isNotEmpty) ...[
                  _buildPersonalRecordsSection(personalRecords),
                  const SizedBox(height: 16),
                ],
                // Workout History List
                ...state.workoutRecords.map((record) {
                  final isPersonalBest =
                      _isPersonalBest(record, personalRecords);

                  return FutureBuilder<WorkoutDto?>(
                    future: _getWorkout(record.workoutId),
                    builder: (context, snapshot) {
                      final workout = snapshot.data;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isPersonalBest ? 4 : 1,
                        color: isPersonalBest
                            ? Colors.amber.withValues(alpha: 0.05)
                            : null,
                        child: InkWell(
                          onTap: () {
                            context.push(
                              '/workouts/history/${record.id}',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  workout?.name ??
                                                      'Unknown Workout',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (isPersonalBest)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.emoji_events,
                                                        size: 14,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'PB',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(record.startedAt
                                                    .millisecondsSinceEpoch ~/
                                                1000),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (record.completedAt != null)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      )
                                    else
                                      Icon(
                                        Icons.radio_button_unchecked,
                                        color: Colors.orange,
                                        size: 24,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetricChip(
                                        Icons.repeat,
                                        '${record.totalSets} sets',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMetricChip(
                                        Icons.fitness_center,
                                        '${record.totalReps} reps',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMetricChip(
                                        Icons.timer,
                                        _formatDuration(
                                          record.startedAt
                                                  .millisecondsSinceEpoch ~/
                                              1000,
                                          record.completedAt != null
                                              ? record.completedAt!
                                                      .millisecondsSinceEpoch ~/
                                                  1000
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Map<String, WorkoutRecordDto> _calculatePersonalRecords(
    List<WorkoutRecordDto> records,
  ) {
    if (records.isEmpty) return {};

    final completedRecords =
        records.where((r) => r.completedAt != null).toList();
    if (completedRecords.isEmpty) return {};

    final Map<String, WorkoutRecordDto> personalRecords = {};

    // Most sets
    final maxSets = completedRecords.reduce(
      (a, b) => a.totalSets > b.totalSets ? a : b,
    );
    personalRecords['mostSets'] = maxSets;

    // Most reps
    final maxReps = completedRecords.reduce(
      (a, b) => a.totalReps > b.totalReps ? a : b,
    );
    personalRecords['mostReps'] = maxReps;

    // Longest workout (by duration)
    final longestWorkout = completedRecords.reduce((a, b) {
      final durationA = a.completedAt!.difference(a.startedAt).inSeconds;
      final durationB = b.completedAt!.difference(b.startedAt).inSeconds;
      return durationA > durationB ? a : b;
    });
    personalRecords['longestWorkout'] = longestWorkout;

    return personalRecords;
  }

  bool _isPersonalBest(
      WorkoutRecordDto record, Map<String, WorkoutRecordDto> personalRecords) {
    return personalRecords.values.any((pb) => pb.id == record.id);
  }

  Widget _buildPersonalRecordsSection(
      Map<String, WorkoutRecordDto> personalRecords) {
    return Card(
      color: Colors.amber.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Personal Records',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (personalRecords.containsKey('mostSets'))
              _buildPersonalRecordItem(
                'Most Sets',
                '${personalRecords['mostSets']!.totalSets} sets',
                Icons.repeat,
                Colors.blue,
              ),
            if (personalRecords.containsKey('mostReps'))
              _buildPersonalRecordItem(
                'Most Reps',
                '${personalRecords['mostReps']!.totalReps} reps',
                Icons.fitness_center,
                Colors.orange,
              ),
            if (personalRecords.containsKey('longestWorkout'))
              _buildPersonalRecordItem(
                'Longest Workout',
                _formatDuration(
                  personalRecords['longestWorkout']!
                          .startedAt
                          .millisecondsSinceEpoch ~/
                      1000,
                  personalRecords['longestWorkout']!.completedAt != null
                      ? personalRecords['longestWorkout']!
                              .completedAt!
                              .millisecondsSinceEpoch ~/
                          1000
                      : null,
                ),
                Icons.timer,
                Colors.purple,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalRecordItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
