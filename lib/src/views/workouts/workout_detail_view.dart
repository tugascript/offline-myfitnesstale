import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/states/workout_state.dart';
import '../../cubits/workout_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/action_buttons.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workouts/details/empty_sets_card.dart';
import '../../widgets/workouts/details/workout_header_card.dart';
import '../../widgets/workouts/details/workout_set_card.dart';
import '../loading_view.dart';

class WorkoutDetailView extends StatefulWidget {
  static const name = "workout-detail";
  static const routeName = "/workouts/:id";

  final int workoutId;

  const WorkoutDetailView({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  // TODO: fix always get the workout
  @override
  void initState() {
    super.initState();
    context.read<WorkoutCubit>().getWorkout(widget.workoutId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous.selectedWorkout != current.selectedWorkout,
      listener: (context, workoutState) {
        if (workoutState.isLoading) {
          return;
        }

        if (workoutState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(workoutState.error!.description)),
          );
          return;
        }
      },
      builder: (context, workoutState) {
        if (workoutState.isLoading && workoutState.selectedWorkout == null) {
          return const LoadingView(
            title: "Workout details",
            message: "Loading workout details...",
          );
        }

        if (workoutState.selectedWorkout == null) {
          return AppScaffold(
            title: "Unknown Workout",
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    workoutState.error?.description ?? 'Workout not found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final workout = workoutState.selectedWorkout!;

        return ResponsiveScaffold(
          title: workout.name,
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizes.padding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Header
                WorkoutHeaderCard(
                  sizes: sizes,
                  workoutDto: workout,
                  actionButtonPress: () {
                    context.read<WorkoutCubit>().updateWorkout(
                          id: workout.id,
                          isFavorite: !workout.isFavorite,
                        );
                  },
                ),
                SizedBox(height: sizes.spacing * 1.25),
                // Workout Sets
                Text(
                  'Sets',
                  style: TextStyle(
                    fontSize: sizes.titleFountSize,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                if (workout.sets == null || workout.sets!.isEmpty)
                  EmptySetsCard(sizes: sizes)
                else
                  ...workoutState.selectedWorkout!.sets!
                      .asMap()
                      .entries
                      .map((entry) {
                    return WorkoutSetCard(
                      theme: theme,
                      isDarkTheme: isDarkTheme,
                      sizes: sizes,
                      set: entry.value,
                      setNumber: entry.key + 1,
                    );
                  }),
                SizedBox(height: sizes.spacing * 2),
                ActionButtons(
                    isLoading: workoutState.isLoading,
                    theme: theme,
                    sizes: sizes,
                    showMutationBtns: workout.createdBy == CreatedBy.user,
                    onStart: () => context
                        .push('/workouts/${workout.id}/active'), // TODO: fix me
                    startLabel: 'Start Workout',
                    onEdit: () => context.push('/workouts/${workout.id}/edit'),
                    onHistory: () =>
                        context.push('/workouts/${workout.id}/history'),
                    historyLabel: 'History',
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          title: 'Delete Workout',
                          content:
                              'Are you sure you want to delete this workout? This action cannot be undone.',
                          confirmLabel: 'Delete',
                          isDestructive: true,
                          onConfirm: () {
                            context
                                .read<WorkoutCubit>()
                                .deleteWorkout(widget.workoutId);
                            context.pop();
                          },
                        ),
                      );
                    }),
                SizedBox(height: sizes.spacing),
              ],
            ),
          ),
        );
      },
    );
  }
}
