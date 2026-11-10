import 'package:flutter/material.dart';

import '../../../data/utils/enums.dart';
import '../../../services/dtos/workout_dto.dart';
import '../../../ui/core/sizes/data_display_sizes.dart';
import '../../../ui/core/widgets/base_details_header.dart';
import '../../../ui/core/widgets/difficulty_badge.dart';
import '../../../ui/core/widgets/muscles_carousel.dart';
import '../../../ui/core/widgets/total_numeric_string.dart';

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
