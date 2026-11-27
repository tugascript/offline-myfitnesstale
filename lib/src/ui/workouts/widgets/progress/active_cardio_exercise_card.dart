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

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/cardio_set_type_badge.dart';

class ActiveCardioExerciseCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final CardioSetType setType;
  final int currentBlock;
  final int totalBlocks;
  final int currentRound;
  final int totalRounds;
  final int currentExercise;
  final int totalExercises;
  final String exerciseName;
  final CardioBaseMode mode;
  final int targetQuantity;
  final String? unit;
  final int exerciseRestSecs;
  final int setRestSecs;

  const ActiveCardioExerciseCard({
    super.key,
    required this.sizes,
    required this.theme,
    required this.setType,
    required this.currentBlock,
    required this.totalBlocks,
    required this.currentRound,
    required this.totalRounds,
    required this.currentExercise,
    required this.totalExercises,
    required this.exerciseName,
    required this.mode,
    required this.targetQuantity,
    this.unit,
    required this.exerciseRestSecs,
    required this.setRestSecs,
  });

  String _formatTarget() {
    if (mode == CardioBaseMode.time) {
      return Converters.formatDuration(targetQuantity);
    }
    final trimmedUnit = unit?.trim();
    if (trimmedUnit != null && trimmedUnit.isNotEmpty) {
      return '$targetQuantity $trimmedUnit';
    }
    return '$targetQuantity units';
  }

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final mutedColor = colors.onSurfaceVariant;
    final targetLabel = _formatTarget();
    final showExerciseRest =
        setType == CardioSetType.interval && exerciseRestSecs > 0;
    final showSetRest = setRestSecs > 0;

    return Card(
      margin: EdgeInsets.zero,
      shape: const BeveledRectangleBorder(),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
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
                    CardioSetTypeBadge(sizes: sizes, setType: setType),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.repeat,
                          size: sizes.fontSize * 1.1,
                          color: mutedColor,
                        ),
                        Flexible(
                          child: Text(
                            setType == CardioSetType.interval
                                ? ' Round $currentRound of $totalRounds'
                                : ' Block $currentBlock of $totalBlocks',
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
                if (totalExercises > 1)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_run,
                        size: sizes.fontSize * 1.1,
                        color: mutedColor,
                      ),
                      Flexible(
                        child: Text(
                          ' Exercise $currentExercise of $totalExercises',
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
            SizedBox(height: sizes.spacing),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: sizes.halfSpacing,
              runSpacing: sizes.quarterSpacing,
              children: [
                Text(
                  targetLabel,
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
                  ),
                ),
                Text(
                  exerciseName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            if (showExerciseRest || showSetRest) ...[
              SizedBox(height: sizes.spacing),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: sizes.halfSpacing,
                runSpacing: sizes.quarterSpacing,
                children: [
                  if (showExerciseRest)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: sizes.fontSize * 1.1,
                          color: colors.onSurface,
                        ),
                        Flexible(
                          child: Text(
                            ' Exercise Rest: ${Converters.formatDuration(exerciseRestSecs)}',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (showSetRest)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: sizes.fontSize * 1.1,
                          color: colors.onSurface,
                        ),
                        Flexible(
                          child: Text(
                            setType == CardioSetType.interval
                                ? ' Round Rest: ${Converters.formatDuration(setRestSecs)}'
                                : ' Rest: ${Converters.formatDuration(setRestSecs)}',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
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
