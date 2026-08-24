import 'package:flutter/material.dart';

import '../../../../services/dtos/exercise_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/modal_search/modal_search_card.dart';
import '../../../common/not_found_list.dart';

class SetExerciseSearchList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final List<ExerciseDto> exercises;
  final ValueChanged<ExerciseDto> onExerciseSelected;

  const SetExerciseSearchList({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.exercises,
    required this.onExerciseSelected,
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
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ModalSearchCard(
          name: exercise.name,
          isFavorite: exercise.isFavorite,
          margins: sizes.margins / 2,
          padding: sizes.padding / 2,
          fontSize: sizes.smallFontSize,
          onTap: () => onExerciseSelected(exercise),
        );
      },
    );
  }
}
