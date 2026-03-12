import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../models/utilities.dart';
import '../../../services/dtos/workout_set_dto.dart';
import '../../../services/dtos/workout_set_exercise_dto.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/detail_number.dart';

class ActiveWorkoutSetCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDarkTheme;
  final DataDisplaySizesList sizes;
  final WorkoutSetDto set;
  final int setNumber;
  final bool isCurrentSet;
  final int? currentExerciseIndexInSet;
  final bool isCompleted;

  const ActiveWorkoutSetCard({
    super.key,
    required this.theme,
    required this.isDarkTheme,
    required this.sizes,
    required this.set,
    required this.setNumber,
    required this.isCurrentSet,
    this.currentExerciseIndexInSet,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final iconGreyColor = isDarkTheme ? Colors.grey[200] : Colors.grey[800];
    final iconLightGreyColor =
        isDarkTheme ? Colors.grey[400] : Colors.grey[600];
    final isExpanded = isCurrentSet || setNumber == 1;

    return Card(
      elevation: isCurrentSet ? theme.cardTheme.elevation ?? 2 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: isCurrentSet
            ? BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: ExpansionTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCompleted)
              Padding(
                padding: EdgeInsets.only(right: sizes.padding / 4),
                child: Icon(
                  Icons.check_circle,
                  size: sizes.subtitleFontSize,
                  color: theme.colorScheme.primary,
                ),
              ),
            DetailNumber(
              number: setNumber,
              theme: theme,
              fontSize: sizes.subtitleFontSize,
            ),
          ],
        ),
        initiallyExpanded: isExpanded,
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
            ...set.exercises!.asMap().entries.map((entry) {
              final exerciseIndex = entry.key;
              final setExercise = entry.value;
              final isCurrentExercise = isCurrentSet &&
                  currentExerciseIndexInSet != null &&
                  exerciseIndex == currentExerciseIndexInSet;
              return _ActiveSetExercise(
                isDarkTheme: isDarkTheme,
                sizes: sizes,
                setExercise: setExercise,
                isCurrentExercise: isCurrentExercise,
                theme: theme,
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

class _ActiveSetExercise extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutSetExerciseDto setExercise;
  final bool isDarkTheme;
  final bool isCurrentExercise;
  final ThemeData theme;

  const _ActiveSetExercise({
    required this.sizes,
    required this.setExercise,
    required this.isDarkTheme,
    required this.isCurrentExercise,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isCurrentExercise
          ? BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: ListTile(
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
                fontWeight:
                    isCurrentExercise ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
