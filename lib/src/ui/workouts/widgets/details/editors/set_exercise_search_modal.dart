// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/modal_search/modal_search_form.dart';
import '../../../../exercises/view_models/exercise_cubit.dart';
import '../../../../exercises/view_models/states/exercise_state.dart';
import './set_exercise_search_list.dart';

class SetExerciseSearchModal extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final MuscleGroup? initialMuscleGroup;
  final ValueChanged<ExerciseDto> onExerciseSelected;

  const SetExerciseSearchModal({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.onExerciseSelected,
    this.initialMuscleGroup,
  });

  @override
  State<SetExerciseSearchModal> createState() => _SetExerciseSearchModalState();
}

class _SetExerciseSearchModalState extends State<SetExerciseSearchModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ExerciseCubit>().getSelectionExercises(
        muscleGroup: widget.initialMuscleGroup,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: BeveledRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      insetPadding: EdgeInsets.all(widget.sizes.margins),
      child: Padding(
        padding: EdgeInsets.all(widget.sizes.padding / 2),
        child: BlocConsumer<ExerciseCubit, ExerciseState>(
          listenWhen: (previous, current) =>
              previous.isLoading && !current.isLoading,
          builder: (context, state) {
            return Column(
              children: [
                ModalSearchForm(
                  theme: theme,
                  sizes: widget.sizes,
                  isLoading: state.isLoading,
                  initialName: '',
                  initialMuscleGroup: widget.initialMuscleGroup,
                  initialIsFavorite: false,
                  onSubmit:
                      ({
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
                SizedBox(height: widget.sizes.spacing),
                Expanded(
                  child: SetExerciseSearchList(
                    sizes: widget.sizes,
                    isLoading: state.isLoading || widget.isLoading,
                    exercises: state.exerciseSelection,
                    onExerciseSelected: widget.onExerciseSelected,
                  ),
                ),
              ],
            );
          },
          listener: (context, state) {
            if (state.isLoading) {
              return;
            }

            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.error?.description ?? "Something went wrong",
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
