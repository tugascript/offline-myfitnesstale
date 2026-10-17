import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/nullable.dart';
import '../../../../cubits/exercise_record_cubit.dart';
import '../../../../models/common.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/exercise_dto.dart';
import '../../../../services/dtos/exercise_record_dto.dart';
import '../../../../services/inputs/exercise_record_input.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_modal.dart';
import 'exercise_record_form.dart';

class EditExerciseRecordModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final bool isLoading;
  final Units units;
  final ExerciseDto exercise;
  final ExerciseRecordDto record;

  const EditExerciseRecordModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.units,
    required this.exercise,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: ExerciseRecordForm(
        theme: theme,
        sizes: sizes,
        isLoading: isLoading,
        submitLabel: "UPDATE ${exercise.name} RECORD",
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
              await context.read<ExerciseRecordCubit>().updateExerciseRecord(
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
                            source: existingPicture.source,
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
                Navigator.pop(context);
              }
            },
      ),
    );
  }
}
