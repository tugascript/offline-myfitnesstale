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

import '../../core/sizes/data_display_sizes.dart';

class WorkoutPlanWeeksStrip extends StatelessWidget {
  final int startWeek;
  final int endWeek;
  final int selectedWeek;
  final ValueChanged<int> onSelectWeek;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final int? currentWeekNum;
  final bool Function(int weekNum)? isWeekCompleted;
  final int Function(int weekNum)? getWeekWorkoutCount;

  const WorkoutPlanWeeksStrip({
    super.key,
    required this.startWeek,
    required this.endWeek,
    required this.selectedWeek,
    required this.onSelectWeek,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    this.currentWeekNum,
    this.isWeekCompleted,
    this.getWeekWorkoutCount,
  });

  @override
  Widget build(BuildContext context) {
    final weekCount = endWeek >= startWeek ? (endWeek - startWeek + 1) : 0;
    if (weekCount <= 0) return const SizedBox.shrink();

    final colors = theme.colorScheme;

    Widget buildItem(int weekNum) {
      final isSelected = weekNum == selectedWeek;
      final isCurrent = weekNum == currentWeekNum;
      final completed = isWeekCompleted?.call(weekNum) ?? false;
      final workoutCount = getWeekWorkoutCount?.call(weekNum);

      Color labelColor;
      if (isSelected || isCurrent) {
        labelColor = colors.primary;
      } else {
        labelColor = colors.onSurfaceVariant;
      }

      final lineColor = isSelected
          ? colors.primary
          : isCurrent
          ? colors.primary.withValues(alpha: 0.5)
          : completed
          ? Colors.green
          : colors.outlineVariant;

      final semanticLabel =
          'Week $weekNum'
          '${completed ? ', completed' : ''}'
          '${isCurrent ? ', current week' : ''}'
          '${workoutCount != null ? ', $workoutCount workouts' : ''}';

      return Semantics(
        label: semanticLabel,
        selected: isSelected,
        button: true,
        child: InkWell(
          onTap: () => onSelectWeek(weekNum),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: sizes.spacing / 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  key: ValueKey('week-strip-line-$weekNum'),
                  height: sizes.spacing / 4,
                  color: lineColor,
                ),
                SizedBox(height: sizes.spacing / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (completed) ...[
                      Icon(
                        Icons.check_circle,
                        size: sizes.smallFontSize * 1.1,
                        color: Colors.green,
                      ),
                      SizedBox(width: sizes.spacing / 6),
                    ],
                    Flexible(
                      child: Text(
                        'W$weekNum',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizes.smallFontSize,
                          fontWeight: isSelected || isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: labelColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (weekCount <= 7) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -100 && selectedWeek < endWeek) {
            onSelectWeek(selectedWeek + 1);
          } else if (details.primaryVelocity! > 100 &&
              selectedWeek > startWeek) {
            onSelectWeek(selectedWeek - 1);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(weekCount, (i) {
            final weekNum = startWeek + i;
            return Expanded(child: buildItem(weekNum));
          }),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(weekCount, (i) {
          final weekNum = startWeek + i;
          return SizedBox(
            width: sizes.buttonSize * 1.3,
            child: buildItem(weekNum),
          );
        }),
      ),
    );
  }
}
