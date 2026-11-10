// Copyright (C) 2026 afonsobarracha
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

import '../../../data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import './workout_plan_card.dart';

class WorkoutPlansList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final List<WorkoutPlanDto> workoutPlans;
  final ScrollController? scrollController;

  const WorkoutPlansList({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.workoutPlans,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && workoutPlans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (workoutPlans.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: sizes.margins),
              Icon(
                Icons.calendar_today,
                size: sizes.titleFontSize * 3,
                color: Colors.grey[400],
              ),
              SizedBox(height: sizes.margins),
              Text(
                'No workout plans found',
                style: TextStyle(
                  fontSize: sizes.titleFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: workoutPlans.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == workoutPlans.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final plan = workoutPlans[index];
        return WorkoutPlanCard(
          plan: plan,
          sizes: sizes,
          onTap: () => context.push('/workout-plans/${plan.id}'),
        );
      },
    );
  }
}
