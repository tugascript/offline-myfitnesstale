import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/states/workout_state.dart';
import '../../../cubits/workout_cubit.dart';
import '../../../models/enums.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import 'workout_base_form.dart';

class CreateWorkoutDialog extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const CreateWorkoutDialog({
    super.key,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: BeveledRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      insetPadding: EdgeInsets.all(sizes.margins),
      child: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: sizes.padding * 2,
                horizontal: sizes.padding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Create Workout".toUpperCase(),
                    style: TextStyle(
                      fontSize: sizes.titleFountSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: sizes.spacing),
                  WorkoutBaseForm(
                    theme: theme,
                    sizes: sizes,
                    isLoading: state.isLoading,
                    submitLabel: "Start Editing",
                    initialName: "",
                    initialIsFavorite: false,
                    initialDifficulty: Difficulty.beginner,
                    onSubmit: ({
                      required String name,
                      required bool isFavorite,
                      required Difficulty difficulty,
                      String? description,
                    }) async {
                      await context.read<WorkoutCubit>().createWorkout(
                            name: name,
                            isFavorite: isFavorite,
                            difficulty: difficulty,
                            description: description,
                          );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        if (state.selectedWorkout != null) {
                          // Fix getting workout
                          context.push(
                            "/workouts/${state.selectedWorkout!.id}",
                          );
                        }
                      }
                    },
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
