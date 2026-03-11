import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/exercise_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/exercise_dto.dart';
import '../../../../services/dtos/exercise_record_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import 'exercise_record_form.dart';

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
                onSubmit: ({
                  required int exerciseId,
                  required int weight,
                  required int reps,
                  required DateTime date,
                }) async {
                  await context
                      .read<ExerciseRecordCubit>()
                      .updateExerciseRecord(
                        id: record.id,
                        weight: weight,
                        reps: reps,
                        date: date,
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
