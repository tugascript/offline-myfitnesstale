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

import '../../../../data/utils/json_data.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/formatters.dart';

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
                  '$minReps${toMaxReps
                      ? '-MAX '
                      : maxReps != null
                      ? '-$maxReps '
                      : ' '}x ',
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
