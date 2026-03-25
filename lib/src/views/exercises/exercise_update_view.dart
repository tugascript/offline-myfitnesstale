import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/exercises/details/exercise_form.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import 'exercise_detail_view.dart';

class ExerciseUpdateView extends StatefulWidget {
  static const routeName = '/exercises/:id/update';
  static const name = 'exercise_update';

  final int exerciseId;

  const ExerciseUpdateView({
    super.key,
    required this.exerciseId,
  });

  @override
  State<ExerciseUpdateView> createState() => _ExerciseUpdateViewState();
}

class _ExerciseUpdateViewState extends State<ExerciseUpdateView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseCubit>();

    if (cubit.state.selectedExercise?.id != widget.exerciseId) {
      cubit.getExercise(widget.exerciseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

    return BlocConsumer<ExerciseCubit, ExerciseState>(
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
        final exercise = state.selectedExercise;
        return ResponsiveScaffold(
          title: exercise?.name ?? "Update Exercise",
          isEntity: true,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: breakpoints.height / 18),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.padding,
                    vertical: sizes.padding * 2,
                  ),
                  child: ExerciseForm(
                    theme: theme,
                    sizes: sizes,
                    isLoading: state.isLoading,
                    submitLabel: "UPDATE",
                    initialName: exercise?.name ?? '',
                    initialDescription: exercise?.description,
                    initialMuscleGroup: exercise?.muscleGroup,
                    initialPrimaryMuscles: exercise?.muscles.primary ?? {},
                    initialSecondaryMuscles: exercise?.muscles.secondary ?? {},
                    initialEquipmentIds:
                        exercise?.equipments?.map((e) => e.id).toSet() ?? {},
                    initialDifficulty: exercise?.difficulty,
                    initialIsFavorite: exercise?.isFavorite ?? false,
                    onSubmit: ({
                      String? description,
                      Difficulty? difficulty,
                      required Set<int> equipmentIds,
                      required bool isFavorite,
                      required MuscleGroup muscleGroup,
                      required String name,
                      required Set<Muscle> primaryMuscles,
                      required Set<Muscle> secondaryMuscles,
                    }) async {
                      await context.read<ExerciseCubit>().updateExercise(
                            id: widget.exerciseId,
                            name: name,
                            description: description,
                            muscleGroup: muscleGroup,
                            primaryMuscles: primaryMuscles,
                            secondaryMuscles: secondaryMuscles,
                            equipmentIds: equipmentIds,
                            difficulty: difficulty,
                            isFavorite: isFavorite,
                          );

                      if (context.mounted) {
                        if (state.error == null) {
                          if (context.canPop()) {
                            context.pop();
                            return;
                          }

                          context.go(
                            ExerciseDetailView.routeName.replaceFirst(
                              ":id",
                              widget.exerciseId.toString(),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
