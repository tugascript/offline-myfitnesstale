import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../cubits/exercise_record_cubit.dart';
import '../../../models/enums.dart';
import '../../../services/dtos/exercise_dto.dart';
import '../../../services/dtos/exercise_record_dto.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/formatters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/confirmation_dialog.dart';
import 'editors/edit_exercise_record_modal.dart';
import 'exercise_record_reps.dart';

class ExerciseRecordsList extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;

  final ExerciseDto exercise;
  final bool isLoading;
  final List<ExerciseRecordDto> records;

  const ExerciseRecordsList({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.exercise,
    required this.isLoading,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = theme.colorScheme.brightness == Brightness.dark;
    final greyColor = isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600;
    final redColor = isDarkTheme ? Colors.red.shade400 : Colors.red.shade600;
    return Skeletonizer(
      enabled: isLoading && records.isEmpty,
      child: ListView.builder(
        itemCount: isLoading && records.isEmpty ? 3 : records.length,
        itemBuilder: (context, index) {
          if (isLoading && records.isEmpty) {
            return _ExerciseRecordCard(
              theme: theme,
              sizes: sizes,
              units: units,
              exercise: exercise,
              record: ExerciseRecordDto.empty(),
              greyColor: greyColor,
              redColor: redColor,
            );
          }

          final record = records[index];
          return _ExerciseRecordCard(
            theme: theme,
            sizes: sizes,
            units: units,
            exercise: exercise,
            record: record,
            greyColor: greyColor,
            redColor: redColor,
          );
        },
      ),
    );
  }
}

class _ExerciseRecordCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final ExerciseDto exercise;
  final ExerciseRecordDto record;

  final Color greyColor;
  final Color redColor;

  const _ExerciseRecordCard({
    required this.theme,
    required this.sizes,
    required this.units,
    required this.exercise,
    required this.record,
    required this.greyColor,
    required this.redColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMetric = units == Units.metric;
    final weightUnit = isMetric ? "KG" : "LBS";
    final maxStrengthValue = isMetric
        ? Converters.gramsToKg(record.maxStrength).toStringAsFixed(2)
        : Converters.gramsToLbs(record.maxStrength).toStringAsFixed(2);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(
        vertical: sizes.margins,
        horizontal: sizes.margins / 2,
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "💪",
                      style: TextStyle(fontSize: sizes.subtitleFontSize * 1.2),
                    ),
                    Text(
                      " $maxStrengthValue $weightUnit",
                      style: TextStyle(
                        fontSize: sizes.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                ExerciseRecordReps(
                  units: units,
                  fontSize: sizes.fontSize,
                  reps: record.reps,
                  weight: record.weight,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: sizes.fontSize * 1.2),
                    Text(
                      " ${Formatters.formatDate(units, record.recordDate)}",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EditExerciseRecordModal(
                            theme: theme,
                            sizes: sizes,
                            isLoading: false,
                            exercise: exercise,
                            units: units,
                            record: record,
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit,
                        size: sizes.subtitleFontSize * 1.2,
                      ),
                      color: greyColor,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                            title: "Delete Exercise Record",
                            content:
                                "Are you sure you want to delete this exercise record?",
                            confirmLabel: "Delete",
                            isDestructive: true,
                            onConfirm: () async {
                              await context
                                  .read<ExerciseRecordCubit>()
                                  .deleteExerciseRecord(record.id);
                            },
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.delete,
                        size: sizes.subtitleFontSize * 1.2,
                      ),
                      color: redColor,
                      visualDensity: VisualDensity.compact,
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
