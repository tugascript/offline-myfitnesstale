import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/entitlement_cubit.dart';
import '../../../cubits/states/workout_state.dart';
import '../../../cubits/workout_cubit.dart';
import '../../../models/enums.dart';
import '../../../services/entitlement_guard.dart';
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
          final entitlementState = context.watch<EntitlementCubit>().state;
          final canUsePremiumEditor =
              EntitlementGuard.canUsePremium(entitlementState.snapshot);
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: sizes.padding * 2,
                horizontal: sizes.padding,
              ),
              child: WorkoutBaseForm(
                theme: theme,
                sizes: sizes,
                isLoading: state.isLoading,
                submitLabel: "CREATE WORKOUT",
                initialName: "",
                initialIsFavorite: false,
                initialDifficulty: Difficulty.beginner,
                initialEditorType: EditorType.basic,
                canUsePremiumEditor: canUsePremiumEditor,
                onSubmit: ({
                  required String name,
                  required bool isFavorite,
                  required Difficulty difficulty,
                  required EditorType editorType,
                  String? description,
                }) async {
                  await context.read<WorkoutCubit>().createWorkout(
                        name: name,
                        isFavorite: isFavorite,
                        difficulty: difficulty,
                        editorType: editorType,
                        description: description,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
