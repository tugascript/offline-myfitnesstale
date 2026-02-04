import 'package:flutter/material.dart';

import '../../services/dtos/workout_dto.dart';
import '../../utilities/sizes/workouts_sizes.dart';
import '../common/difficulty_badge.dart';
import '../common/muscle_group_badge.dart';
import '../common/total_numeric_string.dart';
import '../layout/list_card.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutDto workout;
  final VoidCallback onTap;
  final WorkoutsSizesList sizes;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.sizes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.gridSpacing / 2,
      padding: sizes.cardPadding,
      onTap: onTap,
      children: [
        Text(
          workout.name,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.cardSpacing),
        Padding(
          padding: EdgeInsets.only(
            right: sizes.padding,
          ),
          child: Wrap(
            spacing: sizes.cardSpacing,
            runSpacing: sizes.cardSpacing,
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
        SizedBox(height: sizes.cardSpacing),
        Wrap(
          spacing: sizes.cardSpacing / 3,
          runSpacing: sizes.cardSpacing / 3,
          children: workout.muscleGroups.map((mg) {
            return MuscleGroupBadge(
              muscleGroup: mg,
              fontSize: sizes.fontSize * 0.8,
            );
          }).toList(),
        ),
        SizedBox(height: sizes.cardSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DifficultyBadge(
              difficulty: workout.difficulty,
              spacing: sizes.cardPadding / 2,
              fontSize: sizes.fontSize,
              fontWeight: FontWeight.w600,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.arrowIconSize,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
