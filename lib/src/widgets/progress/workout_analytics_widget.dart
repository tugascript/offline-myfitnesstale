import 'package:flutter/material.dart';

import '../../models/workout_record_model.dart';
import '../../models/workout_set_exercise_record_model.dart';
import '../../models/exercise_model.dart';
import '../../services/workout_set_exercise_record_service.dart';
import '../../services/workout_record_service.dart';
import '../../services/workout_set_record_service.dart';
import '../../services/exercise_service.dart';
import '../../services/common/result.dart';

class WorkoutAnalyticsWidget extends StatefulWidget {
  const WorkoutAnalyticsWidget({super.key});

  @override
  State<WorkoutAnalyticsWidget> createState() => _WorkoutAnalyticsWidgetState();
}

class _WorkoutAnalyticsWidgetState extends State<WorkoutAnalyticsWidget> {
  final WorkoutRecordService _workoutRecordService = WorkoutRecordService();
  final WorkoutSetExerciseRecordService _exerciseRecordService =
      WorkoutSetExerciseRecordService();
  final WorkoutSetRecordService _setRecordService = WorkoutSetRecordService();
  final ExerciseService _exerciseService = ExerciseService();

  List<WorkoutRecord> _workoutRecords = [];
  Map<int, List<WorkoutSetExerciseRecord>> _exerciseRecords = {};
  Map<int, double> _volumeByDate = {};
  Map<int, Exercise> _exercises = {};
  double _maxVolume = 0.0;
  WorkoutRecord? _maxVolumeWorkout;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final workoutRecordsResult = await _workoutRecordService.getWorkoutRecords(
        limit: 100,
      );
      if (workoutRecordsResult.isErr()) {
        setState(() => _isLoading = false);
        return;
      }
      final workoutRecords = (workoutRecordsResult as Ok).value.data;

      final exerciseRecordsMap = <int, List<WorkoutSetExerciseRecord>>{};
      final volumeByDate = <int, double>{};
      final exerciseIds = <int>{};
      final exercisesMap = <int, Exercise>{};

      for (final record in workoutRecords) {
        if (record.id == null) continue;

        // Get set records for this workout
        final setRecordsResult = await _setRecordService.getWorkoutSetRecords(
          workoutProgressId: record.id,
        );
        if (setRecordsResult.isErr()) continue;
        final setRecords = (setRecordsResult as Ok).value.data;

        // Get exercise records for each set
        for (final setRecord in setRecords) {
          if (setRecord.id == null) continue;

          final exerciseRecordsResult =
              await _exerciseRecordService.getWorkoutSetExerciseRecords(
            workoutSetProgressId: setRecord.id,
          );
          if (exerciseRecordsResult.isErr()) continue;
          final exerciseRecords = (exerciseRecordsResult as Ok).value;

          exerciseRecordsMap[setRecord.id!] = exerciseRecords;
          exerciseIds.addAll(exerciseRecords.map((e) => e.exerciseId));

          // Calculate volume (weight * reps) for this workout
          final workoutVolume = exerciseRecords.fold<double>(
            0.0,
            (sum, er) => sum + (er.weightGrams / 1000.0) * er.reps,
          );

          // Group by date (day timestamp)
          final dateKey = _getDateKey(record.startedAt);
          volumeByDate[dateKey] =
              (volumeByDate[dateKey] ?? 0.0) + workoutVolume;
        }
      }

      // Load all exercises
      if (exerciseIds.isNotEmpty) {
        final exercises = await _exerciseService.getExercisesByIdsLoader(
          exerciseIds.toList(),
        );
        exercisesMap.addAll(exercises);
      }

      // Calculate max volume workout
      double maxVolume = 0.0;
      WorkoutRecord? maxVolumeWorkout;
      final completedRecords =
          workoutRecords.where((r) => r.completedAt != null).toList();
      for (final record in completedRecords) {
        if (record.id == null) continue;
        final setRecordsResult = await _setRecordService.getWorkoutSetRecords(
          workoutProgressId: record.id,
        );
        if (setRecordsResult.isErr()) continue;
        final setRecords = (setRecordsResult as Ok).value.data;
        double workoutVolume = 0.0;
        for (final setRecord in setRecords) {
          if (setRecord.id == null) continue;
          final exerciseRecordsResult =
              await _exerciseRecordService.getWorkoutSetExerciseRecords(
            workoutSetProgressId: setRecord.id,
          );
          if (exerciseRecordsResult.isErr()) continue;
          final exerciseRecords = (exerciseRecordsResult as Ok).value;
          workoutVolume += exerciseRecords.fold<double>(
            0.0,
            (sum, er) => sum + (er.weightGrams / 1000.0) * er.reps,
          );
        }
        if (workoutVolume > maxVolume) {
          maxVolume = workoutVolume;
          maxVolumeWorkout = record;
        }
      }

