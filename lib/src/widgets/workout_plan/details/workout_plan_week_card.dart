import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../models/utilities.dart';
import '../../../services/dtos/workout_plan_week_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/detail_number.dart';
import 'workout_plan_day_card.dart';

class WorkoutPlanWeekCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDarkTheme;
  final DataDisplaySizesList sizes;
  final WorkoutPlanWeekDto week;
  final int weekNumber;

  const WorkoutPlanWeekCard({
    super.key,
    required this.theme,
    required this.isDarkTheme,
    required this.sizes,
    required this.week,
    required this.weekNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: sizes.margins / 2,
      ),
      child: ExpansionTile(
        dense: true,
        leading: DetailNumber(
          number: weekNumber,
          theme: theme,
          fontSize: sizes.subtitleFontSize,
        ),
        initiallyExpanded: weekNumber == 1,
        title: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month, size: sizes.subtitleFontSize * 2),
                Text(
                  ' ${week.startWeek}${week.endWeek > week.startWeek ? ' - ${week.endWeek}' : ''}',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (week.phase != null) ...[
              SizedBox(width: sizes.spacing),
              _WorkoutPhaseBadge(
                sizes: sizes,
                phase: week.phase!,
              ),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: sizes.subtitleFontSize * 1.2,
                ),
                Text(
                  ' ${week.totalDays}',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '🏋',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize * 1.2,
                  ),
                ),
                Text(
                  ' ${week.totalWorkouts}',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: week.days
                ?.map(
                  (day) => WorkoutPlanDayCard(
                    day: day,
                    sizes: sizes,
                    theme: theme,
                    isDarkTheme: isDarkTheme,
                  ),
                )
                .toList() ??
            [],
      ),
    );
  }
}

class _WorkoutPhaseBadge extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutPhase phase;

  const _WorkoutPhaseBadge({
    required this.sizes,
    required this.phase,
  });

  Color _getPhaseColor(WorkoutPhase phase) {
    switch (phase) {
      case WorkoutPhase.endurance:
        return Colors.green;
      case WorkoutPhase.hypertrophy:
        return Colors.yellow[700]!;
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
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        EnumDisplayNames.getWorkoutPhaseDisplayName(phase),
        style: TextStyle(
          color: color,
          fontSize: sizes.smallFontSize,
        ),
      ),
    );
  }
}
