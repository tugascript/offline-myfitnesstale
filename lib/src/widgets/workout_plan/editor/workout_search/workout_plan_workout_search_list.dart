import 'package:flutter/material.dart';

import '../../../../services/dtos/workout_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/modal_search/modal_search_card.dart';
import '../../../common/not_found_list.dart';

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
