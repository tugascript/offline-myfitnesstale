import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/dtos/exercise_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../common/not_found_list.dart';
import 'exercise_card.dart';

class ExercisesList extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final List<ExerciseDto> exercises;
  final ScrollController? scrollController;

  const ExercisesList({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.exercises,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && exercises.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exercises.isEmpty) {
      return NotFoundList(sizes: sizes, name: 'exercises');
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: exercises.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == exercises.length) {
          return Padding(
            padding: EdgeInsets.all(sizes.padding),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final exercise = exercises[index];
        return ExerciseCard(
          theme: theme,
          exercise: exercise,
          sizes: sizes,
          onTap: () => context.push('/exercises/${exercise.id}'),
        );
      },
    );
  }
}
