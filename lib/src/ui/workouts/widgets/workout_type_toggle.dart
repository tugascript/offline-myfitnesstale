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

class WorkoutTypeToggle extends StatelessWidget {
  final ExerciseType selectedType;
  final ValueChanged<ExerciseType> onChanged;
  final DataDisplaySizesList sizes;
  final bool enabled;

  const WorkoutTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
    required this.sizes,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ExerciseType>(
        showSelectedIcon: false,
        style: const ButtonStyle(
          shape: WidgetStatePropertyAll(BeveledRectangleBorder()),
        ),
        segments: [
          ButtonSegment<ExerciseType>(
            value: ExerciseType.strength,
            icon: Icon(Icons.fitness_center, size: sizes.iconSmallSize),
            label: Text(
              EnumDisplayNames.getExerciseTypeDisplayName(
                ExerciseType.strength,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: sizes.smallFontSize),
            ),
          ),
          ButtonSegment<ExerciseType>(
            value: ExerciseType.cardio,
            icon: Icon(Icons.directions_run, size: sizes.iconSmallSize),
            label: Text(
              EnumDisplayNames.getExerciseTypeDisplayName(ExerciseType.cardio),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: sizes.smallFontSize),
            ),
          ),
        ],
        selected: {selectedType},
        onSelectionChanged: enabled
            ? (selection) {
                if (selection.isEmpty) {
                  return;
                }
                final nextType = selection.first;
                if (nextType != selectedType) {
                  onChanged(nextType);
                }
              }
            : null,
      ),
    );
  }
}
