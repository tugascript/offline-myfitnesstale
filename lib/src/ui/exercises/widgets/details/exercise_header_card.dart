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

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/base_details_header.dart';
import '../../../core/widgets/difficulty_badge.dart';
import '../../../core/widgets/muscles_carousel.dart';

class ExerciseHeaderCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ExerciseDto exerciseDto;
  final VoidCallback onFavoriteToggle;
  final ThemeData? theme;

  const ExerciseHeaderCard({
    super.key,
    required this.sizes,
    required this.exerciseDto,
    required this.onFavoriteToggle,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? Theme.of(context);

    return BaseDetailsHeader(
      padding: sizes.padding,
      children: [
        Row(
          children: [
            Expanded(
              child: DifficultyBadge(
                spacing: sizes.spacing,
                difficulty: exerciseDto.difficulty,
                fontSize: sizes.smallFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: Icon(
                exerciseDto.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: exerciseDto.isFavorite ? Colors.red : null,
              ),
              onPressed: onFavoriteToggle,
              tooltip: exerciseDto.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        MusclesCarousel(
          sizes: sizes,
          theme: resolvedTheme,
          muscleGroup: exerciseDto.muscleGroup,
          muscles: exerciseDto.muscles,
          equipments: exerciseDto.equipments ?? const [],
        ),
        if (exerciseDto.description.isNotEmpty) ...[
          SizedBox(height: sizes.spacing),
          Text(
            'Description',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sizes.spacing / 2),
          Text(
            exerciseDto.description,
            style: TextStyle(fontSize: sizes.fontSize),
          ),
        ],
      ],
    );
  }
}
