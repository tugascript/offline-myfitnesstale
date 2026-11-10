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

import '../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/difficulty_badge.dart';
import '../../core/widgets/modal_search/modal_search_entity_name.dart';
import '../../core/widgets/muscle_group_badge.dart';
import '../../core/widgets/layout/list_card.dart';

class ExerciseCard extends StatelessWidget {
  final ThemeData theme;
  final ExerciseDto exercise;
  final VoidCallback onTap;
  final DataDisplaySizesList sizes;

  const ExerciseCard({
    super.key,
    required this.theme,
    required this.exercise,
    required this.onTap,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.margins / 2,
      padding: sizes.padding,
      onTap: onTap,
      children: [
        ModalSearchEntityName(
          name: exercise.name,
          isFavorite: exercise.isFavorite,
          fontSize: sizes.subtitleFontSize,
        ),
        SizedBox(height: sizes.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: sizes.spacing,
                runSpacing: sizes.spacing / 2,
                children: [
                  DifficultyBadge(
                    difficulty: exercise.difficulty,
                    spacing: sizes.padding / 2,
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  MuscleGroupBadge(
                    muscleGroup: exercise.muscleGroup,
                    fontSize: sizes.fontSize,
                    theme: theme,
                  ),
                ],
              ),
            ),
            SizedBox(width: sizes.spacing),
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.fontSize * 1.2,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
