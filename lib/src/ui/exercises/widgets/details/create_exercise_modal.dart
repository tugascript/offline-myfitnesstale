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

import '../../../../data/repositories/exercises/inputs/exercise_input.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/json_data.dart';
import '../../../../utils/nullable.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_modal.dart';
import '../../view_models/exercise_cubit.dart';
import '../../view_models/states/exercise_state.dart';
import './exercise_form.dart';

class CreateExerciseModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const CreateExerciseModal({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<ExerciseCubit, ExerciseState>(
        builder: (context, state) => ExerciseForm(
          theme: theme,
          sizes: sizes,
          isLoading: state.isLoading,
          submitLabel: "CREATE EXERCISE",
          initialName: '',
          initialDescription: null,
          initialVideoUrl: null,
          initialMuscleGroup: null,
          initialPrimaryMuscles: const {},
          initialSecondaryMuscles: const {},
          initialEquipmentIds: const {},
          initialDifficulty: null,
          initialWeightProgress: ExerciseWeightProgress.positive,
          initialIsFavorite: false,
          onSubmit:
              ({
                String? description,
                String? videoUrl,
                Difficulty? difficulty,
                required ExerciseWeightProgress weightProgress,
                required Set<int> equipmentIds,
                required bool isFavorite,
                required MuscleGroup muscleGroup,
                required String name,
                required Set<Muscle> primaryMuscles,
                required Set<Muscle> secondaryMuscles,
              }) async {
                final cubit = context.read<ExerciseCubit>();
                await cubit.createExercise(
                  ExerciseInput(
                    name: name,
                    description: Nullable(description),
                    video: Nullable(
                      videoUrl != null
                          ? VideoData(
                              uri: videoUrl,
                              platform: VideoPlatform.youtube,
                            )
                          : null,
                    ),
                    muscleGroup: muscleGroup,
                    muscles: TargetMuscles(
                      primary: primaryMuscles,
                      secondary: secondaryMuscles,
                    ),
                    equipmentIds: equipmentIds,
                    difficulty: Nullable(difficulty),
                    weightProgress: weightProgress,
                    isFavorite: isFavorite,
                  ),
                );
                if (context.mounted && cubit.state.error == null) {
                  Navigator.of(context).pop();
                }
              },
        ),
      ),
    );
  }
}
