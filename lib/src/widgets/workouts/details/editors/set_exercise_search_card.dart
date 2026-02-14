import 'package:flutter/material.dart';

import '../../../exercises/exercise_name.dart';
import '../../../layout/list_card.dart';
import '../../../../services/dtos/exercise_dto.dart';

class SetExerciseSearchCard extends StatelessWidget {
  final ExerciseDto exercise;
  final double margins;
  final double padding;
  final double fontSize;
  final VoidCallback onTap;

  const SetExerciseSearchCard({
    super.key,
    required this.exercise,
    required this.margins,
    required this.padding,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: margins,
      padding: padding,
      onTap: onTap,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ExerciseName(
              name: exercise.name,
              isFavorite: exercise.isFavorite,
              fontSize: fontSize,
            ),
            Icon(
              Icons.add,
              size: fontSize * 1.2,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
