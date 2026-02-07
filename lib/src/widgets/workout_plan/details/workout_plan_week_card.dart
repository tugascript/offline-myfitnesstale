import 'package:flutter/material.dart';

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
      child: ExpansionTile(
        leading: DetailNumber(
          number: weekNumber,
          theme: theme,
          fontSize: sizes.subtitleFontSize,
        ),
        initiallyExpanded: weekNumber == 1,
        title: Row(
          children: [
            Icon(Icons.calendar_today, size: sizes.subtitleFontSize),
            Text(
              ' ${week.startWeek}${week.endWeek > week.startWeek ? ' - ${week.endWeek}' : ''}',
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: week.days
                ?.map(
                  (day) => WorkoutPlanDayCard(day: day),
                )
                .toList() ??
            [],
      ),
    );
  }
}
