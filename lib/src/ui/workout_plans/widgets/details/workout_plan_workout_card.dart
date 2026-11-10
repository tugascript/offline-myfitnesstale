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
import 'package:go_router/go_router.dart';

import '../../../../data/utils/enums.dart';

import '../../../../routing/routes.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../../data/utils/display_names.dart';

class WorkoutPlanWorkoutCard extends StatelessWidget {
  final bool isDarkTheme;
  final DataDisplaySizesList sizes;
  final WorkoutPlanWorkoutDto workoutPlanWorkout;

  const WorkoutPlanWorkoutCard({
    super.key,
    required this.isDarkTheme,
    required this.sizes,
    required this.workoutPlanWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final lightGrey = isDarkTheme ? Colors.grey[200] : Colors.grey[800];
    final grey = isDarkTheme ? Colors.grey[400] : Colors.grey[600];
    return ListTile(
      leading: Icon(Icons.fitness_center, color: lightGrey),
      title: Text(
        workoutPlanWorkout.workout?.name ?? "Unknown Workout",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: sizes.fontSize,
          color: lightGrey,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.symmetric(vertical: sizes.padding / 4),
        child: _TimeOfDayInfo(
          timeOfDay: workoutPlanWorkout.timeOfDay,
          fontSize: sizes.smallFontSize,
          color: grey,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push(
          Routes.workoutDetail.name.replaceFirst(
            ":id",
            workoutPlanWorkout.workoutId.toString(),
          ),
        );
      },
    );
  }
}

class _TimeOfDayInfo extends StatelessWidget {
  final WorkoutTimeOfDay? timeOfDay;
  final double fontSize;
  final Color? color;

  const _TimeOfDayInfo({
    required this.timeOfDay,
    required this.fontSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_getTimeOfDayIcon(timeOfDay), size: fontSize * 1.2, color: color),
        Text(
          " ${EnumDisplayNames.getTimeOfDayDisplayName(timeOfDay)}",
          style: TextStyle(fontSize: fontSize, color: color),
        ),
      ],
    );
  }

  IconData _getTimeOfDayIcon(WorkoutTimeOfDay? timeOfDay) {
    switch (timeOfDay) {
      case WorkoutTimeOfDay.morning:
        return Icons.wb_sunny_outlined;
      case WorkoutTimeOfDay.afternoon:
        return Icons.wb_sunny;
      case WorkoutTimeOfDay.evening:
        return Icons.cloud;
      case WorkoutTimeOfDay.night:
        return Icons.dark_mode_sharp;
      default:
        return Icons.access_time;
    }
  }
}
