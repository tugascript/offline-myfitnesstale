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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/exercises/inputs/exercise_input.dart';
import '../../../data/utils/enums.dart';
import '../../../data/utils/json_data.dart';
import '../../../routing/routes.dart';
import '../../../utils/nullable.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/details/exercise_form.dart';

class ExerciseUpdateScreen extends StatefulWidget {
  static const name = 'exercise_update';

  final int exerciseId;

  const ExerciseUpdateScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseUpdateScreen> createState() => _ExerciseUpdateScreenState();
}

class _ExerciseUpdateScreenState extends State<ExerciseUpdateScreen> {
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
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

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
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: Column(
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
                      initialSecondaryMuscles:
                          exercise?.muscles.secondary ?? {},
                      initialEquipmentIds:
                          exercise?.equipments?.map((e) => e.id).toSet() ?? {},
                      initialDifficulty: exercise?.difficulty,
                      initialIsFavorite: exercise?.isFavorite ?? false,
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
                          }) async {
                            final existingPicture = exercise?.picture;
                            final existingVideo = exercise?.video;
                            await context.read<ExerciseCubit>().updateExercise(
                              widget.exerciseId,
                              ExerciseInput(
                                name: name,
                                description: Nullable(description),
                                muscleGroup: muscleGroup,
                                muscles: TargetMuscles(
                                  primary: primaryMuscles,
                                  secondary: secondaryMuscles,
                                ),
                                picture: Nullable(
                                  existingPicture != null
                                      ? PictureData(
                                          uri: existingPicture.uri,
                                          storage: existingPicture.storage,
                                        )
                                      : null,
                                ),
                                video: Nullable(
                                  existingVideo != null
                                      ? VideoData(
                                          uri: existingVideo.uri,
                                          platform: existingVideo.platform,
                                        )
                                      : null,
                                ),
                                equipmentIds: equipmentIds,
                                difficulty: Nullable(difficulty),
                                isFavorite: isFavorite,
                              ),
                            );

                            if (context.mounted) {
                              if (state.error == null) {
                                if (context.canPop()) {
                                  context.pop();
                                  return;
                                }

                                context.go(
                                  Routes.exerciseDetail.name.replaceFirst(
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
          ),
        );
      },
    );
  }
}
