// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';

import '../../../data/repositories/workouts/dtos/workout_set_dto.dart';
import '../utils/converters.dart';
import '../sizes/data_display_sizes.dart';
import './set_type_badge.dart';

class BaseSetData extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final Color workoutsColor;
  final Color restTimeColor;
  final WorkoutSetDto workoutSet;

  const BaseSetData({
    super.key,
    required this.sizes,
    required this.theme,
    required this.workoutsColor,
    required this.restTimeColor,
    required this.workoutSet,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: sizes.padding / 2,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat, size: sizes.fontSize * 1.2),
            Text(
              ' ${workoutSet.minSets}${workoutSet.maxSets != null && workoutSet.maxSets! > workoutSet.minSets ? '-${workoutSet.maxSets}' : ''}',
              style: TextStyle(fontSize: sizes.fontSize),
            ),
          ],
        ),
        SetTypeBadge(sizes: sizes, setType: workoutSet.setType),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: sizes.fontSize,
              color: workoutsColor,
            ),
            Text(
              ' ${workoutSet.exercises?.length ?? 0} ',
              style: TextStyle(fontSize: sizes.fontSize, color: workoutsColor),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.timer_outlined,
              size: sizes.fontSize,
              color: restTimeColor,
            ),
            Text(
              ' ${Converters.formatDuration(workoutSet.recommendedRestSecs)}${workoutSet.maxRestSecs != null && workoutSet.maxRestSecs! > workoutSet.recommendedRestSecs ? '-${Converters.formatDuration(workoutSet.maxRestSecs!)}' : ''}',
              style: TextStyle(fontSize: sizes.fontSize, color: restTimeColor),
            ),
          ],
        ),
      ],
    );
  }
}
