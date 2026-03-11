import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/exercise_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/exercise_dto.dart';
import '../../../../services/dtos/exercise_record_dto.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/formatters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/confirmation_dialog.dart';
import '../../../common/mutation_buttons.dart';
import '../../../layout/app_modal.dart';
import '../exercise_record_reps.dart';
import 'edit_exercise_record_modal.dart';

class ExerciseRecordPointDetailsModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final ExerciseDto exercise;
  final ExerciseRecordDto record;
  final bool isLoading;

  const ExerciseRecordPointDetailsModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.exercise,
    required this.record,
    required this.isLoading,
  });

  static Future<void> show({
    required BuildContext context,
    required ThemeData theme,
    required DataDisplaySizesList sizes,
    required Units units,
    required ExerciseRecordDto record,
    required ExerciseDto exercise,
    required bool isLoading,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ExerciseRecordPointDetailsModal(
        theme: theme,
        sizes: sizes,
        isLoading: isLoading,
        units: units,
        record: record,
        exercise: exercise,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMetric = units == Units.metric;
    final weightUnit = isMetric ? "KG" : "LBS";
    final maxStrengthValue = isMetric
        ? Converters.gramsToKg(record.maxStrength).toStringAsFixed(2)
        : Converters.gramsToLbs(record.maxStrength).toStringAsFixed(2);

    return AppModal(
      theme: theme,
      sizes: sizes,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${exercise.name} Record",
            style: TextStyle(
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: sizes.spacing),
          Row(
            children: [
              Text(
                "💪",
                style: TextStyle(fontSize: sizes.fontSize * 1.2),
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
          SizedBox(height: sizes.spacing),
          ExerciseRecordReps(
            units: units,
            fontSize: sizes.fontSize,
            reps: record.reps,
            weight: record.weight,
          ),
          SizedBox(height: sizes.spacing),
          Row(
            children: [
              Icon(Icons.calendar_today, size: sizes.subtitleFontSize * 1.2),
              Text(
                " ${Formatters.formatDate(units, record.recordDate)}",
                style: TextStyle(
                  fontSize: sizes.fontSize,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.spacing),
          MutationButtons(
            padding: 0,
            theme: theme,
            sizes: sizes,
            isLoading: isLoading,
            onEdit: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => EditExerciseRecordModal(
                  theme: theme,
                  sizes: sizes,
                  isLoading: isLoading,
                  units: units,
                  exercise: exercise,
                  record: record,
                ),
              );
            },
            onDelete: () {
              Navigator.of(context).pop();
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
          ),
        ],
      ),
    );
  }
}
