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

import '../../../data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/difficulty_badge.dart';
import '../../core/widgets/total_numeric_string.dart';
import '../../core/widgets/layout/list_card.dart';

class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlanDto plan;
  final DataDisplaySizesList sizes;
  final VoidCallback onTap;

  const WorkoutPlanCard({
    super.key,
    required this.plan,
    required this.sizes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.margins / 2,
      padding: sizes.padding,
      onTap: onTap,
      children: [
        Text(
          plan.name,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        Padding(
          padding: EdgeInsets.only(right: sizes.padding),
          child: Wrap(
            spacing: sizes.spacing,
            runSpacing: sizes.spacing,
            children: [
              TotalNumericString(
                leading: Text(
                  '📅',
                  style: TextStyle(fontSize: sizes.fontSize * 1.2),
                ),
                name: "Weeks",
                total: plan.totalWeeks,
                fontSize: sizes.fontSize,
              ),
              TotalNumericString(
                leading: Text(
                  '☀️',
                  style: TextStyle(fontSize: sizes.fontSize * 1.2),
                ),
                name: "Days",
                total: plan.totalDays,
                fontSize: sizes.fontSize,
              ),
              TotalNumericString(
                leading: Text(
                  '🏋️',
                  style: TextStyle(fontSize: sizes.fontSize * 1.2),
                ),
                name: "Workouts",
                total: plan.totalWorkouts,
                fontSize: sizes.fontSize,
              ),
            ],
          ),
        ),
        SizedBox(height: sizes.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DifficultyBadge(
              difficulty: plan.difficulty,
              spacing: sizes.padding / 2,
              fontSize: sizes.fontSize,
              fontWeight: FontWeight.w600,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.fontSize * 1.2,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
