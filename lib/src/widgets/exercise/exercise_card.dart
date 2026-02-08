import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/dtos/exercise_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../common/difficulty_badge.dart';
import '../common/muscle_group_badge.dart';
import '../layout/list_card.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseDto exercise;
  final VoidCallback onTap;
  final DataDisplaySizesList sizes;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.margins,
      padding: sizes.padding,
      onTap: onTap,
      children: [
        _ExerciseName(
          name: exercise.name,
          isFavorite: exercise.isFavorite,
          fontSize: sizes.subtitleFontSize,
        ),
        SizedBox(height: sizes.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ExerciseInfo(
              sizes: sizes,
              difficulty: exercise.difficulty,
              muscleGroup: exercise.muscleGroup,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.fontSize * 1.2,
              color: Colors.grey,
            )
          ],
        ),
      ],
    );
  }
}

class _ExerciseName extends StatelessWidget {
  final String name;
  final bool isFavorite;
  final double fontSize;

  const _ExerciseName({
    required this.name,
    required this.isFavorite,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFavorite) {
      return Text(
        name,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      children: [
        Text(
          "$name ",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Icon(
          Icons.favorite,
          color: Colors.red,
          size: fontSize * 1.2,
        ),
      ],
    );
  }
}

class _ExerciseInfo extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Difficulty? difficulty;
  final MuscleGroup muscleGroup;

  const _ExerciseInfo({
    required this.sizes,
    required this.difficulty,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DifficultyBadge(
          difficulty: difficulty,
          spacing: sizes.padding / 2,
          fontSize: sizes.fontSize,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(width: sizes.spacing),
        MuscleGroupBadge(
          muscleGroup: muscleGroup,
          fontSize: sizes.fontSize,
        ),
      ],
    );
  }
}
