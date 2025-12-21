import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/workout_set_exercise_record_model.dart';
import '../services/exercise_service.dart';
import '../services/workout_set_exercise_record_service.dart';
import '../widgets/layout/responsive_scaffold.dart';

class ExerciseHistoryDetailView extends StatefulWidget {
  final int exerciseId;

  const ExerciseHistoryDetailView({
    super.key,
    required this.exerciseId,
  });

  @override
  State<ExerciseHistoryDetailView> createState() =>
      _ExerciseHistoryDetailViewState();
}

class _ExerciseHistoryDetailViewState
    extends State<ExerciseHistoryDetailView> {
  final ExerciseService _exerciseService = ExerciseService();
  final WorkoutSetExerciseRecordService _exerciseRecordService =
      WorkoutSetExerciseRecordService();

  Exercise? _exercise;
  List<WorkoutSetExerciseRecord> _records = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExerciseHistory();
  }

  Future<void> _loadExerciseHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load exercise
      final exercise = await _exerciseService.getExercise(widget.exerciseId);
      if (exercise == null) {
        setState(() {
          _error = 'Exercise not found';
          _isLoading = false;
        });
        return;
      }

      // Load all exercise records
      final records =
          await _exerciseRecordService.getWorkoutSetExerciseRecords(
        exerciseId: widget.exerciseId,
      );

      // Sort by creation date (most recent first)
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _exercise = exercise;
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: _exercise?.name ?? 'Exercise Progress',
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
                        'Error loading exercise history',
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
                        onPressed: _loadExerciseHistory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No Progress Data',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete workouts with this exercise to see progress',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise Info
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _exercise?.name ?? 'Unknown Exercise',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (_exercise?.description != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _exercise!.description!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Progress Statistics
                          _buildProgressStatistics(),
                          const SizedBox(height: 16),
                          // Weight Progression
                          _buildWeightProgression(),
                          const SizedBox(height: 16),
                          // Volume Tracking
                          _buildVolumeTracking(),
                          const SizedBox(height: 16),
                          // Recent History
                          _buildRecentHistory(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProgressStatistics() {
    if (_records.isEmpty) return const SizedBox.shrink();

    final weights = _records.map((r) => r.weightGrams / 1000.0).toList();
    final reps = _records.map((r) => r.reps).toList();
    final volumes =
        _records.map((r) => (r.weightGrams / 1000.0) * r.reps).toList();

    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final maxReps = reps.reduce((a, b) => a > b ? a : b);
    final maxVolume = volumes.reduce((a, b) => a > b ? a : b);
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
    final totalVolume = volumes.reduce((a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Sessions',
                    '${_records.length}',
                    Icons.event,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Max Weight',
                    '${maxWeight.toStringAsFixed(1)} kg',
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
                  child: _buildStatCard(
                    'Max Reps',
                    '$maxReps',
                    Icons.repeat,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Max Volume',
                    '${maxVolume.toStringAsFixed(1)} kg',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Weight',
                    '${avgWeight.toStringAsFixed(1)} kg',
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Volume',
                    '${totalVolume.toStringAsFixed(1)} kg',
                    Icons.inventory,
                    Colors.indigo,
                  ),
                ),
              ],
            ),
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
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgression() {
    if (_records.isEmpty) return const SizedBox.shrink();

    // Group records by date and get max weight per date
    final Map<String, double> weightByDate = {};
    for (final record in _records) {
      final date = DateTime.fromMillisecondsSinceEpoch(record.createdAt * 1000);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final weight = record.weightGrams / 1000.0;
      final currentMax = weightByDate[dateKey] ?? 0.0;
      if (weight > currentMax) {
        weightByDate[dateKey] = weight;
      }
    }

    final sortedDates = weightByDate.keys.toList()..sort();
    if (sortedDates.isEmpty) return const SizedBox.shrink();

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
                  'Weight Progression',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedDates.length == 1)
              Center(
                child: Text(
                  'Only one session recorded',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...sortedDates.reversed.take(10).map((dateKey) {
                final weight = weightByDate[dateKey]!;
                final dateParts = dateKey.split('-');
                final displayDate =
                    '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${weight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeTracking() {
    if (_records.isEmpty) return const SizedBox.shrink();

    // Calculate volume by week
    final Map<String, double> volumeByWeek = {};
    for (final record in _records) {
      final date = DateTime.fromMillisecondsSinceEpoch(record.createdAt * 1000);
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekKey =
          '${weekStart.year}-W${((weekStart.difference(DateTime(weekStart.year, 1, 1)).inDays) / 7).floor() + 1}';
      final volume = (record.weightGrams / 1000.0) * record.reps;
      volumeByWeek[weekKey] = (volumeByWeek[weekKey] ?? 0.0) + volume;
    }

    final sortedWeeks = volumeByWeek.keys.toList()..sort();
    if (sortedWeeks.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Volume Tracking',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedWeeks.reversed.take(8).map((weekKey) {
              final volume = volumeByWeek[weekKey] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        weekKey,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${volume.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory() {
    if (_records.isEmpty) return const SizedBox.shrink();

    final recentRecords = _records.take(20).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recentRecords.map((record) {
              final weight = record.weightGrams / 1000.0;

              return ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(
                  '${weight.toStringAsFixed(1)} kg × ${record.reps} reps',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(_formatDate(record.createdAt)),
                trailing: Text(
                  '${(weight * record.reps).toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

