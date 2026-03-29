import 'package:flutter/material.dart';

import '../../../models/common.dart';
import '../../../utilities/formatters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';

class ActiveExerciseCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final int minSets;
  final int? maxSets;
  final int currentSet;
  final int exercises;
  final int currentExercise;
  final int minReps;
  final int? maxReps;
  final bool toMaxReps;
  final String exerciseName;
  final int recommendedRestSecs;
  final int? maxRestSecs;
  final WorkoutSetExerciseDifficulty? difficulty;

  const ActiveExerciseCard({
    super.key,
    required this.sizes,
    required this.theme,
    required this.minSets,
    required this.maxSets,
    required this.currentSet,
    required this.exercises,
    required this.currentExercise,
    required this.minReps,
    required this.maxReps,
    required this.toMaxReps,
    required this.exerciseName,
    required this.recommendedRestSecs,
    required this.maxRestSecs,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final greyColor = theme.colorScheme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat, size: sizes.fontSize * 1.2),
                    Text(
                      ' Set $currentSet of $minSets${maxSets != null ? '-$maxSets' : ''}',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fitness_center, size: sizes.fontSize * 1.2),
                    Text(
                      ' Exercise $currentExercise of $exercises',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$minReps${toMaxReps ? '-MAX ' : maxReps != null ? '-$maxReps ' : ' '}x ',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: greyColor,
                  ),
                ),
                Text(
                  exerciseName,
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: sizes.fontSize * 1.2,
                      color: theme.colorScheme.onSurface,
                    ),
                    Text(
                      ' Rest: ${Formatters.formatDuration(recommendedRestSecs)}${maxRestSecs != null ? '-${Formatters.formatDuration(maxRestSecs!)}' : ''}',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (difficulty != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: sizes.fontSize * 1.2),
                      Text(
                        ' Difficulty: ${difficulty!.value} ${difficulty!.type.value}',
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
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
