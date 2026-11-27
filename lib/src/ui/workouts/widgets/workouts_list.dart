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

import '../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../data/utils/enums.dart';
import '../../../data/utils/json_data.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/not_found_list.dart';
import '../view_models/states/workout_state.dart';
import './workout_card.dart';

const _skeletonWorkout = WorkoutDto(
  id: 0,
  name: 'Loading Workout Name...',
  muscleGroups: {MuscleGroup.push, MuscleGroup.legs},
  muscles: TargetMuscles(primary: {}, secondary: {}),
  difficulty: Difficulty.beginner,
  version: 1,
  isFavorite: false,
  totalSets: 4,
  totalReps: 40,
  editorType: EditorType.advanced,
  createdBy: CreatedBy.system,
);

const _skeletonCardioWorkout = WorkoutDto(
  id: 0,
  name: 'Loading Cardio Workout...',
  muscleGroups: {},
  muscles: TargetMuscles(primary: {}, secondary: {}),
  difficulty: Difficulty.beginner,
  version: 1,
  isFavorite: false,
  totalSets: 4,
  totalReps: 0,
  editorType: EditorType.cardio,
  createdBy: CreatedBy.system,
);

void _noopTap() {}

class WorkoutsList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final bool isReloading;
  final ExerciseType skeletonType;
  final List<WorkoutDto> workouts;
  final WorkoutPagination pagination;
  final ScrollController? scrollController;

  const WorkoutsList({
    super.key,
    required this.sizes,
    required this.isLoading,
    this.isReloading = false,
    this.skeletonType = ExerciseType.strength,
    required this.workouts,
    required this.pagination,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final showSkeletonList = isReloading || (isLoading && workouts.isEmpty);

    if (!showSkeletonList && workouts.isEmpty) {
      return NotFoundList(sizes: sizes, name: 'workouts');
    }

    final skeletonWorkout = skeletonType == ExerciseType.cardio
        ? _skeletonCardioWorkout
        : _skeletonWorkout;

    final listView = ListView.builder(
      controller: scrollController,
      // Remove shrinkWrap and physics to allow normal scrolling behavior in Expanded
      itemCount: showSkeletonList ? 3 : workouts.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (showSkeletonList) {
          return WorkoutCard(
            workout: skeletonWorkout,
            sizes: sizes,
            onTap: _noopTap,
          );
        }

        if (index == workouts.length) {
          return Skeletonizer(
            enabled: true,
            child: WorkoutCard(
              workout: skeletonWorkout,
              sizes: sizes,
              onTap: _noopTap,
            ),
          );
        }

        final workout = workouts[index];
        return WorkoutCard(
          workout: workout,
          sizes: sizes,
          onTap: () => context.push(
            Routes.workoutDetail.name.replaceFirst(
              ":id",
              workout.id.toString(),
            ),
          ),
        );
      },
    );

    if (showSkeletonList) {
      return Skeletonizer(enabled: true, child: listView);
    }

    return listView;
  }
}
