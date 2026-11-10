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

import '../../../../../utils/nullable.dart';
import '../../../view_models/exercise_record_cubit.dart';
import '../../../../../data/utils/json_data.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../../data/repositories/exercises/inputs/exercise_record_input.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import './exercise_record_form.dart';

class UpdateExerciseRecordCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final bool isLoading;
  final Units units;
  final ExerciseDto exercise;
  final ExerciseRecordDto record;

  final VoidCallback onClose;

  const UpdateExerciseRecordCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.onClose,
    required this.isLoading,
    required this.record,
    required this.units,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.padding,
            vertical: sizes.padding * 2,
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Update ${exercise.name} Record",
                      style: TextStyle(
                        fontSize: sizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close,
                      size: sizes.titleFontSize * 1.2,
                      color: theme.colorScheme.brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    onPressed: onClose,
                  ),
                ],
              ),
              SizedBox(height: sizes.spacing),
              ExerciseRecordForm(
                theme: theme,
                sizes: sizes,
                isLoading: isLoading,
                submitLabel: "UPDATE",
                submitIcon: Icons.save,
                units: units,
                exerciseId: exercise.id,
                initialDate: record.recordDate,
                initialWeight: record.weight,
                initialReps: record.reps,
                onSubmit:
                    ({
                      required int exerciseId,
                      required int weight,
                      required int reps,
                      required DateTime date,
                    }) async {
                      final existingPicture = record.picture;
                      final existingVideo = record.video;
                      await context
                          .read<ExerciseRecordCubit>()
                          .updateExerciseRecord(
                            record.id,
                            ExerciseRecordInput(
                              exerciseId: exerciseId,
                              weight: weight,
                              reps: reps,
                              recordDate: date,
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
                            ),
                          );
                      if (context.mounted) {
                        onClose();
                      }
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
