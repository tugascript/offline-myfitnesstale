import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/states/workout_plan_state.dart';
import '../cubits/workout_plan_cubit.dart';
import '../models/enums.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/workout_plan/details/start_workout_plan.dart';
import '../widgets/workout_plan/details/workout_plan_week_card.dart';
import 'error_view.dart';
import 'loading_view.dart';

class WorkoutPlanDetailView extends StatelessWidget {
  static const String routeName = "/workout-plans/:id";
  static const String name = 'workout-plan-detail';

  final int workoutPlanId;

  const WorkoutPlanDetailView({
    super.key,
    required this.workoutPlanId,
  });

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
    return BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
      builder: (context, state) {
        if (state.isLoading) {
          return LoadingView();
        }

        if (state.error != null && state.selectedWorkoutPlan == null) {
          return ErrorView(
            description: state.error!.description,
            type: state.error!.type,
          );
        }

        final plan = state.selectedWorkoutPlan!;
        final difficultyColor = _difficultyColor(plan.difficulty);

        return ResponsiveScaffold(
          title: plan.name,
          body: SingleChildScrollView(
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
                        if (plan.description != null &&
                            plan.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            plan.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${plan.totalWeeks} ${plan.totalWeeks == 1 ? 'week' : 'weeks'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StartWorkoutPlan(workoutPlanId: plan.id),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Weekly Breakdown
                Text(
                  'Weekly Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                ...(plan.weeks?.map(
                      (week) => WorkoutPlanWeekCard(week: week),
                    ) ??
                    []),
              ],
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!.description),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (state.selectedWorkoutPlan == null ||
            state.selectedWorkoutPlan!.id != workoutPlanId) {
          context.read<WorkoutPlanCubit>().getWorkoutPlan(workoutPlanId);
        }
      },
    );
  }
}
