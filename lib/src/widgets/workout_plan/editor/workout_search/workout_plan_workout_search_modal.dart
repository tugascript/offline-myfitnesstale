import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/states/workout_state.dart';
import '../../../../cubits/workout_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/modal_search/modal_search_form.dart';
import 'workout_plan_workout_search_list.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkoutCubit>().getWorkouts(
            name: '',
            difficulty: null,
            muscleGroup: null,
            limit: 20,
            offset: 0,
            isFavorite: false,
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
                  onSubmit: ({
                    required String name,
                    required MuscleGroup? muscleGroup,
                    required bool isFavorite,
                  }) {
                    context.read<WorkoutCubit>().getWorkouts(
                          name: name,
                          muscleGroup: muscleGroup,
                          limit: 20,
                          offset: 0,
                          isFavorite: isFavorite,
                        );
                  },
                ),
                SizedBox(height: widget.sizes.spacing),
                Expanded(
                  child: WorkoutPlanWorkoutSearchList(
                    sizes: widget.sizes,
                    isLoading: state.isLoading || widget.isLoading,
                    workouts: state.workouts,
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
