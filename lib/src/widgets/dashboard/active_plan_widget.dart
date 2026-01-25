import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/states/workout_plan_record_state.dart';
import '../../cubits/workout_plan_record_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/profile_dto.dart';
import '../../utilities/sizes/home_sizes.dart';

class ActivePlanWidget extends StatefulWidget {
  final HomeSizesList sizes;

  const ActivePlanWidget({
    super.key,
    required this.sizes,
  });

  @override
  State<ActivePlanWidget> createState() => _ActivePlanWidgetState();
}

class _ActivePlanWidgetState extends State<ActivePlanWidget> {
  bool _hasAttemptedLoad = false;

  @override
  void initState() {
    super.initState();
    // Check if profile is already loaded when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final profileState = context.read<ProfileCubit>().state;
        if (profileState.profile != null && !profileState.isLoading) {
          _loadActivePlanIfNeeded(profileState.profile);
        }
      }
    });
  }

  void _loadActivePlanIfNeeded(ProfileDto? profile) {
    if (_hasAttemptedLoad || profile == null) {
      return;
    }

    final cubit = context.read<WorkoutPlanRecordCubit>();
    // Only load if not already loading and no plan exists
    if (!cubit.state.isLoading &&
        cubit.state.currentPlanRecord.workoutPlan == null) {
      _hasAttemptedLoad = true;
      // Load active plan record
      cubit.getActivePlanRecord();
    }
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
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, profileState) {
        // Load active plan when profile becomes available (only once)
        if (profileState.profile != null && !profileState.isLoading) {
          _loadActivePlanIfNeeded(profileState.profile);
        }
      },
      child: BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
        builder: (context, state) {
          final currentPlanRecord = state.currentPlanRecord;

          if (currentPlanRecord.workoutPlan == null) {
            return const SizedBox.shrink();
          }

          final plan = currentPlanRecord.workoutPlan!;
          final difficulty = Difficulty.fromValue(plan.difficulty);
          final difficultyColor = _difficultyColor(difficulty);
          final progressPercentange = currentPlanRecord.completedWorkouts /
              currentPlanRecord.totalWorkouts;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Active Workout Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    context.push('/workout-plans/current');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                                _difficultyLabel(difficulty),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: difficultyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  '${progressPercentange.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progressPercentange / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currentPlanRecord.completedWorkouts} of ${currentPlanRecord.totalWorkouts} workouts',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (currentPlanRecord.todaysWorkouts.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Today's Workout",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        currentPlanRecord
                                            .todaysWorkouts.first.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    context.push(
                                      '/workouts/${currentPlanRecord.todaysWorkouts.first.id}/active',
                                    );
                                  },
                                  tooltip: 'Start Workout',
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            context.push('/workout-plans/current');
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('View Plan Details'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
