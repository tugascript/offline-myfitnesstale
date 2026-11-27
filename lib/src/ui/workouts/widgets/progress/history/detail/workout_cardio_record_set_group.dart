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

import 'package:material_ui/material_ui.dart';

import '../../../../../../data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import '../../../../../../data/repositories/workouts/dtos/workout_cardio_set_exercise_record_dto.dart';
import '../../../../../../data/repositories/workouts/dtos/workout_cardio_set_record_dto.dart';
import '../../../../../../data/utils/enums.dart';
import '../../../../../../data/utils/exercise_details.dart';
import '../../../../../core/sizes/data_display_sizes.dart';
import '../../../../../core/utils/converters.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/cardio_set_type_badge.dart';
import '../../../../../core/widgets/detail_number.dart';

class WorkoutCardioRecordSetGroup extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final bool initiallyExpanded;

  final WorkoutCardioSetDto workoutCardioSet;
  final List<WorkoutCardioSetRecordDto> cardioSetRecords;

  const WorkoutCardioRecordSetGroup({
    super.key,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.initiallyExpanded,
    required this.workoutCardioSet,
    required this.cardioSetRecords,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDarkTheme
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final strongColor = isDarkTheme
        ? Colors.grey.shade200
        : Colors.grey.shade800;

    return Card(
      margin: EdgeInsets.symmetric(vertical: sizes.margins / 2),
      shape: const BeveledRectangleBorder(),
      child: ExpansionTile(
        dense: true,
        initiallyExpanded: initiallyExpanded,
        visualDensity: VisualDensity.compact,
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: sizes.halfSpacing,
          runSpacing: sizes.quarterSpacing,
          children: [
            CardioSetTypeBadge(sizes: sizes, setType: workoutCardioSet.setType),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.repeat,
                  size: sizes.fontSize * 1.1,
                  color: strongColor,
                ),
                Flexible(
                  child: Text(
                    ' ${workoutCardioSet.rounds} ${workoutCardioSet.rounds == 1 ? 'round' : 'rounds'}',
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      fontWeight: FontWeight.w600,
                      color: strongColor,
                    ),
                  ),
                ),
              ],
            ),
            if (workoutCardioSet.restSecs > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: sizes.fontSize * 1.1,
                    color: mutedColor,
                  ),
                  Flexible(
                    child: Text(
                      ' ${Converters.formatDuration(workoutCardioSet.restSecs)}',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: mutedColor,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        children: [
          for (final setRecord in cardioSetRecords)
            _WorkoutCardioRecordRound(
              sizes: sizes,
              theme: theme,
              isDarkTheme: isDarkTheme,
              mutedColor: mutedColor,
              setRecord: setRecord,
            ),
        ],
      ),
    );
  }
}

class _WorkoutCardioRecordRound extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final Color mutedColor;
  final WorkoutCardioSetRecordDto setRecord;

  const _WorkoutCardioRecordRound({
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.mutedColor,
    required this.setRecord,
  });

  @override
  Widget build(BuildContext context) {
    final exercises =
        setRecord.exerciseRecords ??
        const <WorkoutCardioSetExerciseRecordDto>[];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sizes.spacing / 2),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: DetailNumber(
          number: setRecord.roundNumber,
          theme: theme,
          fontSize: sizes.subtitleFontSize,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < exercises.length; i++) ...[
              _WorkoutCardioRecordExerciseRow(
                sizes: sizes,
                theme: theme,
                isDarkTheme: isDarkTheme,
                mutedColor: mutedColor,
                exerciseRecord: exercises[i],
              ),
              if (i < exercises.length - 1) SizedBox(height: sizes.halfSpacing),
            ],
            if (setRecord.totalRestSecs != null &&
                setRecord.totalRestSecs! > 0) ...[
              SizedBox(height: sizes.halfSpacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: sizes.fontSize * 1.1,
                    color: mutedColor,
                  ),
                  Flexible(
                    child: Text(
                      ' Round rest: ${Formatters.formatDuration(setRecord.totalRestSecs!)}',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: mutedColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutCardioRecordExerciseRow extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final Color mutedColor;
  final WorkoutCardioSetExerciseRecordDto exerciseRecord;

  const _WorkoutCardioRecordExerciseRow({
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.mutedColor,
    required this.exerciseRecord,
  });

  String _formatLoggedAmount() {
    if (exerciseRecord.mode == CardioBaseMode.time) {
      return Converters.formatDuration(exerciseRecord.durationSecs);
    }
    final unit = exerciseRecord.exercise
        ?.getDetails<CardioExerciseDetails>()
        ?.unit
        .trim();
    if (unit != null && unit.isNotEmpty) {
      return '${exerciseRecord.quantity} $unit';
    }
    return '${exerciseRecord.quantity} units';
  }

  @override
  Widget build(BuildContext context) {
    final rpeColor = isDarkTheme ? Colors.red.shade400 : Colors.red.shade600;
    final amountText = _formatLoggedAmount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: sizes.halfSpacing,
          runSpacing: sizes.quarterSpacing,
          children: [
            Text(
              amountText,
              style: TextStyle(
                fontSize: sizes.fontSize,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
            ),
            Text(
              exerciseRecord.exercise?.name ?? 'Unknown Exercise',
              style: TextStyle(
                fontSize: sizes.fontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, size: sizes.fontSize * 1.1, color: rpeColor),
                Flexible(
                  child: Text(
                    '${exerciseRecord.rpe} RPE',
                    style: TextStyle(fontSize: sizes.fontSize, color: rpeColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (exerciseRecord.mode == CardioBaseMode.units ||
            exerciseRecord.restSecs > 0) ...[
          SizedBox(height: sizes.quarterSpacing),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: sizes.spacing,
            runSpacing: sizes.quarterSpacing,
            children: [
              if (exerciseRecord.mode == CardioBaseMode.units)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: sizes.fontSize * 1.1,
                      color: mutedColor,
                    ),
                    Flexible(
                      child: Text(
                        ' ${Converters.formatDuration(exerciseRecord.durationSecs)}',
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              if (exerciseRecord.restSecs > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: sizes.fontSize * 1.1,
                      color: mutedColor,
                    ),
                    Flexible(
                      child: Text(
                        ' Rest ${Formatters.formatDuration(exerciseRecord.restSecs)}',
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}
