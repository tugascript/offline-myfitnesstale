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

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_cardio_set_exercise_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/exercise_details.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/cardio_set_type_badge.dart';
import '../../../core/widgets/detail_number.dart';

class WorkoutCardioSetCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final WorkoutCardioSetDto set;
  final int setNumber;

  const WorkoutCardioSetCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.set,
    required this.setNumber,
  });

  String _formatTarget(WorkoutCardioSetExerciseDto exercise) {
    if (exercise.mode == CardioBaseMode.time) {
      return Converters.formatDuration(exercise.quantity);
    }

    final unit = exercise.exercise
        ?.getDetails<CardioExerciseDetails>()
        ?.unit
        .trim();
    if (unit != null && unit.isNotEmpty) {
      return '${exercise.quantity} $unit';
    }
    return '${exercise.quantity} units';
  }

  @override
  Widget build(BuildContext context) {
    final exercises = set.exercises ?? const <WorkoutCardioSetExerciseDto>[];
    final isConstantSingle =
        set.setType == CardioSetType.constant && exercises.length == 1;

    if (isConstantSingle) {
      return _buildConstantSingleCard(context, exercises.first);
    }

    return _buildStackedCard(context, exercises);
  }

  Widget _buildConstantSingleCard(
    BuildContext context,
    WorkoutCardioSetExerciseDto exercise,
  ) {
    final colors = theme.colorScheme;
    final mutedColor = colors.onSurfaceVariant;
    final targetText = _formatTarget(exercise);
    final restText = Converters.formatDuration(set.restSecs);

    return Card(
      margin: EdgeInsets.zero,
      shape: const BeveledRectangleBorder(),
      child: InkWell(
        onTap: () => context.push('/exercises/${exercise.exerciseId}'),
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DetailNumber(
                number: setNumber,
                theme: theme,
                fontSize: sizes.subtitleFontSize,
              ),
              SizedBox(width: sizes.spacing),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: sizes.halfSpacing,
                  runSpacing: sizes.quarterSpacing,
                  children: [
                    CardioSetTypeBadge(sizes: sizes, setType: set.setType),
                    Text(
                      exercise.exercise?.name ?? 'Unknown Exercise',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          exercise.mode == CardioBaseMode.time
                              ? Icons.schedule
                              : Icons.straighten,
                          size: sizes.mediumSmallFontSize,
                          color: mutedColor,
                        ),
                        Flexible(
                          child: Text(
                            ' $targetText',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: mutedColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (set.restSecs > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: sizes.mediumSmallFontSize,
                            color: mutedColor,
                          ),
                          Flexible(
                            child: Text(
                              ' $restText',
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
              ),
              SizedBox(width: sizes.halfSpacing),
              Icon(
                Icons.chevron_right,
                size: sizes.compactIconSize,
                color: mutedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedCard(
    BuildContext context,
    List<WorkoutCardioSetExerciseDto> exercises,
  ) {
    final colors = theme.colorScheme;
    final mutedColor = colors.onSurfaceVariant;
    final showStepLabels = exercises.length > 1;
    final restText = Converters.formatDuration(set.restSecs);

    return Card(
      margin: EdgeInsets.zero,
      shape: const BeveledRectangleBorder(),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DetailNumber(
                  number: setNumber,
                  theme: theme,
                  fontSize: sizes.subtitleFontSize,
                ),
                SizedBox(width: sizes.spacing),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: sizes.halfSpacing,
                    runSpacing: sizes.quarterSpacing,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: sizes.halfSpacing,
                        runSpacing: sizes.quarterSpacing,
                        children: [
                          CardioSetTypeBadge(
                            sizes: sizes,
                            setType: set.setType,
                          ),
                          if (set.setType == CardioSetType.interval)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: sizes.mediumSmallFontSize,
                                  color: mutedColor,
                                ),
                                Flexible(
                                  child: Text(
                                    ' ${set.rounds}×',
                                    style: TextStyle(
                                      fontSize: sizes.fontSize,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (set.restSecs > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: sizes.mediumSmallFontSize,
                              color: mutedColor,
                            ),
                            Flexible(
                              child: Text(
                                ' $restText',
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
                ),
              ],
            ),
            SizedBox(height: sizes.halfSpacing),
            Container(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: sizes.quarterSpacing),
            if (exercises.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: sizes.halfSpacing),
                child: Text(
                  'No exercises in this block',
                  style: TextStyle(
                    color: mutedColor,
                    fontStyle: FontStyle.italic,
                    fontSize: sizes.fontSize,
                  ),
                ),
              )
            else
              ...exercises.asMap().entries.map((entry) {
                final exIndex = entry.key;
                final exercise = entry.value;
                final label = showStepLabels ? '${exIndex + 1}' : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (exIndex > 0)
                      Container(
                        height: 1,
                        margin: EdgeInsets.symmetric(
                          vertical: sizes.quarterSpacing,
                        ),
                        color: colors.outlineVariant.withValues(alpha: 0.35),
                      ),
                    _CardioExerciseRow(
                      theme: theme,
                      sizes: sizes,
                      label: label,
                      exercise: exercise,
                      targetText: _formatTarget(exercise),
                      showExerciseRest:
                          set.setType == CardioSetType.interval &&
                          exercise.restSecs > 0,
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _CardioExerciseRow extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final String? label;
  final WorkoutCardioSetExerciseDto exercise;
  final String targetText;
  final bool showExerciseRest;

  const _CardioExerciseRow({
    required this.theme,
    required this.sizes,
    required this.label,
    required this.exercise,
    required this.targetText,
    required this.showExerciseRest,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final mutedColor = colors.onSurfaceVariant;

    return InkWell(
      onTap: () => context.push('/exercises/${exercise.exerciseId}'),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: sizes.halfSpacing,
          horizontal: sizes.quarterSpacing,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (label != null) ...[
              Container(
                width: sizes.fontSize * 1.5,
                height: sizes.fontSize * 1.5,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Text(
                  label!,
                  style: TextStyle(
                    fontSize: sizes.smallFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              SizedBox(width: sizes.halfSpacing),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: sizes.halfSpacing,
                    runSpacing: sizes.quarterSpacing,
                    children: [
                      Text(
                        exercise.exercise?.name ?? 'Unknown Exercise',
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        targetText,
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w500,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                  if (showExerciseRest) ...[
                    SizedBox(height: sizes.quarterSpacing),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: sizes.mediumSmallFontSize,
                          color: mutedColor,
                        ),
                        SizedBox(width: sizes.quarterSpacing),
                        Flexible(
                          child: Text(
                            'Rest ${Converters.formatDuration(exercise.restSecs)}',
                            style: TextStyle(
                              fontSize: sizes.smallFontSize,
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
            SizedBox(width: sizes.halfSpacing),
            Icon(
              Icons.chevron_right,
              size: sizes.compactIconSize,
              color: mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}
