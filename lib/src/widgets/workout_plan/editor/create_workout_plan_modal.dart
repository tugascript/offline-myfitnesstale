import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/states/workout_plan_state.dart';
import '../../../cubits/workout_plan_cubit.dart';
import '../../../models/enums.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_modal.dart';
import 'workout_plan_base_form.dart';

class CreateWorkoutPlanModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const CreateWorkoutPlanModal({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
        builder: (context, state) {
          return WorkoutPlanBaseForm(
            theme: theme,
            sizes: sizes,
            isLoading: state.isLoading,
            submitLabel: "CREATE WORKOUT PLAN",
            initialName: "",
            initialIsFavorite: false,
            initialDifficulty: Difficulty.beginner,
            initialDescription: null,
            onSubmit: ({
              required String name,
              required bool isFavorite,
              required Difficulty difficulty,
              String? description,
            }) async {
              await context.read<WorkoutPlanCubit>().createWorkoutPlan(
                    name: name,
                    isFavorite: isFavorite,
                    difficulty: difficulty,
                    description: description,
                  );
              await Future.delayed(const Duration(milliseconds: 10));

              if (context.mounted) {
                Navigator.of(context).pop();
                final cubitState = context.read<WorkoutPlanCubit>().state;
                if (cubitState.selectedWorkoutPlan != null) {
                  context.push(
                    "/workout-plans/${cubitState.selectedWorkoutPlan!.id}",
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
