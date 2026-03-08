// Copyright (C) 2026 Afonso Barracha
//
// This file is part of MyFitnessTale.
//
// MyFitnessTale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MyFitnessTale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MyFitnessTale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import '../cubits/states/weight_record_state.dart';
import '../cubits/states/workout_record_state.dart';
import '../cubits/weight_record_cubit.dart';
import '../cubits/workout_record_cubit.dart';
import '../models/enums.dart';
import '../services/dtos/system_dto.dart';
import '../services/dtos/weight_record_dto.dart';
import '../utilities/converters.dart';
import '../widgets/layout/responsive_scaffold.dart';
import 'exercise_progress_view.dart';
import 'workout_history_view.dart';

class ProgressView extends StatefulWidget {
  static const routeName = "/progress";
  static const name = "progress";

  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Load weight records
    context.read<WeightRecordCubit>().getWeightRecords(limit: 20, offset: 0);
    // Load workout records
    context.read<WorkoutRecordCubit>().getWorkoutRecords(limit: 50, offset: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: "Progress",
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return BlocConsumer<WeightRecordCubit, WeightRecordState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!.description),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, weightState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight -
                    100, // Approximate space for tab bar
                child: Column(
                  children: [
                    // Tab Bar
                    Container(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.monitor_weight),
                            text: 'Weight',
                          ),
                          Tab(
                            icon: Icon(Icons.flag),
                            text: 'Goals',
                          ),
                          Tab(
                            icon: Icon(Icons.trending_up),
                            text: 'Analytics',
                          ),
                          Tab(
                            icon: Icon(Icons.fitness_center),
                            text: 'Workouts',
                          ),
                          Tab(
                            icon: Icon(Icons.track_changes),
                            text: 'Exercises',
                          ),
                        ],
                      ),
                    ),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildWeightTab(weightState, profileState.system),
                          _buildGoalsTab(),
                          _buildAnalyticsTab(weightState, profileState.system),
                          _buildWorkoutHistoryTab(),
                          _buildExerciseProgressTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWeightTab(WeightRecordState weightState, SystemDto? system) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weight Tracking',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Log Weight'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Current Weight Display
          if (weightState.weightRecords.isNotEmpty)
            _buildCurrentWeightCard(weightState.weightRecords.first, system),

          const SizedBox(height: 24),

          // Weight History
          Expanded(
            child: _buildWeightHistory(
                weightState.weightRecords, system, weightState),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight Goal Tracking Widget
          // const WeightGoalTrackingWidget(),

          // const SizedBox(height: 24),

          // Goal History (Future enhancement)
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goal History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Goal History Coming Soon',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(WeightRecordState weightState, SystemDto? system) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight Analytics Section
          if (weightState.weightRecords.isNotEmpty) ...[
            Text(
              'Weight Analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildWeightStatistics(
              weightState.weightRecords,
              weightState.recordPagination.total,
              system,
            ),
            const SizedBox(height: 24),
            _buildWeightTrendChart(weightState.weightRecords, system),
            const SizedBox(height: 32),
          ],
          // Workout Analytics Section
          Text(
            'Workout Analytics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // TODO: create a proper workout analytics
        ],
      ),
    );
  }

  Widget _buildCurrentWeightCard(
      WeightRecordDto latestWeight, SystemDto? system) {
    final units = system?.units ?? Units.metric;
    final displayWeight = units == Units.metric
        ? '${(latestWeight.weight / 1000).toStringAsFixed(1)} kg'
        : '${(latestWeight.weight / 453.592).toStringAsFixed(1)} lbs';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Weight',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              displayWeight,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            if (latestWeight.fatPercentage != null) ...[
              const SizedBox(height: 4),
              Text(
                'Body Fat: ${latestWeight.fatPercentage}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDate(latestWeight.recordDate.millisecondsSinceEpoch ~/ 1000)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightHistory(List<WeightRecordDto> weightRecords,
      SystemDto? system, WeightRecordState weightState) {
    final units = system?.units ?? Units.metric;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: weightRecords.length,
            itemBuilder: (context, index) {
              final record = weightRecords[index];
              final displayWeight = units == Units.metric
                  ? Converters.formatMetricWeight(record.weight)
                  : Converters.formatImperialWeight(record.weight);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                    leading: const Icon(Icons.monitor_weight),
                    title: Text(displayWeight),
                    subtitle: Text(_formatDate(
                        record.recordDate.millisecondsSinceEpoch ~/ 1000)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (record.fatPercentage != null)
                          Chip(
                            label: Text('${record.fatPercentage}% fat'),
                            backgroundColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                          ),
                        weightState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                tooltip: 'Delete record',
                                onPressed: () {
                                  _showDeleteConfirmation(record);
                                },
                              ),
                      ],
                    )),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightStatistics(
      List<WeightRecordDto> weightRecords, int weightTotal, SystemDto? system) {
    final units = system?.units ?? Units.metric;

    // Calculate statistics
    final weights = weightRecords.map((r) => r.weight.toDouble()).toList();
    final averageWeight = weights.reduce((a, b) => a + b) / weights.length;
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    String formatWeight(double weight) {
      if (units == Units.metric) {
        return '${(weight / 1000).toStringAsFixed(1)} kg';
      } else {
        return '${(weight / 453.592).toStringAsFixed(1)} lbs';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight Statistics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Average',
                formatWeight(averageWeight),
                Icons.analytics,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Lowest',
                formatWeight(minWeight),
                Icons.trending_down,
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
                'Highest',
                formatWeight(maxWeight),
                Icons.trending_up,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Records',
                weightTotal.toString(),
                Icons.list,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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

  Widget _buildWeightTrendChart(
      List<WeightRecordDto> weightRecords, SystemDto? system) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chart Coming Soon',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int recordDate) {
    final date = DateTime.fromMillisecondsSinceEpoch(recordDate * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(WeightRecordDto record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Weight Record'),
          content: Text(
            'Are you sure you want to delete this weight record from ${_formatDate(record.recordDate.millisecondsSinceEpoch ~/ 1000)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteWeightRecord(record.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWeightRecord(int? id) {
    if (id != null) {
      context.read<WeightRecordCubit>().deleteWeightRecord(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weight record deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildWorkoutHistoryTab() {
    return BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
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

        return Column(
          children: [
            // Quick Stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildWorkoutQuickStats(state.workoutRecords),
            ),
            // Workout History List
            Expanded(
              child: const WorkoutHistoryView(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutQuickStats(List<dynamic> workoutRecords) {
    final completedCount =
        workoutRecords.where((r) => r.completedAt != null).length;
    final totalSets = workoutRecords.fold<int>(
      0,
      (sum, record) => sum + (record.totalSets as int),
    );
    final totalReps = workoutRecords.fold<int>(
      0,
      (sum, record) => sum + (record.totalReps as int),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickStatItem(
                'Completed',
                completedCount.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildQuickStatItem(
                'Total Sets',
                totalSets.toString(),
                Icons.repeat,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildQuickStatItem(
                'Total Reps',
                totalReps.toString(),
                Icons.fitness_center,
                Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseProgressTab() {
    return const ExerciseProgressView();
  }
}
