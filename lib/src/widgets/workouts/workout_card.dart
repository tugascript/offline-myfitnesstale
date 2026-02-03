import 'package:flutter/material.dart';

import '../../services/dtos/workout_dto.dart';
import '../../utilities/sizes/workouts_sizes.dart';
import '../common/difficulty_badge.dart';
import '../common/muscle_group_badge.dart';

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
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(
        vertical: sizes.gridSpacing / 2,
        horizontal: sizes.gridSpacing / 4,
      ),
      elevation: sizes.cardElevation,
      shape: BeveledRectangleBorder(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(sizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.name,
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}
