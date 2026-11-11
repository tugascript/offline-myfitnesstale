// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/display_names.dart';
import '../../../../data/utils/enums.dart';

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
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing / 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_phaseIcon(), size: fontSize * 1.2, color: color),
          Text(
            " ${EnumDisplayNames.getWeightGoalPhaseDisplayName(phase)}",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
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
