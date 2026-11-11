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

import '../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/base_details_header.dart';
import '../../../core/widgets/difficulty_badge.dart';
import '../../../core/widgets/muscles_carousel.dart';
import '../../../core/widgets/total_numeric_string.dart';

class WorkoutHeaderCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutDto workoutDto;
  final Widget? actionButtonIcon;
  final VoidCallback actionButtonPress;

  const WorkoutHeaderCard({
    super.key,
    required this.sizes,
    required this.workoutDto,
    this.actionButtonIcon,
    required this.actionButtonPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseDetailsHeader(
      padding: sizes.padding,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sizes.spacing),
              child: Icon(
                workoutDto.createdBy == CreatedBy.user
                    ? Icons.person
                    : Icons.public,
                color: workoutDto.createdBy == CreatedBy.user
                    ? Colors.blue
                    : Colors.grey,
              ),
            ),
            Expanded(
              child: Wrap(
                spacing: sizes.spacing,
                runSpacing: sizes.spacing / 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DifficultyBadge(
                    spacing: sizes.spacing,
                    difficulty: workoutDto.difficulty,
                    fontSize: sizes.smallFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  Text(
                    'Version ${workoutDto.version}',
                    style: TextStyle(
                      fontSize: sizes.smallFontSize,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: ValueKey(
                actionButtonIcon == null
                    ? 'workout-favorite'
                    : 'workout-header-edit',
              ),
              icon:
                  actionButtonIcon ??
                  Icon(
                    workoutDto.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: workoutDto.isFavorite ? Colors.red : null,
                  ),
              onPressed: actionButtonPress,
              tooltip: workoutDto.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
            ),
          ],
        ),
        Wrap(
          spacing: sizes.spacing,
          runSpacing: sizes.spacing / 2,
          children: [
            TotalNumericString(
              leading: Icon(Icons.repeat, size: sizes.fontSize * 1.2),
              name: 'Sets',
              total: workoutDto.totalSets,
              fontSize: sizes.fontSize,
            ),
            TotalNumericString(
              leading: Icon(Icons.repeat_one, size: sizes.fontSize * 1.2),
              name: 'Reps',
              total: workoutDto.totalReps,
              fontSize: sizes.fontSize,
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        MusclesCarousel(
          sizes: sizes,
          theme: theme,
          muscleGroups: workoutDto.muscleGroups,
          muscles: workoutDto.muscles,
        ),
        if (workoutDto.description != null &&
            workoutDto.description!.isNotEmpty) ...[
          SizedBox(height: sizes.spacing),
          Text(
            'Description',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sizes.spacing / 2),
          Wrap(
            spacing: sizes.spacing / 2,
            runSpacing: sizes.spacing / 2,
            children: [
              Text(
                workoutDto.description!,
                style: TextStyle(fontSize: sizes.fontSize),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
