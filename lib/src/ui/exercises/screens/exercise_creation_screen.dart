import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/nullable.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../../../data/utils/json_data.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routing.dart';
import '../../../data/repositories/exercises/inputs/exercise_input.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../widgets/details/exercise_form.dart';

class ExerciseCreationScreen extends StatelessWidget {
  static const name = 'exercise_creation';

  const ExerciseCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      title: "Create Exercise",
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                    Routes.exerciseDetail.name.replaceFirst(
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
                      onSubmit:
                          ({
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
                              ExerciseInput(
                                name: name,
                                description: Nullable(description),
                                muscleGroup: muscleGroup,
                                muscles: TargetMuscles(
                                  primary: primaryMuscles,
                                  secondary: secondaryMuscles,
                                ),
                                equipmentIds: equipmentIds,
                                difficulty: Nullable(difficulty),
                                isFavorite: isFavorite,
                              ),
                            );
                          },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
