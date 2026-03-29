import 'package:flutter/material.dart';

import '../../../../../models/enums.dart';
import '../../../../../services/dtos/workout_set_dto.dart';
import '../../../../../services/dtos/workout_set_exercise_record_dto.dart';
import '../../../../../services/dtos/workout_set_record_dto.dart';
import '../../../../../utilities/converters.dart';
import '../../../../../utilities/formatters.dart';
import '../../../../../utilities/sizes/data_display_sizes.dart';
import '../../../../common/base_set_data.dart';
import '../../../../common/detail_number.dart';

class WorkoutRecordSetGroup extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final Units units;

  final WorkoutSetDto workoutSet;
  final List<WorkoutSetRecordDto> setRecords;

  const WorkoutRecordSetGroup({
    super.key,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.units,
    required this.workoutSet,
    required this.setRecords,
  });

  @override
  Widget build(BuildContext context) {
    final iconGreyColor =
        isDarkTheme ? Colors.grey.shade200 : Colors.grey.shade800;
    final iconLightGreyColor =
        isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: sizes.margins / 2,
      ),
      child: ExpansionTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        title: BaseSetData(
          sizes: sizes,
          theme: theme,
          workoutsColor: iconGreyColor,
          restTimeColor: iconLightGreyColor,
          workoutSet: workoutSet,
        ),
        children: [
          for (final setRecord in setRecords)
            _WorkoutRecordSet(
              sizes: sizes,
              theme: theme,
              isDarkTheme: isDarkTheme,
              units: units,
              greyColor: iconLightGreyColor,
              darkGreyColor: iconGreyColor,
              setRecord: setRecord,
            ),
        ],
      ),
    );
  }
}

class _WorkoutRecordSet extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final Units units;
  final Color greyColor;
  final Color darkGreyColor;
  final WorkoutSetRecordDto setRecord;

  const _WorkoutRecordSet({
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.units,
    required this.setRecord,
    required this.greyColor,
    required this.darkGreyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: sizes.spacing / 2,
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            DetailNumber(
              number: setRecord.setNumber,
              theme: theme,
              fontSize: sizes.subtitleFontSize,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: sizes.subtitleFontSize * 1.2,
                  color: greyColor,
                ),
                Text(
                  ' ${Formatters.formatDate(units, setRecord.startedAt)}',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    color: greyColor,
                  ),
                ),
              ],
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final setExerciseRecord
                in setRecord.setExerciseRecords ?? []) ...[
              _WorkoutRecordSetExercise(
                sizes: sizes,
                theme: theme,
                isDarkTheme: isDarkTheme,
                greyColor: greyColor,
                darkGreyColor: darkGreyColor,
                units: units,
                setExerciseRecord: setExerciseRecord,
              ),
              SizedBox(height: sizes.spacing / 2),
            ],
            if (setRecord.totalRestSecs != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: sizes.fontSize * 1.2,
                    color: greyColor,
                  ),
                  Text(
                    ' ${Formatters.formatDuration(setRecord.totalRestSecs!)}',
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: greyColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutRecordSetExercise extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final Units units;
  final Color greyColor;
  final Color darkGreyColor;

  final WorkoutSetExerciseRecordDto setExerciseRecord;

  const _WorkoutRecordSetExercise({
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.units,
    required this.greyColor,
    required this.darkGreyColor,
    required this.setExerciseRecord,
  });

  @override
  Widget build(BuildContext context) {
    final isMetric = units == Units.metric;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${setExerciseRecord.reps}x ',
            style: TextStyle(
              fontSize: sizes.fontSize,
              color: greyColor,
            ),
          ),
          Text(
            setExerciseRecord.exercise?.name ?? 'Unknown Exercise',
            style: TextStyle(
              fontSize: sizes.fontSize,
            ),
          ),
          Text(
            ' ${isMetric ? Converters.gramsToKg(
                setExerciseRecord.weightGrams,
              ).toStringAsFixed(2) : Converters.gramsToLbs(
                setExerciseRecord.weightGrams,
              ).toStringAsFixed(2)} ${isMetric ? 'KG' : 'LBS'}',
            style: TextStyle(
              fontSize: sizes.fontSize,
              color: darkGreyColor,
            ),
          ),
        ],
      ),
      subtitle: _WorkoutRecordDifficulty(
        sizes: sizes,
        isDarkTheme: isDarkTheme,
        difficultyType: setExerciseRecord.difficulty.type,
        difficultyValue: setExerciseRecord.difficulty.value,
      ),
    );
  }
}

class _WorkoutRecordDifficulty extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isDarkTheme;
  final WorkoutSetExerciseDifficultyType difficultyType;
  final int difficultyValue;

  const _WorkoutRecordDifficulty({
    required this.sizes,
    required this.isDarkTheme,
    required this.difficultyType,
    required this.difficultyValue,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDarkTheme ? Colors.red.shade400 : Colors.red.shade600;
    return Wrap(
      children: [
        Icon(
          Icons.bolt,
          size: sizes.fontSize * 1.2,
          color: color,
        ),
        SizedBox(width: sizes.padding / 2),
        Text(
          '$difficultyValue ${difficultyType.value}',
          style: TextStyle(
            fontSize: sizes.fontSize,
            color: color,
          ),
        ),
      ],
    );
  }
}
