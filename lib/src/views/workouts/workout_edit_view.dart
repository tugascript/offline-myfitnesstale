import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/states/workout_state.dart';
import '../../cubits/workout_cubit.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/workouts/details/basic_editor/basic_editor.dart';
import '../../widgets/workouts/details/workout_header_card.dart';

class WorkoutEditView extends StatefulWidget {
  static const name = "workout_edit";
  static const routeName = "/workouts/:id/edit";

  final int workoutId; // If provided, we're editing

  const WorkoutEditView({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutEditView> createState() => _WorkoutEditViewState();
}

class _WorkoutEditViewState extends State<WorkoutEditView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutCubit>();

    if (cubit.state.selectedWorkout?.id != widget.workoutId) {
      cubit.getWorkout(widget.workoutId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);

    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final workout = state.selectedWorkout;

        if (workout == null) {
          return const AppScaffold(
            title: "Edit Workout",
            isEntity: true,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AppScaffold(
          title: workout.name,
          isEntity: true,
          body: Column(
            children: [
              WorkoutHeaderCard(
                sizes: sizes,
                workoutDto: workout,
                onFavoriteToggle: () {
                  context.read<WorkoutCubit>().updateWorkout(
                        id: workout.id,
                        isFavorite: !workout.isFavorite,
                      );
                },
              ),
              Expanded(
                child: BasicEditor(
                  workoutId: widget.workoutId,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
