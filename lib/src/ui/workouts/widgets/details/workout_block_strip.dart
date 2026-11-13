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

import '../../../../data/repositories/workouts/dtos/workout_set_dto.dart';
import '../../../../data/utils/display_names.dart';
import '../../../core/sizes/data_display_sizes.dart';

class WorkoutBlockStrip extends StatelessWidget {
  final List<WorkoutSetDto> sets;
  final int? selectedBlockIndex;
  final ValueChanged<int> onSelectBlock;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const WorkoutBlockStrip({
    super.key,
    required this.sets,
    required this.selectedBlockIndex,
    required this.onSelectBlock,
    required this.sizes,
    required this.theme,
  });

  String _formatRounds(WorkoutSetDto set) {
    if (set.maxSets != null && set.maxSets! > set.minSets) {
      return '${set.minSets}–${set.maxSets}×';
    }
    return '${set.minSets}×';
  }

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) return const SizedBox.shrink();

    final colors = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          final isSelected = selectedBlockIndex == index;
          final typeName = EnumDisplayNames.getSetTypeDisplayName(set.setType);
          final rounds = _formatRounds(set);
          final label = '${index + 1} $typeName · $rounds';

          final labelColor = isSelected
              ? theme.primaryColor
              : colors.onSurfaceVariant;
          final lineColor = isSelected
              ? theme.primaryColor
              : colors.outlineVariant;

          return Semantics(
            label: 'Block ${index + 1}, $typeName, $rounds',
            selected: isSelected,
            button: true,
            child: InkWell(
              key: ValueKey('block-strip-item-$index'),
              onTap: () => onSelectBlock(index),
              child: IntrinsicWidth(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.halfSpacing,
                    vertical: sizes.quarterSpacing,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizes.smallFontSize,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      SizedBox(height: sizes.halfSpacing),
                      Container(
                        key: ValueKey('block-strip-line-$index'),
                        height: sizes.quarterSpacing,
                        color: lineColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
