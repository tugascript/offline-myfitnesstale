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

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../data/utils/enums.dart';
import '../../../data/utils/exercise_details.dart';
import '../../../data/utils/json_data.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/not_found_list.dart';
import './exercise_card.dart';

const _skeletonStrengthExercise = ExerciseDto(
  id: 0,
  name: 'Loading Exercise Name...',
  description: '',
  details: StrengthExerciseDetails(
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    weightProgress: ExerciseWeightProgress.positive,
  ),
  difficulty: Difficulty.beginner,
  isFavorite: false,
  createdBy: CreatedBy.system,
);

const _skeletonCardioExercise = ExerciseDto(
  id: 0,
  name: 'Loading Cardio Exercise...',
  description: '',
  details: CardioExerciseDetails(
    defaultMode: CardioBaseMode.time,
    unitType: CardioUnitType.distance,
    unit: 'km',
  ),
  difficulty: Difficulty.beginner,
  isFavorite: false,
  createdBy: CreatedBy.system,
);

void _noopTap() {}

class ExercisesList extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final bool isReloading;
  final ExerciseType skeletonType;
  final List<ExerciseDto> exercises;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? emptyHeight;

  const ExercisesList({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    this.isReloading = false,
    this.skeletonType = ExerciseType.strength,
    required this.exercises,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
    this.emptyHeight,
  });

  @override
  Widget build(BuildContext context) {
    final showSkeletonList = isReloading || (isLoading && exercises.isEmpty);

    if (!showSkeletonList && exercises.isEmpty) {
      return NotFoundList(sizes: sizes, name: 'exercises', height: emptyHeight);
    }

    final skeletonExercise = skeletonType == ExerciseType.cardio
        ? _skeletonCardioExercise
        : _skeletonStrengthExercise;

    final listView = ListView.builder(
      controller: scrollController,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: showSkeletonList ? 3 : exercises.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (showSkeletonList) {
          return ExerciseCard(
            theme: theme,
            exercise: skeletonExercise,
            sizes: sizes,
            onTap: _noopTap,
          );
        }

        if (index == exercises.length) {
          return Skeletonizer(
            enabled: true,
            child: ExerciseCard(
              theme: theme,
              exercise: skeletonExercise,
              sizes: sizes,
              onTap: _noopTap,
            ),
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

    if (showSkeletonList) {
      return Skeletonizer(enabled: true, child: listView);
    }

    return listView;
  }
}
