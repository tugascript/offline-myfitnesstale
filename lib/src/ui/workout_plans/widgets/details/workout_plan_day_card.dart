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

import 'package:flutter/material.dart';

import '../../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../core/sizes/data_display_sizes.dart';
import './workout_plan_workout_card.dart';

class WorkoutPlanDayCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDarkTheme;
  final DataDisplaySizesList sizes;
  final WorkoutPlanDayDto day;

  const WorkoutPlanDayCard({
    super.key,
    required this.theme,
    required this.isDarkTheme,
    required this.sizes,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return day.isRestDay
        ? _WorkoutPlanRestDay(
            number: day.day,
            isDarkTheme: isDarkTheme,
            fontSize: sizes.subtitleFontSize,
            padding: sizes.padding,
          )
        : _WorkoutPlanWorkoutDay(
            isDarkTheme: isDarkTheme,
            sizes: sizes,
            day: day,
            initiallyExpanded: day.day == 1,
          );
  }
}

class _WorkoutPlanRestDay extends StatelessWidget {
  final int number;
  final bool isDarkTheme;
  final double fontSize;
  final double padding;

  const _WorkoutPlanRestDay({
    required this.number,
    required this.isDarkTheme,
    required this.fontSize,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDarkTheme ? Colors.grey[400] : Colors.grey[600];
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.snooze, color: color, size: fontSize * 2),
              Text(
                " Day $number",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(right: padding),
            child: Icon(
              Icons.do_not_disturb,
              size: fontSize * 1.75,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanWorkoutDay extends StatelessWidget {
  final bool isDarkTheme;
  final DataDisplaySizesList sizes;
  final WorkoutPlanDayDto day;
  final bool initiallyExpanded;

  const _WorkoutPlanWorkoutDay({
    required this.isDarkTheme,
    required this.sizes,
    required this.day,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: sizes.fontSize * 2),
              Text(
                " Day ${day.day}",
                style: TextStyle(
                  fontSize: sizes.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🏋', style: TextStyle(fontSize: sizes.fontSize * 1.2)),
              Text(
                ' ${day.totalWorkouts}',
                style: TextStyle(
                  fontSize: sizes.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      initiallyExpanded: initiallyExpanded,
      children:
          day.planWorkouts
              ?.map(
                (planWorkout) => WorkoutPlanWorkoutCard(
                  isDarkTheme: isDarkTheme,
                  sizes: sizes,
                  workoutPlanWorkout: planWorkout,
                ),
              )
              .toList() ??
          [],
    );
  }
}
