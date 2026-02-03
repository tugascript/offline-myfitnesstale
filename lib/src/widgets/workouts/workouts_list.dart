import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/states/workout_state.dart';
import '../../services/dtos/workout_dto.dart';
import '../../utilities/sizes/workouts_sizes.dart';
import '../../views/workout_detail_view.dart';
import 'workout_card.dart';

class WorkoutsList extends StatelessWidget {
  final WorkoutsSizesList sizes;
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
      return SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: sizes.gridSpacing),
              Icon(
                Icons.fitness_center,
                size: sizes.bigIcon,
                color: Colors.grey[400],
              ),
              SizedBox(height: sizes.gridSpacing),
              Text(
                'No workouts found',
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
      // Remove shrinkWrap and physics to allow normal scrolling behavior in Expanded
      itemCount: workouts.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == workouts.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
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
