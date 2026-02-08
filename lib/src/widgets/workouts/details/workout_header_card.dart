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

  const WorkoutHeaderCard({
    super.key,
    required this.sizes,
    required this.workoutDto,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDetailsHeader(
      padding: sizes.padding,
      children: [
        Row(
          children: [
            Expanded(
              child: DifficultyBadge(
                spacing: sizes.spacing,
                difficulty: workoutDto.difficulty,
                fontSize: sizes.smallFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: sizes.spacing,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TotalNumericString(
                    name: 'Sets',
                    total: workoutDto.totalSets,
                    fontSize: sizes.fontSize,
                  ),
                  SizedBox(
                    height: sizes.spacing / 2,
                  ),
                  TotalNumericString(
                    name: 'Reps',
                    total: workoutDto.totalReps,
                    fontSize: sizes.fontSize,
                  ),
                ],
              ),
            ),
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
