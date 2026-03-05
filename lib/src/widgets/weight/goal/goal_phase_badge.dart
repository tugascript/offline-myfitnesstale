import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../models/utilities.dart';

class GoalPhaseBadge extends StatelessWidget {
  const GoalPhaseBadge({
    super.key,
    required this.phase,
    required this.spacing,
    required this.fontSize,
    required this.fontWeight,
  });

  final WeightGoalPhase? phase;
  final double spacing;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor();
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _phaseIcon(),
            size: fontSize * 1.2,
            color: color,
          ),
          Text(
            " ${EnumDisplayNames.getWeightGoalPhaseDisplayName(phase)}",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          )
        ],
      ),
    );
  }

  Color _phaseColor() {
    switch (phase) {
      case WeightGoalPhase.cut:
        return Colors.green;
      case WeightGoalPhase.maintain:
        return Colors.orange;
      case WeightGoalPhase.bulk:
        return Colors.red;
      case null:
        return Colors.grey;
    }
  }

  IconData _phaseIcon() {
    switch (phase) {
      case WeightGoalPhase.cut:
        return Icons.trending_down;
      case WeightGoalPhase.maintain:
        return Icons.trending_flat;
      case WeightGoalPhase.bulk:
        return Icons.trending_up;
      case null:
        return Icons.help;
    }
  }
}
