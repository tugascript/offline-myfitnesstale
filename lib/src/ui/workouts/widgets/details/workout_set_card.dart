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

import '../../../../data/repositories/workouts/dtos/workout_set_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_set_exercise_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/detail_number.dart';
import '../../../core/widgets/set_type_badge.dart';

class WorkoutSetCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDarkTheme;
  final DataDisplaySizesList sizes;
  final WorkoutSetDto set;
  final int setNumber;
  final bool isSelected;

  const WorkoutSetCard({
    super.key,
    required this.theme,
    required this.isDarkTheme,
    required this.sizes,
    required this.set,
    required this.setNumber,
    this.isSelected = false,
  });

  String _formatRest() {
    final baseRest = Converters.formatDuration(set.recommendedRestSecs);
    if (set.maxRestSecs != null && set.maxRestSecs! > set.recommendedRestSecs) {
      return '$baseRest-${Converters.formatDuration(set.maxRestSecs!)}';
    }
    return baseRest;
  }

  String _formatRounds() {
    if (set.maxSets != null && set.maxSets! > set.minSets) {
      return '${set.minSets}–${set.maxSets}×';
    }
    return '${set.minSets}×';
  }

  String _formatReps(WorkoutSetExerciseDto exercise) {
    if (exercise.toMaxReps) {
      return '${exercise.minReps}-MAX reps';
    }
    if (exercise.maxReps != null && exercise.maxReps! > exercise.minReps) {
      return '${exercise.minReps}–${exercise.maxReps} reps';
    }
    return '${exercise.minReps} reps';
  }

  String _formatRoundsAndReps(WorkoutSetExerciseDto exercise) {
    final rounds = set.maxSets != null && set.maxSets! > set.minSets
        ? '${set.minSets}–${set.maxSets}'
        : '${set.minSets}';
    final reps = exercise.toMaxReps
        ? '${exercise.minReps}-MAX'
        : exercise.maxReps != null && exercise.maxReps! > exercise.minReps
        ? '${exercise.minReps}–${exercise.maxReps}'
        : '${exercise.minReps}';
    return '$rounds×$reps';
  }

  BeveledRectangleBorder _cardShape() {
    return BeveledRectangleBorder(
      side: isSelected
          ? BorderSide(color: theme.primaryColor, width: 1.5)
          : BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStandardSingle =
        set.setType == WorkoutSetType.standard &&
        (set.exercises?.length ?? 0) == 1;

    if (isStandardSingle) {
      return _buildStandardSingleCard(context, set.exercises!.first);
    }

    return _buildStackedCard(context);
  }

  Widget _buildStandardSingleCard(
    BuildContext context,
    WorkoutSetExerciseDto exercise,
  ) {
    final colors = theme.colorScheme;
    final mutedColor = colors.onSurfaceVariant;
    final roundsAndReps = _formatRoundsAndReps(exercise);
    final rest = _formatRest();
    final hasDifficulty = exercise.difficulty != null;
    final hasOptions = exercise.options != null && exercise.options!.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      shape: _cardShape(),
      child: InkWell(
        onTap: () {
          context.push('/exercises/${exercise.exerciseId}');
        },
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: sizes.halfSpacing,
                      runSpacing: sizes.quarterSpacing,
                      children: [
                        SetTypeBadge(sizes: sizes, setType: set.setType),
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
                              Icons.repeat,
                              size: sizes.mediumSmallFontSize,
                              color: mutedColor,
                            ),
                            Text(
                              ' $roundsAndReps',
                              style: TextStyle(
                                fontSize: sizes.fontSize,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: sizes.mediumSmallFontSize,
                              color: mutedColor,
                            ),
                            Text(
                              ' $rest',
                              style: TextStyle(
                                fontSize: sizes.fontSize,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (hasDifficulty || hasOptions) ...[
                      SizedBox(height: sizes.quarterSpacing),
                      _SetExerciseSubtitle(
                        setExercise: exercise,
                        sizes: sizes,
                        theme: theme,
                        isDarkTheme: isDarkTheme,
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
      ),
    );
  }

  Widget _buildStackedCard(BuildContext context) {
    final colors = theme.colorScheme;
    final mutedColor = colors.onSurfaceVariant;
    final rounds = _formatRounds();
    final rest = _formatRest();
    final exercises = set.exercises ?? const <WorkoutSetExerciseDto>[];
    final showStepLabels = exercises.length > 1;

    final isLettered =
        set.setType == WorkoutSetType.superSet ||
        set.setType == WorkoutSetType.giant ||
        set.setType == WorkoutSetType.circuit;

    return Card(
      margin: EdgeInsets.zero,
      shape: _cardShape(),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Block Header
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
                          SetTypeBadge(sizes: sizes, setType: set.setType),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.repeat,
                                size: sizes.mediumSmallFontSize,
                                color: mutedColor,
                              ),
                              Text(
                                ' $rounds',
                                style: TextStyle(
                                  fontSize: sizes.fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: sizes.mediumSmallFontSize,
                            color: mutedColor,
                          ),
                          Text(
                            ' $rest',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: mutedColor,
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
            // Stacked exercises
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
                final setExercise = entry.value;
                final label = showStepLabels
                    ? (isLettered
                          ? String.fromCharCode(65 + exIndex)
                          : '${exIndex + 1}')
                    : null;

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
                    _StackedExerciseRow(
                      theme: theme,
                      isDarkTheme: isDarkTheme,
                      sizes: sizes,
                      label: label,
                      setExercise: setExercise,
                      repsText: _formatReps(setExercise),
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

class _StackedExerciseRow extends StatelessWidget {
  final ThemeData theme;
  final bool isDarkTheme;
  final DataDisplaySizesList sizes;
  final String? label;
  final WorkoutSetExerciseDto setExercise;
  final String repsText;

  const _StackedExerciseRow({
    required this.theme,
    required this.isDarkTheme,
    required this.sizes,
    required this.label,
    required this.setExercise,
    required this.repsText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final mutedColor = colors.onSurfaceVariant;
    final hasDifficulty = setExercise.difficulty != null;
    final hasOptions =
        setExercise.options != null && setExercise.options!.isNotEmpty;

    return InkWell(
      onTap: () {
        context.push('/exercises/${setExercise.exerciseId}');
      },
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
                        setExercise.exercise?.name ?? 'Unknown Exercise',
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        repsText,
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w500,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                  if (hasDifficulty || hasOptions) ...[
                    SizedBox(height: sizes.quarterSpacing),
                    _SetExerciseSubtitle(
                      setExercise: setExercise,
                      sizes: sizes,
                      theme: theme,
                      isDarkTheme: isDarkTheme,
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

class _SetExerciseSubtitle extends StatelessWidget {
  final WorkoutSetExerciseDto setExercise;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;

  const _SetExerciseSubtitle({
    required this.setExercise,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final hasDifficulty = setExercise.difficulty != null;
    final hasOptions =
        setExercise.options != null && setExercise.options!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDifficulty) _buildDifficulty(),
        if (hasDifficulty && hasOptions) SizedBox(height: sizes.quarterSpacing),
        if (hasOptions) _buildOptions(),
      ],
    );
  }

  Widget _buildDifficulty() {
    final color = isDarkTheme ? Colors.red[400] : Colors.red[600];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt, size: sizes.mediumSmallFontSize, color: color),
        SizedBox(width: sizes.quarterSpacing),
        Flexible(
          child: Text(
            '${setExercise.difficulty!.value} ${setExercise.difficulty!.type.value}',
            style: TextStyle(
              fontSize: sizes.smallFontSize,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    final color = theme.colorScheme.onSurfaceVariant;
    final optionNames = setExercise.options!
        .map((option) => option.exercise?.name ?? 'Unknown')
        .join(', ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: sizes.quarterSpacing / 2),
          child: Icon(
            Icons.swap_horiz,
            size: sizes.mediumSmallFontSize,
            color: color,
          ),
        ),
        SizedBox(width: sizes.quarterSpacing),
        Expanded(
          child: Text(
            optionNames,
            style: TextStyle(fontSize: sizes.smallFontSize, color: color),
          ),
        ),
      ],
    );
  }
}
