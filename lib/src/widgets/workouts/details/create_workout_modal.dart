import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/nullable.dart';
import '../../../cubits/states/workout_state.dart';
import '../../../cubits/workout_cubit.dart';
import '../../../models/enums.dart';
import '../../../ui/core/sizes/data_display_sizes.dart';
import '../../layout/app_modal.dart';
import 'workout_base_form.dart';

class CreateWorkoutDialog extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const CreateWorkoutDialog({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          return WorkoutBaseForm(
            theme: theme,
            sizes: sizes,
            isLoading: state.isLoading,
            submitLabel: "CREATE WORKOUT",
            initialName: "",
            initialIsFavorite: false,
            initialDifficulty: Difficulty.beginner,
            initialEditorType: EditorType.basic,
            onSubmit:
                ({
                  required String name,
                  required bool isFavorite,
                  required Difficulty difficulty,
                  required EditorType editorType,
                  String? description,
                }) async {
                  await context.read<WorkoutCubit>().createWorkout(
                    WorkoutInput(
                      name: name,
                      isFavorite: isFavorite,
                      difficulty: difficulty,
                      editorType: editorType,
                      description: Nullable(description),
                    ),
                  );
                  await Future.delayed(const Duration(milliseconds: 10));

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    final cubitState = context.read<WorkoutCubit>().state;
                    if (cubitState.selectedWorkout != null) {
                      context.push(
                        "/workouts/${cubitState.selectedWorkout!.id}",
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
