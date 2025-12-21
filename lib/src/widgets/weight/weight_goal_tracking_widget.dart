import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/weight_goal_cubit.dart';
import '../../cubits/states/weight_goal_state.dart';
import '../../cubits/weight_record_cubit.dart';
import '../../cubits/states/weight_record_state.dart';
import '../../models/enums.dart';
import '../../models/weight_goal_model.dart';
import '../../models/weight_record_model.dart';
import '../../utilities/converters.dart';
import '../../views/weight_goal_view.dart';

class WeightGoalTrackingWidget extends StatelessWidget {
  const WeightGoalTrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeightGoalCubit, WeightGoalState>(
      builder: (context, goalState) {
        return BlocBuilder<WeightRecordCubit, WeightRecordState>(
          builder: (context, weightState) {
            return BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                final activeGoal = goalState.activeWeightGoal;
                final latestWeight = weightState.weightRecords.isNotEmpty
                    ? weightState.weightRecords.first
                    : null;

                if (activeGoal == null) {
                  return _buildNoGoalCard(context);
                }

                return _buildGoalProgressCard(
                  context,
                  activeGoal,
                  latestWeight,
                  profileState.system?.units ?? Units.metric,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNoGoalCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weight Goal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No active weight goal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WeightGoalView(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Set a Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard(
    BuildContext context,
    WeightGoal goal,
    WeightRecord? latestWeight,
    Units units,
  ) {
    final progress = _calculateProgress(goal, latestWeight, units);
    final remainingWeight =
        _calculateRemainingWeight(goal, latestWeight, units);
    final estimatedCompletion =
        _calculateEstimatedCompletion(goal, latestWeight);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Weight Goal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _buildStatusChip(goal.status),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            _buildProgressBar(context, progress),
            const SizedBox(height: 12),

            // Goal Details
            _buildGoalDetails(context, goal, latestWeight, units),
            const SizedBox(height: 16),

            // Progress Stats
            _buildProgressStats(context, remainingWeight, estimatedCompletion),
            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(context, goal),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : Theme.of(context).primaryColor,
          ),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildGoalDetails(
    BuildContext context,
    WeightGoal goal,
    WeightRecord? latestWeight,
    Units units,
  ) {
    final targetWeight = units == Units.metric
        ? Converters().formatMetricWeight(goal.targetWeight)
        : Converters().formatImperialWeight(goal.targetWeight);

    final currentWeight = latestWeight != null
        ? (units == Units.metric
            ? Converters().formatMetricWeight(latestWeight.weight)
            : Converters().formatImperialWeight(latestWeight.weight))
        : 'No data';

    final startDate =
        DateTime.fromMillisecondsSinceEpoch(goal.startDate * 1000);
    final endDate = DateTime.fromMillisecondsSinceEpoch(goal.endDate * 1000);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem('Target', targetWeight, Icons.flag),
            ),
            Expanded(
              child: _buildDetailItem(
                  'Current', currentWeight, Icons.monitor_weight),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Start',
                '${startDate.day}/${startDate.month}/${startDate.year}',
                Icons.calendar_today,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'Target Date',
                '${endDate.day}/${endDate.month}/${endDate.year}',
                Icons.event,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStats(
    BuildContext context,
    String remainingWeight,
    String estimatedCompletion,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Remaining',
            remainingWeight,
            Icons.trending_up,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Est. Completion',
            estimatedCompletion,
            Icons.schedule,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WeightGoal goal) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WeightGoalView(goalToEdit: goal),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showGoalActionDialog(context, goal);
            },
            icon: const Icon(Icons.flag),
            label: const Text('Actions'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ProgressStatus status) {
    Color color;
    String text;

    switch (status) {
      case ProgressStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case ProgressStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case ProgressStatus.abandoned:
        color = Colors.red;
        text = 'Abandoned';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showGoalActionDialog(BuildContext context, WeightGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Goal Actions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Mark as Completed'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<WeightGoalCubit>().completeWeightGoal(goal.id!);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Abandon Goal'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<WeightGoalCubit>().abandonWeightGoal(goal.id!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  double _calculateProgress(
      WeightGoal goal, WeightRecord? latestWeight, Units units) {
    if (latestWeight == null) return 0.0;

    final startDate =
        DateTime.fromMillisecondsSinceEpoch(goal.startDate * 1000);
    final endDate = DateTime.fromMillisecondsSinceEpoch(goal.endDate * 1000);
    final now = DateTime.now();

    // Calculate time progress
    final totalDuration = endDate.difference(startDate).inDays;
    final elapsedDuration = now.difference(startDate).inDays;
    final timeProgress = elapsedDuration / totalDuration;

    // Calculate weight progress (simplified - assumes linear progress)
    // This is a basic calculation and could be improved with more sophisticated logic
    return timeProgress.clamp(0.0, 1.0);
  }

  String _calculateRemainingWeight(
      WeightGoal goal, WeightRecord? latestWeight, Units units) {
    if (latestWeight == null) return 'Unknown';

    final currentWeight = latestWeight.weight.toDouble();
    final targetWeight = goal.targetWeight.toDouble();
    final difference = (targetWeight - currentWeight).abs();

    if (units == Units.metric) {
      return '${(difference / 1000).toStringAsFixed(1)} kg';
    } else {
      return '${(difference / 453.592).toStringAsFixed(1)} lbs';
    }
  }

  String _calculateEstimatedCompletion(
      WeightGoal goal, WeightRecord? latestWeight) {
    final endDate = DateTime.fromMillisecondsSinceEpoch(goal.endDate * 1000);
    final now = DateTime.now();
    final daysRemaining = endDate.difference(now).inDays;

    if (daysRemaining <= 0) {
      return 'Overdue';
    } else if (daysRemaining < 7) {
      return '$daysRemaining days';
    } else {
      final weeks = (daysRemaining / 7).ceil();
      return '$weeks weeks';
    }
  }
}
