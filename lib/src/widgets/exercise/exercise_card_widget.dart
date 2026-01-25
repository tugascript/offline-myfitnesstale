import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/dtos/exercise_dto.dart';

class ExerciseCardWidget extends StatelessWidget {
  final ExerciseDto exercise;
  final String? muscleGroupName;
  final VoidCallback? onTap;
  final bool showFavorite;
  final bool compact;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    this.muscleGroupName,
    this.onTap,
    this.showFavorite = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: compact
              ? const EdgeInsets.all(12.0)
              : const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showFavorite && exercise.isFavorite)
                    Icon(
                      Icons.favorite,
                      size: compact ? 16 : 20,
                      color: Colors.red,
                    ),
                ],
              ),
              if (muscleGroupName != null || exercise.difficulty != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (muscleGroupName != null)
                      Text(
                        muscleGroupName!,
                        style: TextStyle(
                          fontSize: compact ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (exercise.difficulty != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _difficultyColor(Difficulty.fromValue(exercise.difficulty!))
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _difficultyLabel(Difficulty.fromValue(exercise.difficulty!)),
                          style: TextStyle(
                            fontSize: compact ? 10 : 12,
                            color: _difficultyColor(Difficulty.fromValue(exercise.difficulty!)),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'B-I';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'I-A';
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

