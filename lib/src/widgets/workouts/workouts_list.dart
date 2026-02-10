import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/states/workout_state.dart';
import '../../services/dtos/workout_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../views/workouts/workout_detail_view.dart';
import '../common/not_found_list.dart';
import 'workout_card.dart';

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
            WorkoutDetailView.routeName.replaceFirst(
              ":id",
              workout.id.toString(),
            ),
          ),
        );
      },
    );
  }
}
