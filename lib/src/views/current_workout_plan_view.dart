import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/workout_plan_record_cubit.dart';
import '../cubits/states/workout_plan_record_state.dart';
import '../models/enums.dart';
import '../widgets/layout/responsive_scaffold.dart';

class CurrentWorkoutPlanView extends StatefulWidget {
  static const routeName = '/workout-plans/current';

  const CurrentWorkoutPlanView({super.key});

  @override
  State<CurrentWorkoutPlanView> createState() => _CurrentWorkoutPlanViewState();
}

class _CurrentWorkoutPlanViewState extends State<CurrentWorkoutPlanView> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutPlanRecordCubit>().getActivePlanRecord();
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
    return ResponsiveScaffold(
      title: 'Current Plan',
      body: BlocConsumer<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error!.description}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final currentPlanRecord = state.currentPlanRecord;

          if (state.isLoading && currentPlanRecord.workoutPlan == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (currentPlanRecord.workoutPlan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a workout plan to track your progress',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/workout-plans');
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Browse Plans'),
                  ),
                ],
              ),
            );
          }

          final plan = currentPlanRecord.workoutPlan!;
          final difficultyColor = _difficultyColor(plan.difficulty);
          final progressPercentage = (currentPlanRecord.totalWorkouts > 0)
              ? (currentPlanRecord.completedWorkouts /
                      currentPlanRecord.totalWorkouts) *
                  100
              : 0.0;

          return RefreshIndicator(
            onRefresh: () async {
              await context
                  .read<WorkoutPlanRecordCubit>()
                  .getActivePlanRecord();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Header
                  Card(
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
                                    fontSize: 24,
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
                                  color: difficultyColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: difficultyColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _difficultyLabel(plan.difficulty),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: difficultyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    '${progressPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progressPercentage / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${currentPlanRecord.completedWorkouts} of ${currentPlanRecord.totalWorkouts} workouts completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Today's Workout
                  Text(
                    "Today's Workout",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (currentPlanRecord.todaysWorkouts.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No workout scheduled for today',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...currentPlanRecord.todaysWorkouts.map((workout) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            child: Icon(
                              Icons.fitness_center,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(
                            workout.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Tap to view details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/workouts/${workout.id}/active');
                            },
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Start'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          onTap: () {
                            context.push('/workouts/${workout.id}');
                          },
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/workout-plans/current/progress');
                          },
                          icon: const Icon(Icons.trending_up),
                          label: const Text('View Progress'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/workout-plans/${plan.id}');
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Plan Details'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
