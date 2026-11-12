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

import '../../../data/utils/display_names.dart';
import '../../../data/utils/enums.dart';
import '../../core/sizes/data_display_sizes.dart';

class WorkoutPhaseBadge extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutPhase phase;

  const WorkoutPhaseBadge({
    super.key,
    required this.sizes,
    required this.phase,
  });

  Color _getPhaseColor(WorkoutPhase phase) {
    switch (phase) {
      case WorkoutPhase.endurance:
        return Colors.green;
      case WorkoutPhase.hypertrophy:
        return Colors.yellow.shade700;
      case WorkoutPhase.maxStrength:
        return Colors.orange;
      case WorkoutPhase.power:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPhaseColor(phase);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.padding / 4,
        vertical: sizes.padding / 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        EnumDisplayNames.getWorkoutPhaseDisplayName(phase),
        style: TextStyle(color: color, fontSize: sizes.smallFontSize),
      ),
    );
  }
}
