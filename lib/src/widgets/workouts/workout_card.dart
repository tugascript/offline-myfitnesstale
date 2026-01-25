import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/dtos/workout_dto.dart';
import '../../utilities/sizes/workouts_sizes.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutDto workout;
  final VoidCallback? onTap;
  final WorkoutsSizesList sizes;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.sizes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: sizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizes.cardSpacing),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(sizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (workout.description != null &&
                  workout.description!.isNotEmpty) ...[
                SizedBox(height: sizes.cardSpacing / 1.5),
                Text(
                  workout.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: sizes.cardSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DifficultyChip(
                    difficulty: workout.difficulty,
                    sizes: sizes,
                  ),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios,
                        size: sizes.arrowIconSize, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;
  final WorkoutsSizesList sizes;

  const _DifficultyChip({
    required this.difficulty,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_difficultyLabel(difficulty)),
      backgroundColor: _difficultyColor(difficulty).withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: _difficultyColor(difficulty),
        fontWeight: FontWeight.w600,
        fontSize: sizes.titleFontSize * 0.55,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(horizontal: sizes.cardPadding / 2),
      side: BorderSide(color: _difficultyColor(difficulty).withValues(alpha: 0.3)),
    );
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'Beginner / Intermediate';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'Intermediate / Advanced';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.beginnerIntermediate:
        return Colors.lightGreen;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.intermediateAdvanced:
        return Colors.deepOrange;
      case Difficulty.advanced:
        return Colors.red;
    }
  }
}
