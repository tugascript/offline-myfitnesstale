import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/dtos/exercise_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../common/difficulty_badge.dart';
import '../common/muscle_badge.dart';
import '../common/muscle_group_badge.dart';
import '../layout/list_card.dart';
import '../common/modal_search/modal_search_entity_name.dart';

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
      margin: sizes.margins,
      padding: sizes.padding,
      onTap: onTap,
      children: [
        ModalSearchEntityName(
          name: exercise.name,
          isFavorite: exercise.isFavorite,
          fontSize: sizes.subtitleFontSize,
        ),
        SizedBox(height: sizes.spacing),
        _ExerciseInfo(
          muscleGroup: exercise.muscleGroup,
          primaryMuscles: exercise.muscles.primaryMuscles,
          sizes: sizes,
          theme: theme,
        ),
        SizedBox(height: sizes.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DifficultyBadge(
              difficulty: exercise.difficulty,
              spacing: sizes.padding / 2,
              fontSize: sizes.fontSize,
              fontWeight: FontWeight.w600,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.fontSize * 1.2,
              color: Colors.grey,
            )
          ],
        ),
      ],
    );
  }
}

class _ExerciseInfo extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MuscleGroup muscleGroup;
  final Set<Muscle> primaryMuscles;

  const _ExerciseInfo({
    required this.theme,
    required this.sizes,
    required this.muscleGroup,
    required this.primaryMuscles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MuscleGroupBadge(
                muscleGroup: muscleGroup,
                fontSize: sizes.fontSize,
                theme: theme,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(right: sizes.padding / 2),
            child: Wrap(
              spacing: sizes.spacing / 4,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: primaryMuscles.map((mg) {
                return MuscleBadge(
                  muscle: mg,
                  fontSize: sizes.smallFontSize,
                  theme: theme,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
