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

import 'package:material_ui/material_ui.dart';

import '../../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/modal_search/modal_search_card.dart';
import '../../../../core/widgets/not_found_list.dart';

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
