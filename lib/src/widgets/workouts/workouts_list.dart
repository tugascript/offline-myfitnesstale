import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/states/workout_state.dart';
import '../../models/workout_model.dart';
import '../../utilities/sizes/workouts_sizes.dart';
import 'workout_card.dart';

class WorkoutsList extends StatefulWidget {
  final WorkoutsSizesList sizes;
  final bool isLoading;
  final List<Workout> workouts;
  final WorkoutPagination pagination;

  const WorkoutsList({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.workouts,
    required this.pagination,
  });

  @override
  State<WorkoutsList> createState() => _WorkoutsListState();
}

class _WorkoutsListState extends State<WorkoutsList> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.workouts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.workouts.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: widget.sizes.gridSpacing),
              Icon(
                Icons.fitness_center,
                size: widget.sizes.bigIcon,
                color: Colors.grey[400],
              ),
              SizedBox(height: widget.sizes.gridSpacing),
              Text(
                'No workouts found',
                style: TextStyle(
                  fontSize: widget.sizes.titleFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.workouts.length,
      itemBuilder: (context, index) {
        final workout = widget.workouts[index];
        return WorkoutCard(
          workout: workout,
          sizes: widget.sizes,
          onTap: () => context.push('/workouts/${workout.id}'),
        );
      },
    );
  }
}
