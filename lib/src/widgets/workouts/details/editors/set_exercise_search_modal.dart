import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/exercise_cubit.dart';
import '../../../../cubits/states/exercise_state.dart';
import '../../../../models/enums.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import 'set_exercise_search_form.dart';
import 'set_exercise_search_list.dart';

class SetExerciseSearchModal extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final void Function(int id, String name) onExerciseSelected;

  const SetExerciseSearchModal({
    super.key,
    required this.sizes,
    required this.onExerciseSelected,
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
      child: Padding(
        padding: EdgeInsets.all(sizes.padding / 2),
        child: BlocConsumer<ExerciseCubit, ExerciseState>(
          listenWhen: (previous, current) =>
              previous.isLoading && !current.isLoading,
          builder: (context, state) {
            return Column(
              children: [
                SetExerciseSearchForm(
                  theme: theme,
                  sizes: sizes,
                  isLoading: state.isLoading,
                  initialName: '',
                  initialMuscleGroup: null,
                  initialIsFavorite: false,
                  onSubmit: ({
                    required String name,
                    required MuscleGroup? muscleGroup,
                    required bool isFavorite,
                  }) {
                    context.read<ExerciseCubit>().getSelectionExercises(
                          name: name,
                          muscleGroup: muscleGroup,
                          isFavorite: isFavorite,
                        );
                  },
                ),
                SizedBox(
                  height: sizes.spacing,
                ),
                Expanded(
                  child: SetExerciseSearchList(
                    sizes: sizes,
                    isLoading: state.isLoading,
                    exercises: state.exerciseSelection,
                    onExerciseSelected: onExerciseSelected,
                  ),
                ),
              ],
            );
          },
          listener: (context, state) {
            if (state.isLoading) {
              return;
            }

            if (state.exerciseSelection.isNotEmpty && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!.description)),
              );
            }
          },
        ),
      ),
    );
  }
}
