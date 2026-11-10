// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../../../data/utils/enums.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/action_buttons.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../widgets/details/empty_sets_card.dart';
import '../widgets/details/workout_header_card.dart';
import '../widgets/details/workout_set_card.dart';
import '../../core/screens/loading_screen.dart';
import './workout_history_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  static const name = "workout-detail";

  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
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
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous.selectedWorkout != current.selectedWorkout &&
          previous.isLoading != current.isLoading,
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
          return const LoadingScreen(
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
            padding: EdgeInsets.all(sizes.viewPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Header
                WorkoutHeaderCard(
                  sizes: sizes,
                  workoutDto: workout,
                  actionButtonPress: () {
                    context.read<WorkoutCubit>().updateWorkoutFavorite(
                      workout.id,
                      !workout.isFavorite,
                    );
                  },
                ),
                SizedBox(height: sizes.spacing * 1.25),
                // Workout Sets
                Text(
                  'Sets',
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                if (workout.sets == null || workout.sets!.isEmpty)
                  EmptySetsCard(sizes: sizes)
                else
                  ...workoutState.selectedWorkout!.sets!.asMap().entries.map((
                    entry,
                  ) {
                    return WorkoutSetCard(
                      theme: theme,
                      isDarkTheme: isDarkTheme,
                      sizes: sizes,
                      set: entry.value,
                      setNumber: entry.key + 1,
                    );
                  }),
                SizedBox(height: sizes.spacing),
                ActionButtons(
                  isLoading: workoutState.isLoading,
                  theme: theme,
                  sizes: sizes,
                  showMutationBtns: workout.createdBy == CreatedBy.user,
                  onStart: () => context.push("/workouts/${workout.id}/active"),
                  startLabel: 'Start Workout',
                  onEdit: () => context.push('/workouts/${workout.id}/edit'),
                  onHistory: () => context.push(
                    WorkoutHistoryScreen.location(
                      workoutId: workout.id,
                      version: workout.version,
                    ),
                  ),
                  historyLabel: 'History',
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Delete Workout',
                        content: 'Are you sure you want to delete this workout? This action cannot be undone.',
                        confirmLabel: 'Delete',
                        isDestructive: true,
                        onConfirm: () {
                          context.read<WorkoutCubit>().deleteWorkout(
                            widget.workoutId,
                          );
                          context.pop();
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: sizes.spacing),
              ],
            ),
          ),
        );
      },
    );
  }
}
