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

import '../../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/modal_search/modal_search_card.dart';
import '../../../../core/widgets/not_found_list.dart';

class WorkoutPlanWorkoutSearchList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final List<WorkoutDto> workouts;
  final void Function(WorkoutDto workout) onWorkoutSelected;

  const WorkoutPlanWorkoutSearchList({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.workouts,
    required this.onWorkoutSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && workouts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (workouts.isEmpty) {
      return NotFoundList(sizes: sizes, name: 'workouts');
    }

    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return ModalSearchCard(
          name: workout.name,
          isFavorite: workout.isFavorite,
          margins: sizes.margins / 2,
          padding: sizes.padding / 2,
          fontSize: sizes.smallFontSize,
          onTap: () => onWorkoutSelected(workout),
        );
      },
    );
  }
}
