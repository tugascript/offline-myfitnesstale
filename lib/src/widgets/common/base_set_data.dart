import 'package:flutter/material.dart';

import '../../services/dtos/workout_set_dto.dart';
import '../../utilities/converters.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'set_type_badge.dart';

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
              ' ${workoutSet.minSets}-${workoutSet.maxSets != null && workoutSet.maxSets! > workoutSet.minSets ? '-${workoutSet.maxSets}' : ''}',
              style: TextStyle(fontSize: sizes.fontSize),
            ),
          ],
        ),
        SetTypeBadge(
          sizes: sizes,
          setType: workoutSet.setType,
        ),
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
              style: TextStyle(
                fontSize: sizes.fontSize,
                color: workoutsColor,
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
              color: restTimeColor,
            ),
            Text(
              ' ${Converters.formatDuration(workoutSet.recommendedRestSecs)}${workoutSet.maxRestSecs != null && workoutSet.maxRestSecs! > workoutSet.recommendedRestSecs ? '-${Converters.formatDuration(workoutSet.maxRestSecs!)}' : ''}',
              style: TextStyle(
                fontSize: sizes.fontSize,
                color: restTimeColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
