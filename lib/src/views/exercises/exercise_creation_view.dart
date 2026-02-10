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

class ExerciseCreationView extends StatelessWidget {
  static const routeName = '/exercises/create';
  static const name = 'exercise_creation';

  const ExerciseCreationView({super.key});

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      title: "Create Exercise",
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: breakPoint.height / 18),
          BlocConsumer<ExerciseCubit, ExerciseState>(
            listenWhen: (previous, current) {
              return previous.selectedExercise != current.selectedExercise;
            },
            listener: (context, state) {
              if (state.isLoading) {
                return;
              }

              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!.description)),
                );
              }

              if (state.selectedExercise != null) {
                context.go(
                  ExerciseDetailView.routeName.replaceFirst(
                    ":id",
                    state.selectedExercise!.id.toString(),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.padding,
                    vertical: sizes.padding * 2,
                  ),
                  child: ExerciseForm(
                    theme: theme,
                    sizes: sizes,
                    submitLabel: "CREATE",
                    isLoading: state.isLoading,
                    initialName: '',
                    initialDescription: null,
                    initialMuscleGroup: null,
                    initialPrimaryMuscles: {},
                    initialSecondaryMuscles: {},
                    initialEquipmentIds: {},
                    initialDifficulty: null,
                    initialIsFavorite: false,
                    onSubmit: ({
                      String? description,
                      Difficulty? difficulty,
                      required Set<int> equipmentIds,
                      required bool isFavorite,
                      required MuscleGroup muscleGroup,
                      required String name,
                      required Set<Muscle> primaryMuscles,
                      required Set<Muscle> secondaryMuscles,
                    }) {
                      context.read<ExerciseCubit>().createExercise(
                            name: name,
                            description: description,
                            muscleGroup: muscleGroup,
                            primaryMuscles: primaryMuscles,
                            secondaryMuscles: secondaryMuscles,
                            equipmentIds: equipmentIds,
                            difficulty: difficulty,
                            isFavorite: isFavorite,
                          );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
