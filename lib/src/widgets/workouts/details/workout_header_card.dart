import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../services/dtos/workout_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/base_details_header.dart';
import '../../common/difficulty_badge.dart';
import '../../common/muscle_group_badge.dart';
import '../../common/muscles_wrap.dart';
import '../../common/total_numeric_string.dart';

// TODO: add versioning
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
              child: DifficultyBadge(
                spacing: sizes.spacing,
                difficulty: workoutDto.difficulty,
                fontSize: sizes.smallFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              key: ValueKey(
                actionButtonIcon == null
                    ? 'workout-favorite'
                    : 'workout-header-edit',
              ),
              icon: actionButtonIcon ??
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
        Row(
          children: [
            Expanded(
              child: TotalNumericString(
                leading: Icon(Icons.repeat, size: sizes.fontSize * 1.2),
                name: 'Sets',
                total: workoutDto.totalSets,
                fontSize: sizes.fontSize,
              ),
            ),
            Expanded(
              child: TotalNumericString(
                leading: Icon(Icons.repeat_one, size: sizes.fontSize * 1.2),
                name: 'Reps',
                total: workoutDto.totalReps,
                fontSize: sizes.fontSize,
              ),
            )
          ],
        ),
        SizedBox(
          height: sizes.spacing,
        ),
        MusclesWrap(
          leading: Text(
            '💪',
            style: TextStyle(fontSize: sizes.subtitleFontSize * 1.2),
          ),
          title: 'Primary Muscles',
          sizes: sizes,
          muscles: workoutDto.muscles.primary,
          theme: theme,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MuscleGroups(
                sizes: sizes,
                muscleGroups: workoutDto.muscleGroups,
                theme: theme,
              ),
            ),
            Expanded(
              child: MusclesWrap(
                leading: Text(
                  '🥈',
                  style: TextStyle(fontSize: sizes.subtitleFontSize * 1.2),
                ),
                title: 'Secondary Muscles',
                sizes: sizes,
                muscles: workoutDto.muscles.secondary,
                theme: theme,
              ),
            ),
          ],
        ),
        if (workoutDto.description != null &&
            workoutDto.description!.isNotEmpty) ...[
          SizedBox(
            height: sizes.spacing,
          ),
          Text(
            'Description',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: sizes.spacing / 2,
          ),
          Wrap(
            spacing: sizes.spacing / 2,
            runSpacing: sizes.spacing / 2,
            children: [
              Text(
                workoutDto.description!,
                style: TextStyle(
                  fontSize: sizes.fontSize,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MuscleGroups extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Set<MuscleGroup> muscleGroups;
  final ThemeData theme;

  const _MuscleGroups({
    required this.sizes,
    required this.muscleGroups,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dataSpacing = sizes.spacing / 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '🏋️',
              style: TextStyle(fontSize: sizes.subtitleFontSize * 1.2),
            ),
            Text(
              ' Muscle Groups',
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(
          height: sizes.spacing / 2,
        ),
        Wrap(
          spacing: dataSpacing,
          runSpacing: dataSpacing,
          children: muscleGroups.map((mg) {
            return MuscleGroupBadge(
              muscleGroup: mg,
              fontSize: sizes.smallFontSize,
              theme: theme,
            );
          }).toList(),
        ),
      ],
    );
  }
}
