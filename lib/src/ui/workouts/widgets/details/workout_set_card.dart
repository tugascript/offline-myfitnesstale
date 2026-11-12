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

  const WorkoutSetCard({
    super.key,
    required this.theme,
    required this.isDarkTheme,
    required this.sizes,
    required this.set,
    required this.setNumber,
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
    final iconLightGreyColor = isDarkTheme
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final roundsAndReps = _formatRoundsAndReps(exercise);
    final rest = _formatRest();
    final hasDifficulty = exercise.difficulty != null;
    final hasOptions = exercise.options != null && exercise.options!.isNotEmpty;

    return Card(
      margin: EdgeInsets.symmetric(vertical: sizes.margins / 2),
      child: InkWell(
        onTap: () {
          context.push('/exercises/${exercise.exerciseId}');
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DetailNumber(
                    number: setNumber,
                    theme: theme,
                    fontSize: sizes.subtitleFontSize,
                  ),
                  SizedBox(width: sizes.padding),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: sizes.padding / 4,
                      children: [
                        Text(
                          exercise.exercise?.name ?? 'Unknown Exercise',
                          style: TextStyle(
                            fontSize: sizes.fontSize,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '· $roundsAndReps · $rest',
                          style: TextStyle(
                            fontSize: sizes.fontSize,
                            color: iconLightGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: sizes.padding / 2),
                  SetTypeBadge(sizes: sizes, setType: set.setType),
                  SizedBox(width: sizes.padding / 4),
                  Icon(
                    Icons.chevron_right,
                    size: sizes.fontSize * 1.2,
                    color: iconLightGreyColor,
                  ),
                ],
              ),
              if (hasDifficulty || hasOptions) ...[
                SizedBox(height: sizes.padding / 4),
                Padding(
                  padding: EdgeInsets.only(
                    left: sizes.subtitleFontSize * 1.75 + sizes.padding,
                  ),
                  child: _SetExerciseSubtitle(
                    setExercise: exercise,
                    padding: 0,
                    spacing: sizes.spacing / 2,
                    smallPadding: sizes.padding / 4,
                    fontSize: sizes.fontSize,
                    smallFontSize: sizes.smallFontSize,
                    isDarkTheme: isDarkTheme,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedCard(BuildContext context) {
    final iconGreyColor = isDarkTheme
        ? Colors.grey.shade200
        : Colors.grey.shade800;
    final iconLightGreyColor = isDarkTheme
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final rounds = _formatRounds();
    final rest = _formatRest();

    final isLettered =
        set.setType == WorkoutSetType.superSet ||
        set.setType == WorkoutSetType.giant ||
        set.setType == WorkoutSetType.circuit;

    return Card(
      margin: EdgeInsets.symmetric(vertical: sizes.margins / 2),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(width: sizes.padding),
                SetTypeBadge(sizes: sizes, setType: set.setType),
                SizedBox(width: sizes.padding / 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: sizes.fontSize * 1.1,
                      color: iconLightGreyColor,
                    ),
                    Text(
                      ' $rounds',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.w600,
                        color: iconGreyColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: sizes.fontSize,
                      color: iconLightGreyColor,
                    ),
                    Text(
                      ' $rest',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: iconLightGreyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: sizes.padding / 2),
            const Divider(height: 1),
            SizedBox(height: sizes.padding / 4),
            // Stacked exercises
            if (set.exercises == null || set.exercises!.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: sizes.padding / 2),
                child: Text(
                  'No exercises in this block',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: sizes.fontSize,
                  ),
                ),
              )
            else
              ...set.exercises!.asMap().entries.map((entry) {
                final exIndex = entry.key;
                final setExercise = entry.value;
                final label = isLettered
                    ? String.fromCharCode(65 + exIndex)
                    : '${exIndex + 1}';

                return Column(
                  children: [
                    if (exIndex > 0)
                      Divider(
                        height: sizes.padding / 2,
                        thickness: 0.5,
                        color: theme.dividerColor.withValues(alpha: 0.3),
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
  final String label;
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
    final iconLightGreyColor = isDarkTheme
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final hasDifficulty = setExercise.difficulty != null;
    final hasOptions =
        setExercise.options != null && setExercise.options!.isNotEmpty;

    return InkWell(
      onTap: () {
        context.push('/exercises/${setExercise.exerciseId}');
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: sizes.padding / 2,
          horizontal: sizes.padding / 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: sizes.fontSize * 1.5,
                  height: sizes.fontSize * 1.5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDarkTheme
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: sizes.smallFontSize,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
                SizedBox(width: sizes.padding / 2),
                Expanded(
                  child: Text(
                    setExercise.exercise?.name ?? 'Unknown Exercise',
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: sizes.padding / 2),
                Text(
                  repsText,
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.w500,
                    color: iconLightGreyColor,
                  ),
                ),
                SizedBox(width: sizes.padding / 4),
                Icon(
                  Icons.chevron_right,
                  size: sizes.fontSize * 1.2,
                  color: iconLightGreyColor,
                ),
              ],
            ),
            if (hasDifficulty || hasOptions)
              Padding(
                padding: EdgeInsets.only(
                  left: sizes.fontSize * 1.5 + sizes.padding / 2,
                  top: sizes.padding / 4,
                ),
                child: _SetExerciseSubtitle(
                  setExercise: setExercise,
                  padding: 0,
                  spacing: sizes.spacing / 2,
                  smallPadding: sizes.padding / 4,
                  fontSize: sizes.fontSize,
                  smallFontSize: sizes.smallFontSize,
                  isDarkTheme: isDarkTheme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SetExerciseSubtitle extends StatelessWidget {
  final WorkoutSetExerciseDto setExercise;
  final double padding;
  final double spacing;
  final double smallPadding;
  final double fontSize;
  final double smallFontSize;
  final bool isDarkTheme;

  const _SetExerciseSubtitle({
    required this.setExercise,
    required this.padding,
    required this.spacing,
    required this.smallPadding,
    required this.fontSize,
    required this.smallFontSize,
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
        if (padding > 0) SizedBox(height: padding),
        if (hasDifficulty) _buildDifficulty(),
        if (hasDifficulty && hasOptions) SizedBox(height: spacing),
        if (hasOptions) _buildOptions(),
      ],
    );
  }

  Widget _buildDifficulty() {
    final color = isDarkTheme ? Colors.red[400] : Colors.red[600];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.bolt, size: fontSize * 1.1, color: color),
        SizedBox(width: smallPadding),
        Text(
          '${setExercise.difficulty!.value} ${setExercise.difficulty!.type.value}',
          style: TextStyle(
            fontSize: smallFontSize,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    final color = isDarkTheme ? Colors.grey[400] : Colors.grey[600];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.swap_horiz, size: smallFontSize * 1.2, color: color),
        SizedBox(width: smallPadding),
        ...setExercise.options!.asMap().entries.map(
          (entry) => Text(
            '${entry.value.exercise?.name}${entry.key == setExercise.options!.length - 1 ? '' : ', '}',
            style: TextStyle(fontSize: smallFontSize, color: color),
          ),
        ),
      ],
    );
  }
}
