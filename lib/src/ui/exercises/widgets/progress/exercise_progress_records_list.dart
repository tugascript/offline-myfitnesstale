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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/json_data.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/not_found_list.dart';
import '../../view_models/states/exercise_record_state.dart';
import './exercise_progress_record_card.dart';

final _skeletonExerciseRecord = ExerciseRecordDto(
  id: 0,
  exerciseId: 0,
  weight: 100000,
  reps: 8,
  maxStrength: 126667,
  recordDate: DateTime(2026, 1, 1),
  exercise: const ExerciseDto(
    id: 0,
    name: 'Loading Exercise Name...',
    description: '',
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    createdBy: CreatedBy.system,
  ),
);

void _noopTap(int _) {}

class ExerciseProgressRecordsList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Units units;
  final bool isLoading;
  final List<ExerciseRecordDto> exerciseRecords;
  final ExerciseRecordPagination pagination;
  final ScrollController? scrollController;
  final ValueChanged<int> onTapExercise;

  const ExerciseProgressRecordsList({
    super.key,
    required this.sizes,
    required this.units,
    required this.isLoading,
    required this.exerciseRecords,
    required this.pagination,
    this.scrollController,
    required this.onTapExercise,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && exerciseRecords.isEmpty) {
      return NotFoundList(
        sizes: sizes,
        message: 'No exercise records found',
        icon: Icons.history,
      );
    }

    final isInitialLoading = isLoading && exerciseRecords.isEmpty;
    final hasMore = exerciseRecords.length < pagination.total;
    final showLoadingMore =
        isLoading && !isInitialLoading && exerciseRecords.isNotEmpty && hasMore;

    return Skeletonizer(
      enabled: isInitialLoading,
      child: ListView.builder(
        controller: scrollController,
        itemCount: isInitialLoading
            ? 3
            : exerciseRecords.length + (showLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (isInitialLoading) {
            return ExerciseProgressRecordCard(
              sizes: sizes,
              units: units,
              record: _skeletonExerciseRecord,
              onTapExercise: _noopTap,
            );
          }

          if (index == exerciseRecords.length) {
            return Skeletonizer(
              enabled: true,
              child: ExerciseProgressRecordCard(
                sizes: sizes,
                units: units,
                record: _skeletonExerciseRecord,
                onTapExercise: _noopTap,
              ),
            );
          }

          return ExerciseProgressRecordCard(
            sizes: sizes,
            units: units,
            record: exerciseRecords[index],
            onTapExercise: onTapExercise,
          );
        },
      ),
    );
  }
}
