import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/states/workout_plan_record_state.dart';
import '../../../cubits/workout_plan_record_cubit.dart';

class StartWorkoutPlan extends StatelessWidget {
  final int workoutPlanId;

  const StartWorkoutPlan({
    super.key,
    required this.workoutPlanId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
      builder: (context, state) {
        if (state.currentPlanRecord.workoutPlan == null ||
            state.currentPlanRecord.workoutPlan!.id != workoutPlanId) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isLoading
                  ? () {}
                  : () {
                      context
                          .read<WorkoutPlanRecordCubit>()
                          .startWorkoutPlan(workoutPlanId);
                    },
              icon: const Icon(Icons.play_arrow),
              label: Text(state.isLoading ? "Loading..." : "Start Plan"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'This plan is currently active',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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

        if (state.currentPlanRecord.workoutPlan == null) {
          context.read<WorkoutPlanRecordCubit>().getActivePlanRecord();
        }
      },
    );
  }
}
