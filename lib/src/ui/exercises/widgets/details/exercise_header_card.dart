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
