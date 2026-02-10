import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/mutation_button.dart';
import '../../widgets/exercises/details/exercise_header_card.dart';
import '../../widgets/layout/app_primary_button.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../loading_view.dart';
import 'exercise_update_view.dart';

class ExerciseDetailView extends StatefulWidget {
  static const routeName = "/exercises/:id";
  static const name = "exercise-detail";

  final int exerciseId;

  const ExerciseDetailView({
    super.key,
    required this.exerciseId,
  });

  @override
  State<ExerciseDetailView> createState() => _ExerciseDetailViewState();
}

class _ExerciseDetailViewState extends State<ExerciseDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseCubit>().getExercise(widget.exerciseId);
  }

  void _toggleFavorite(bool isFavorite) {
    context.read<ExerciseCubit>().updateExerciseFavorite(
          widget.exerciseId,
          !isFavorite,
        );
  }

  void _deleteExercise() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Exercise',
        content:
            'Are you sure you want to delete this exercise? This action cannot be undone.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          context.read<ExerciseCubit>().deleteExercise(widget.exerciseId);
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

    return BlocConsumer<ExerciseCubit, ExerciseState>(
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
        // Navigate back if exercise was deleted
        if (state.selectedExercise == null &&
            state.exercises.isEmpty &&
            !state.isLoading &&
            state.error == null) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exercise deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, exerciseState) {
        if (exerciseState.isLoading && exerciseState.selectedExercise == null) {
          return const LoadingView(
            title: "Exercise Details",
            message: "Loading exercise details...",
          );
        }

        if (exerciseState.selectedExercise == null) {
          return AppScaffold(
            title: "Exercise Not Found",
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Exercise not found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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

        final exercise = exerciseState.selectedExercise!;

        return ResponsiveScaffold(
          title: exercise.name,
          isEntity: true,
          showBackButton: true,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizes.padding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Header
                ExerciseHeaderCard(
                  sizes: sizes,
                  exerciseDto: exercise,
                  onFavoriteToggle: () => _toggleFavorite(exercise.isFavorite),
                ),

                SizedBox(height: sizes.spacing * 1.25),

                // Video Placeholder
                if (exercise.video != null &&
                    exercise.video!.uri.isNotEmpty) ...[
                  Text(
                    'Video',
                    style: TextStyle(
                      fontSize: sizes.titleFountSize,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video: ${exercise.video!.platform.value}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.video!.uri,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sizes.spacing * 1.25),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                          theme: theme,
                          isLoading: exerciseState.isLoading,
                          sizes: sizes,
                          onPressed: () {},
                          label: 'Log Progress',
                          icon: Icons.history),
                    ),
                  ],
                ),
                if (exercise.createdBy == CreatedBy.user) ...[
                  SizedBox(height: sizes.spacing),
                  Row(
                    children: [
                      Expanded(
                        child: MutationButton(
                          isLoading: exerciseState.isLoading,
                          theme: theme,
                          sizes: sizes,
                          onPressed: () {
                            context.push(
                              ExerciseUpdateView.routeName.replaceFirst(
                                ":id",
                                exercise.id.toString(),
                              ),
                            );
                          },
                          label: 'EDIT',
                          icon: Icons.edit,
                        ),
                      ),
                      SizedBox(width: sizes.spacing),
                      Expanded(
                        child: MutationButton(
                          isLoading: exerciseState.isLoading,
                          theme: theme,
                          sizes: sizes,
                          onPressed: _deleteExercise,
                          label: 'DELETE',
                          icon: Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: sizes.spacing * 2),
              ],
            ),
          ),
        );
      },
    );
  }
}
