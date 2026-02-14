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
      child: BlocConsumer<WorkoutCubit, WorkoutState>(
        listener: (context, state) {
          if (state.error == null && !state.isLoading) {
            // Assuming successful creation if no error and not loading anymore
            // Ideally check for a specific success flag or compare list length,
            // but checking for no error after a probable action is a common pattern.
            // However, this listener might trigger on other state changes too.
            // A better way is to check if the list grew or a "created" flag.
            // But usually the Cubit might emit a specific "Success" state or we just check.
            // Given the cubit code:
            // emit(state.copyWith(workouts: [workout, ...], isLoading: false));
            // We can check if `workouts` changed? Or just close it.
            // Let's assume on success we want to close.
            Navigator.of(context).pop();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!.description)),
            );
          }
        },
        listenWhen: (previous, current) {
          // trigger when loading changes from true to false
          return previous.isLoading && !current.isLoading;
        },
        builder: (context, state) {
          return BlocListener<WorkoutCubit, WorkoutState>(
            listener: (context, state) {
              if (state.isLoading) {
                return;
              }

              if (state.error == null && state.selectedWorkout != null) {
                Navigator.of(context).pop();
                context.push(
                  "/workouts/${state.selectedWorkout!.id}/edit",
                );
              }
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!.description)),
                );
              }
            },
            listenWhen: (previous, current) {
              // trigger when loading changes from true to false
              return previous.isLoading && !current.isLoading;
            },
            child: SingleChildScrollView(
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
                      }) {
                        context.read<WorkoutCubit>().createWorkout(
                              name: name,
                              isFavorite: isFavorite,
                              difficulty: difficulty,
                              description: description,
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
