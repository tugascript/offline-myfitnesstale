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

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../data/repositories/exercises/inputs/exercise_input.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/exercise_details.dart';
import '../../../../data/utils/json_data.dart';
import '../../../../utils/nullable.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_modal.dart';
import '../../view_models/exercise_cubit.dart';
import '../../view_models/states/exercise_state.dart';
import './exercise_form.dart';

class EditExerciseModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final ExerciseDto exercise;

  const EditExerciseModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final strengthDetails = exercise.getDetails<StrengthExerciseDetails>();
    final cardioDetails = exercise.getDetails<CardioExerciseDetails>();

    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<ExerciseCubit, ExerciseState>(
        builder: (context, state) => ExerciseForm(
          theme: theme,
          sizes: sizes,
          isLoading: state.isLoading,
          submitLabel: "UPDATE EXERCISE",
          submitIcon: Icons.save,
          initialType: exercise.type,
          allowTypeSelection: false,
          initialName: exercise.name,
          initialDescription: exercise.description.isEmpty
              ? null
              : exercise.description,
          initialVideoUrl: exercise.video?.platform == VideoPlatform.youtube
              ? exercise.video!.uri
              : null,
          initialMuscleGroup: strengthDetails?.muscleGroup,
          initialPrimaryMuscles: strengthDetails?.muscles.primary ?? const {},
          initialSecondaryMuscles:
              strengthDetails?.muscles.secondary ?? const {},
          initialEquipmentIds:
              exercise.equipments?.map((e) => e.id).toSet() ?? const {},
          initialDifficulty: exercise.difficulty,
          initialWeightProgress:
              strengthDetails?.weightProgress ??
              ExerciseWeightProgress.positive,
          initialCardioBaseMode:
              cardioDetails?.defaultMode ?? CardioBaseMode.time,
          initialCardioUnitType:
              cardioDetails?.unitType ?? CardioUnitType.distance,
          initialCardioUnit: cardioDetails?.unit ?? '',
          initialIsFavorite: exercise.isFavorite,
          onSubmit:
              ({
                String? description,
                String? videoUrl,
                Difficulty? difficulty,
                required ExerciseDetails details,
                required Set<int> equipmentIds,
                required bool isFavorite,
                required String name,
              }) async {
                final existingPicture = exercise.picture;
                final existingVideo = exercise.video;
                final cubit = context.read<ExerciseCubit>();
                await cubit.updateExercise(
                  exercise.id,
                  ExerciseInput(
                    name: name,
                    description: Nullable(description),
                    details: details,
                    picture: Nullable(
                      existingPicture != null
                          ? PictureData(
                              uri: existingPicture.uri,
                              storage: existingPicture.storage,
                            )
                          : null,
                    ),
                    video: Nullable(
                      videoUrl != null
                          ? VideoData(
                              uri: videoUrl,
                              platform: VideoPlatform.youtube,
                            )
                          : (existingVideo != null &&
                                    existingVideo.platform !=
                                        VideoPlatform.youtube
                                ? VideoData(
                                    uri: existingVideo.uri,
                                    platform: existingVideo.platform,
                                  )
                                : null),
                    ),
                    equipmentIds: equipmentIds,
                    difficulty: Nullable(difficulty),
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
