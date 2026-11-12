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

import '../../../data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import './workout_phase_badge.dart';

class WorkoutPlanWeekGroupSelector extends StatelessWidget {
  final List<WorkoutPlanWeekDto> weekGroups;
  final int selectedGroupIndex;
  final ValueChanged<int> onSelectGroup;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;

  const WorkoutPlanWeekGroupSelector({
    super.key,
    required this.weekGroups,
    required this.selectedGroupIndex,
    required this.onSelectGroup,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
  });

  String _groupLabel(WorkoutPlanWeekDto group) {
    return group.endWeek > group.startWeek
        ? 'Weeks ${group.startWeek} - ${group.endWeek}'
        : 'Week ${group.startWeek}';
  }

  @override
  Widget build(BuildContext context) {
    if (weekGroups.isEmpty) return const SizedBox.shrink();

    final safeIndex = selectedGroupIndex.clamp(0, weekGroups.length - 1);
    final currentGroup = weekGroups[safeIndex];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.padding,
        vertical: sizes.padding / 2,
      ),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        border: Border.all(
          color: isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (weekGroups.length == 1)
            Text(
              _groupLabel(currentGroup),
              style: TextStyle(
                fontSize: sizes.fontSize,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: safeIndex,
                isExpanded: true,
                itemHeight: null,
                borderRadius: BorderRadius.zero,
                dropdownColor: theme.cardColor,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.primaryColor,
                  size: sizes.buttonIconSize,
                ),
                onChanged: (newIndex) {
                  if (newIndex != null) onSelectGroup(newIndex);
                },
                items: weekGroups.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: sizes.halfSpacing,
                      ),
                      child: Text(
                        _groupLabel(entry.value),
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: sizes.halfSpacing),
          Wrap(
            spacing: sizes.halfSpacing,
            runSpacing: sizes.halfSpacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (currentGroup.phase != null)
                WorkoutPhaseBadge(sizes: sizes, phase: currentGroup.phase!),
              Text(
                '${currentGroup.totalDays} days • ${currentGroup.totalWorkouts} workouts',
                style: TextStyle(
                  fontSize: sizes.smallFontSize,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
