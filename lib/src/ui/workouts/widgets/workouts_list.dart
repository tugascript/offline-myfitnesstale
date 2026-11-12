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

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/not_found_list.dart';
import '../view_models/states/workout_state.dart';
import './workout_card.dart';

class WorkoutsList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final List<WorkoutDto> workouts;
  final WorkoutPagination pagination;
  final ScrollController? scrollController;

  const WorkoutsList({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.workouts,
    required this.pagination,
    this.scrollController,
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
      controller: scrollController,
      // Remove shrinkWrap and physics to allow normal scrolling behavior in Expanded
      itemCount: workouts.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == workouts.length) {
          return Padding(
            padding: EdgeInsets.all(sizes.padding),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final workout = workouts[index];
        return WorkoutCard(
          workout: workout,
          sizes: sizes,
          onTap: () => context.push(
            Routes.workoutDetail.name.replaceFirst(
              ":id",
              workout.id.toString(),
            ),
          ),
        );
      },
    );
  }
}
