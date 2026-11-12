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

import '../../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/detail_number.dart';
import '../workout_phase_badge.dart';
import '../workout_plan_week_strip.dart';
import '../workout_plan_weeks_strip.dart';
import './workout_plan_workout_card.dart';

class WorkoutPlanWeekCard extends StatefulWidget {
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
  State<WorkoutPlanWeekCard> createState() => _WorkoutPlanWeekCardState();
}

class _WorkoutPlanWeekCardState extends State<WorkoutPlanWeekCard> {
  late int _selectedWeek;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedWeek = widget.week.startWeek;
    _selectedDay = _initialSelectedDay();
  }

  @override
  void didUpdateWidget(WorkoutPlanWeekCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.week != widget.week) {
      if (_selectedWeek < widget.week.startWeek ||
          _selectedWeek > widget.week.endWeek) {
        _selectedWeek = widget.week.startWeek;
      }
      final byDay = {for (final d in widget.week.days) d.day: d};
      if (!byDay.containsKey(_selectedDay)) {
        setState(() {
          _selectedDay = _initialSelectedDay();
        });
      }
    }
  }

  int _initialSelectedDay() {
    final byDay = {for (final d in widget.week.days) d.day: d};
    for (int dayNum = 1; dayNum <= 7; dayNum++) {
      final day = byDay[dayNum];
      if (day != null && !day.isRestDay) {
        return dayNum;
      }
    }
    if (widget.week.days.isNotEmpty) {
      return widget.week.days.first.day;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final byDay = {for (final d in widget.week.days) d.day: d};

    return Card(
      margin: EdgeInsets.symmetric(vertical: widget.sizes.margins / 2),
      child: ExpansionTile(
        dense: true,
        leading: DetailNumber(
          number: widget.weekNumber,
          theme: widget.theme,
          fontSize: widget.sizes.subtitleFontSize,
        ),
        initiallyExpanded: widget.weekNumber == 1,
        title: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: widget.sizes.subtitleFontSize * 2,
                ),
                Text(
                  ' ${widget.week.startWeek}${widget.week.endWeek > widget.week.startWeek ? ' - ${widget.week.endWeek}' : ''}',
                  style: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (widget.week.phase != null) ...[
              SizedBox(width: widget.sizes.spacing),
              WorkoutPhaseBadge(sizes: widget.sizes, phase: widget.week.phase!),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: widget.sizes.subtitleFontSize * 1.2,
                ),
                Text(
                  ' ${widget.week.totalDays}',
                  style: TextStyle(fontSize: widget.sizes.subtitleFontSize),
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
                    fontSize: widget.sizes.subtitleFontSize * 1.2,
                  ),
                ),
                Text(
                  ' ${widget.week.totalWorkouts}',
                  style: TextStyle(fontSize: widget.sizes.subtitleFontSize),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(widget.sizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.week.startWeek < widget.week.endWeek) ...[
                  WorkoutPlanWeeksStrip(
                    startWeek: widget.week.startWeek,
                    endWeek: widget.week.endWeek,
                    selectedWeek: _selectedWeek,
                    onSelectWeek: (weekNum) {
                      setState(() {
                        _selectedWeek = weekNum;
                      });
                    },
                    sizes: widget.sizes,
                    theme: widget.theme,
                    isDarkTheme: widget.isDarkTheme,
                    getWeekWorkoutCount: (_) => widget.week.totalWorkouts,
                  ),
                  SizedBox(height: widget.sizes.spacing),
                ],
                WorkoutPlanWeekStrip(
                  days: widget.week.days,
                  selectedDay: _selectedDay,
                  onSelectDay: (dayNum) {
                    setState(() {
                      _selectedDay = dayNum;
                    });
                  },
                  sizes: widget.sizes,
                  theme: widget.theme,
                  isDarkTheme: widget.isDarkTheme,
                ),
                SizedBox(height: widget.sizes.spacing),
                _buildSelectedDayDetail(byDay[_selectedDay]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetail(WorkoutPlanDayDto? day) {
    if (day == null) {
      return Container(
        padding: EdgeInsets.all(widget.sizes.padding),
        decoration: BoxDecoration(
          color: widget.isDarkTheme
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
          border: Border.all(
            color: widget.isDarkTheme
                ? Colors.grey.shade800
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.zero,
        ),
        child: Center(
          child: Text(
            'No workout scheduled for Day $_selectedDay',
            style: TextStyle(
              fontSize: widget.sizes.fontSize,
              color: widget.isDarkTheme
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    if (day.isRestDay) {
      return Container(
        padding: EdgeInsets.all(widget.sizes.padding),
        decoration: BoxDecoration(
          color: widget.isDarkTheme
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
          border: Border.all(
            color: widget.isDarkTheme
                ? Colors.grey.shade800
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          children: [
            Icon(
              Icons.snooze,
              size: widget.sizes.subtitleFontSize * 1.5,
              color: widget.isDarkTheme
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
            SizedBox(width: widget.sizes.spacing / 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${day.day} • Rest Day',
                  style: TextStyle(
                    fontSize: widget.sizes.fontSize,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkTheme
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                ),
                Text(
                  'Recovery day',
                  style: TextStyle(
                    fontSize: widget.sizes.smallFontSize,
                    color: widget.isDarkTheme
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...(day.planWorkouts?.map(
              (planWorkout) => WorkoutPlanWorkoutCard(
                isDarkTheme: widget.isDarkTheme,
                sizes: widget.sizes,
                workoutPlanWorkout: planWorkout,
              ),
            ) ??
            []),
      ],
    );
  }
}
