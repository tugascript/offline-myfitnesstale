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
import '../../core/widgets/icon_numeric_string.dart';
import '../../core/widgets/layout/app_dropdown.dart';
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
    final metaColor = theme.colorScheme.onSurfaceVariant;

    return Column(
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
          AppDropdown<int>(
            filled: true,
            value: safeIndex,
            emptyLabel: 'Select weeks',
            showEmptyValue: false,
            items: List.generate(weekGroups.length, (index) => index),
            labelBuilder: (index) => _groupLabel(weekGroups[index]),
            fontSize: sizes.fontSize,
            padding: sizes.padding * 0.4,
            onChanged: (newIndex) {
              if (newIndex != null) onSelectGroup(newIndex);
            },
            onSaved: (_) {},
          ),
        SizedBox(height: sizes.halfSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (currentGroup.phase != null)
              WorkoutPhaseBadge(sizes: sizes, phase: currentGroup.phase!),
            IconNumericString(
              sizes: sizes,
              icon: Icons.calendar_today,
              color: metaColor,
              number: currentGroup.totalDays,
            ),
            IconNumericString(
              sizes: sizes,
              icon: Icons.fitness_center,
              color: metaColor,
              number: currentGroup.totalWorkouts,
            ),
          ],
        ),
      ],
    );
  }
}
