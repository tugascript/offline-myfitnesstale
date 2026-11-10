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

import '../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/not_found_list.dart';
import './exercise_card.dart';

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
