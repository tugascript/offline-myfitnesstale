import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/utilities.dart';

class DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;
  final double spacing;
  final double fontSize;
  final FontWeight fontWeight;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    required this.spacing,
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _difficultyColor(difficulty);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing / 2,
      ),
      decoration: BoxDecoration(
        color: difficultyColor.withValues(alpha: 0.2),
        border: Border.all(
          color: difficultyColor,
          width: 1,
        ),
      ),
      child: Text(
        EnumDisplayNames.getDifficultyDisplayName(difficulty),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: difficultyColor,
        ),
      ),
    );
  }

  Color _difficultyColor(Difficulty? d) {
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
      case null:
        return Colors.grey;
    }
  }
}
