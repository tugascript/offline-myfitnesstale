import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../models/utilities.dart';
import '../../../services/dtos/workout_set_dto.dart';
import '../../../services/dtos/workout_set_exercise_dto.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/detail_number.dart';

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

  @override
  Widget build(BuildContext context) {
    final iconGreyColor = isDarkTheme ? Colors.grey[200] : Colors.grey[800];
    final iconLightGreyColor =
        isDarkTheme ? Colors.grey[400] : Colors.grey[600];
    return Card(
      child: ExpansionTile(
        leading: DetailNumber(
          number: setNumber,
          theme: theme,
          fontSize: sizes.subtitleFontSize,
        ),
        initiallyExpanded: true,
        title: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: sizes.padding / 2,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.repeat, size: sizes.fontSize * 1.2),
                Text(
                  ' ${set.minSets}${set.maxSets != null ? '-${set.maxSets}' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: sizes.fontSize,
                  ),
                ),
              ],
            ),
            _SetTypeBadge(
              sizes: sizes,
              setType: set.setType,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: sizes.fontSize,
                  color: iconGreyColor,
                ),
                Text(
                  ' ${set.exercises?.length ?? 0} ',
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    color: iconGreyColor,
                  ),
                )
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: sizes.fontSize,
                  color: iconLightGreyColor,
                ),
                Text(
                  ' ${Converters.formatDuration(set.recommendedRestSecs)}${set.maxRestSecs != null ? '-${Converters.formatDuration(set.maxRestSecs!)}' : ''}',
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    color: iconLightGreyColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          if (set.exercises?.isEmpty ?? true)
            Padding(
              padding: EdgeInsets.all(sizes.padding),
              child: Text(
                'No exercises in this set',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: sizes.fontSize,
                ),
              ),
            )
          else
            ...set.exercises!.map((setExercise) {
              return _SetExercise(
                isDarkTheme: isDarkTheme,
                sizes: sizes,
                setExercise: setExercise,
              );
            }),
          SizedBox(height: sizes.padding),
        ],
      ),
    );
  }
}

class _SetTypeBadge extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutSetType setType;

  const _SetTypeBadge({
    required this.sizes,
    required this.setType,
  });

  Color _getSetTypeColor(WorkoutSetType type) {
    switch (type) {
      case WorkoutSetType.standard:
        return Colors.blue;
      case WorkoutSetType.drop:
        return Colors.red;
      case WorkoutSetType.superSet:
        return Colors.purple;
      case WorkoutSetType.giant:
        return Colors.green;
      case WorkoutSetType.pyramid:
        return Colors.amber;
      case WorkoutSetType.circuit:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSetTypeColor(setType);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.padding / 4,
        vertical: sizes.padding / 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        EnumDisplayNames.getSetTypeDisplayName(setType),
        style: TextStyle(
          color: color,
          fontSize: sizes.smallFontSize,
        ),
      ),
    );
  }
}

class _SetExercise extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutSetExerciseDto setExercise;
  final bool isDarkTheme;

  const _SetExercise({
    required this.sizes,
    required this.setExercise,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final smallPadding = sizes.padding / 4;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${setExercise.minReps}${setExercise.maxReps != null ? '-${setExercise.maxReps}' : ''}x ',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            setExercise.exercise?.name ?? 'Unknown Exercise',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
            ),
          ),
        ],
      ),
      subtitle: _SetExerciseSubtitle(
        setExercise: setExercise,
        padding: sizes.padding,
        spacing: sizes.spacing / 2,
        smallPadding: smallPadding,
        fontSize: sizes.fontSize,
        smallFontSize: sizes.smallFontSize,
        isDarkTheme: isDarkTheme,
      ),
      onTap: () {
        context.push('/exercises/${setExercise.exerciseId}');
      },
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

    if (hasDifficulty && hasOptions) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: padding),
          _buildDifficulty(),
          SizedBox(height: spacing),
          _buildOptions(),
        ],
      );
    }

    if (hasDifficulty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: padding),
          _buildDifficulty(),
        ],
      );
    }

    if (hasOptions) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: padding),
          _buildOptions(),
        ],
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildDifficulty() {
    final color = isDarkTheme ? Colors.red[400] : Colors.red[600];
    return Wrap(
      children: [
        Icon(
          Icons.bolt,
          size: fontSize * 1.2,
          color: color,
        ),
        SizedBox(width: fontSize),
        Text(
          '${setExercise.difficulty!.value} ${setExercise.difficulty!.type.value}',
          style: TextStyle(
            fontSize: fontSize,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    final color = isDarkTheme ? Colors.grey[400] : Colors.grey[600];
    return Wrap(
      children: [
        Icon(
          Icons.swap_horiz,
          size: smallFontSize * 1.2,
          color: color,
        ),
        SizedBox(width: smallFontSize),
        ...setExercise.options!.asMap().entries.map(
              (entry) => Text(
                '${entry.value.exercise?.name}${entry.key == setExercise.options!.length - 1 ? '' : ', '}',
                style: TextStyle(
                  fontSize: smallFontSize,
                  color: Colors.grey,
                ),
              ),
            ),
      ],
    );
  }
}
