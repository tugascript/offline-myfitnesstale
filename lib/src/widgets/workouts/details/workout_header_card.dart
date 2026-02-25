import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../services/dtos/workout_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/base_details_header.dart';
import '../../common/difficulty_badge.dart';
import '../../common/muscle_badge.dart';
import '../../common/muscle_group_badge.dart';
import '../../common/total_numeric_string.dart';

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
                emoji: '🔁',
                name: 'Sets',
                total: workoutDto.totalSets,
                fontSize: sizes.fontSize,
              ),
            ),
            Expanded(
              child: TotalNumericString(
                emoji: '🔂',
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
        _MuscleData(
          sizes: sizes,
          muscleGroups: workoutDto.muscleGroups,
          muscles: workoutDto.muscles,
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

class _MuscleData extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Set<MuscleGroup> muscleGroups;
  final Set<Muscle> muscles;

  const _MuscleData({
    required this.sizes,
    required this.muscleGroups,
    required this.muscles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (muscleGroups.isEmpty && muscles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (muscleGroups.isNotEmpty) ...[
          Expanded(
            child: _MuscleGroups(
              sizes: sizes,
              muscleGroups: muscleGroups,
              theme: theme,
            ),
          ),
        ],
        if (muscleGroups.isNotEmpty && muscles.isNotEmpty) ...[
          SizedBox(
            width: sizes.spacing,
          ),
        ],
        if (muscles.isNotEmpty) ...[
          Expanded(
            child: _Muscles(
              sizes: sizes,
              muscles: muscles,
              theme: theme,
            ),
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
        Text(
          '🏋️‍♂️ Muscle Groups',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.w600,
          ),
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

class _Muscles extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Set<Muscle> muscles;
  final ThemeData theme;

  const _Muscles({
    required this.sizes,
    required this.muscles,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dataSpacing = sizes.spacing / 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💪 Muscles',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: sizes.spacing / 2,
        ),
        Wrap(
          spacing: dataSpacing,
          children: muscles.map((m) {
            return MuscleBadge(
              muscle: m,
              fontSize: sizes.smallFontSize,
              theme: theme,
            );
          }).toList(),
        ),
      ],
    );
  }
}
