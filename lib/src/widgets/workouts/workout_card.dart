import 'package:flutter/material.dart';

import '../../services/dtos/workout_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../common/difficulty_badge.dart';
import '../common/muscle_group_badge.dart';
import '../common/total_numeric_string.dart';
import '../layout/list_card.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutDto workout;
  final VoidCallback onTap;
  final DataDisplaySizesList sizes;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.sizes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListCard(
      margin: sizes.margins,
      padding: sizes.padding,
      onTap: onTap,
      children: [
        Text(
          workout.name,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        Padding(
          padding: EdgeInsets.only(
            right: sizes.padding,
          ),
          child: Wrap(
            spacing: sizes.spacing,
            runSpacing: sizes.spacing,
            children: [
              TotalNumericString(
                emoji: '🔁',
                name: "Sets",
                total: workout.totalSets,
                fontSize: sizes.fontSize,
              ),
              TotalNumericString(
                emoji: '💪',
                name: "Reps",
                total: workout.totalReps,
                fontSize: sizes.fontSize,
              ),
            ],
          ),
        ),
        SizedBox(height: sizes.spacing),
        Wrap(
          spacing: sizes.spacing / 3,
          children: workout.muscleGroups.map((mg) {
            return MuscleGroupBadge(
              muscleGroup: mg,
              fontSize: sizes.fontSize * 0.8,
              theme: theme,
            );
          }).toList(),
        ),
        SizedBox(height: sizes.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DifficultyBadge(
              difficulty: workout.difficulty,
              spacing: sizes.padding / 2,
              fontSize: sizes.fontSize,
              fontWeight: FontWeight.w600,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.fontSize * 1.2,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
