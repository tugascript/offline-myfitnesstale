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

import '../../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/modal_search/modal_search_form.dart';
import '../../../../workouts/view_models/states/workout_state.dart';
import '../../../../workouts/view_models/workout_cubit.dart';
import './workout_plan_workout_search_list.dart';

class WorkoutPlanWorkoutSearchModal extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final void Function(WorkoutDto workout) onWorkoutSelected;

  const WorkoutPlanWorkoutSearchModal({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.onWorkoutSelected,
  });

  @override
  State<WorkoutPlanWorkoutSearchModal> createState() =>
      _WorkoutPlanWorkoutSearchModalState();
}

class _WorkoutPlanWorkoutSearchModalState
    extends State<WorkoutPlanWorkoutSearchModal> {
  @override
  void initState() {
    super.initState();
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
        child: BlocConsumer<WorkoutCubit, WorkoutState>(
          listenWhen: (previous, current) =>
              previous.isLoading && !current.isLoading,
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error?.description ?? 'Error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                ModalSearchForm(
                  theme: theme,
                  sizes: widget.sizes,
                  isLoading: state.isLoading,
                  initialName: '',
                  initialMuscleGroup: null,
                  initialIsFavorite: false,
                  onSubmit:
                      ({
                        required String name,
                        required MuscleGroup? muscleGroup,
                        required bool isFavorite,
                      }) {
                        context.read<WorkoutCubit>().getSelectionWorkouts(
                          name: name,
                          muscleGroup: muscleGroup,
                          isFavorite: isFavorite,
                        );
                      },
                ),
                SizedBox(height: widget.sizes.spacing),
                Expanded(
                  child: WorkoutPlanWorkoutSearchList(
                    sizes: widget.sizes,
                    isLoading: state.isLoading || widget.isLoading,
                    workouts: state.workoutSelection,
                    onWorkoutSelected: widget.onWorkoutSelected,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