      setState(() {
        _workoutRecords = workoutRecords;
        _exerciseRecords = exerciseRecordsMap;
        _volumeByDate = volumeByDate;
        _exercises = exercisesMap;
        _maxVolume = maxVolume;
        _maxVolumeWorkout = maxVolumeWorkout;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int _getDateKey(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/
        1000;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_workoutRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Analytics Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts to see analytics',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          _buildSummaryStats(),
          const SizedBox(height: 24),
          // Volume Tracking
          _buildVolumeTracking(),
          const SizedBox(height: 24),
          // Strength Progression
          _buildStrengthProgression(),
          const SizedBox(height: 24),
          // Personal Bests
          _buildPersonalBests(),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalWorkouts = _workoutRecords.length;
    final completedWorkouts =
        _workoutRecords.where((r) => r.completedAt != null).length;
    final totalSets = _workoutRecords.fold<int>(
      0,
      (sum, record) => sum + record.totalSets,
    );
    final totalReps = _workoutRecords.fold<int>(
      0,
      (sum, record) => sum + record.totalReps,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary Statistics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Workouts',
                totalWorkouts.toString(),
                Icons.fitness_center,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completed',
                completedWorkouts.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sets',
                totalSets.toString(),
                Icons.repeat,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Reps',
                totalReps.toString(),
                Icons.fitness_center,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVolumeTracking() {
    // Calculate weekly volume
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final thisMonth = _workoutRecords.where((r) {
      final date = DateTime.fromMillisecondsSinceEpoch(r.startedAt * 1000);
      return date.isAfter(monthAgo);
    }).length;

    // Calculate total volume
    double totalVolume = 0.0;
    double weeklyVolume = 0.0;
    double monthlyVolume = 0.0;

    for (final entry in _volumeByDate.entries) {
      final date = DateTime.fromMillisecondsSinceEpoch(entry.key * 1000);
      totalVolume += entry.value;

      if (date.isAfter(weekAgo)) {
        weeklyVolume += entry.value;
      }

      if (date.isAfter(monthAgo)) {
        monthlyVolume += entry.value;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volume Tracking',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFrequencyCard(
                    'This Week',
                    '${weeklyVolume.toStringAsFixed(0)} kg',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFrequencyCard(
                    'This Month',
                    '${monthlyVolume.toStringAsFixed(0)} kg',
                    Icons.calendar_month,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFrequencyCard(
                    'Total Volume',
                    '${totalVolume.toStringAsFixed(0)} kg',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFrequencyCard(
                    'Workouts',
                    '$thisMonth this month',
                    Icons.fitness_center,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthProgression() {
    if (_exerciseRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    // Collect all exercise records and find max weights per exercise
    final exerciseMaxWeights = <int, double>{};
    final exerciseMaxReps = <int, int>{};
    final exerciseMaxVolume = <int, double>{};

    for (final records in _exerciseRecords.values) {
      for (final record in records) {
        final weight = record.weightGrams / 1000.0;
        final volume = weight * record.reps;

        // Track max weight
        final currentMaxWeight = exerciseMaxWeights[record.exerciseId] ?? 0.0;
        if (weight > currentMaxWeight) {
          exerciseMaxWeights[record.exerciseId] = weight;
        }

        // Track max reps
        final currentMaxReps = exerciseMaxReps[record.exerciseId] ?? 0;
        if (record.reps > currentMaxReps) {
          exerciseMaxReps[record.exerciseId] = record.reps;
        }

        // Track max volume
        final currentMaxVolume = exerciseMaxVolume[record.exerciseId] ?? 0.0;
        if (volume > currentMaxVolume) {
          exerciseMaxVolume[record.exerciseId] = volume;
        }
      }
    }

    if (exerciseMaxWeights.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get top 5 exercises by max weight
    final sortedExercises = exerciseMaxWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topExercises = sortedExercises.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Strength Progression',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topExercises.map((entry) {
              final exercise = _exercises[entry.key];
              final maxReps = exerciseMaxReps[entry.key] ?? 0;
              final maxVolume = exerciseMaxVolume[entry.key] ?? 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  color: Colors.blue.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise?.name ?? 'Exercise ${entry.key}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${entry.value.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Max Reps: $maxReps',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Max Volume: ${maxVolume.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
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
            }),
            if (topExercises.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Complete workouts to see strength progression',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalBests() {
    if (_workoutRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedRecords =
        _workoutRecords.where((r) => r.completedAt != null).toList();
    if (completedRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find personal bests
    final maxSets = completedRecords.reduce(
      (a, b) => a.totalSets > b.totalSets ? a : b,
    );
    final maxReps = completedRecords.reduce(
      (a, b) => a.totalReps > b.totalReps ? a : b,
    );

    // Find longest workout
    final longestWorkout = completedRecords.reduce((a, b) {
      final durationA = (a.completedAt! - a.startedAt);
      final durationB = (b.completedAt! - b.startedAt);
      return durationA > durationB ? a : b;
    });

    String formatDuration(int startedAt, int completedAt) {
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  'Personal Bests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPersonalBestCard(
              'Most Sets in a Workout',
              '${maxSets.totalSets} sets',
              Icons.repeat,
            ),
            const SizedBox(height: 12),
            _buildPersonalBestCard(
              'Most Reps in a Workout',
              '${maxReps.totalReps} reps',
              Icons.fitness_center,
            ),
            if (longestWorkout.completedAt != null) ...[
              const SizedBox(height: 12),
              _buildPersonalBestCard(
                'Longest Workout',
                formatDuration(
                    longestWorkout.startedAt, longestWorkout.completedAt!),
                Icons.timer,
              ),
            ],
            if (_maxVolumeWorkout != null && _maxVolume > 0) ...[
              const SizedBox(height: 12),
              _buildPersonalBestCard(
                'Highest Volume Workout',
                '${_maxVolume.toStringAsFixed(1)} kg',
                Icons.trending_up,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBestCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                    color: Colors.amber[900],
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
