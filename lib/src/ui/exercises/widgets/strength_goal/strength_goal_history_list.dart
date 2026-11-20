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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../data/repositories/exercises/dtos/strength_goal_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/json_data.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/not_found_list.dart';
import '../../../home/view_models/profile_cubit.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import 'strength_goal_history_card.dart';

final _skeletonHistoryGoal = StrengthGoalDto(
  id: 0,
  name: 'Loading Strength Goal...',
  targetReps: 5,
  targetWeight: 100000,
  targetMaxStrength: 116667,
  exerciseId: 0,
  status: ProgressStatus.completed,
  startDate: DateTime(2026, 1, 1),
  completedAt: DateTime(2026, 1, 15),
  exercise: const ExerciseDto(
    id: 0,
    name: 'Loading Exercise Name...',
    description: '',
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    createdBy: CreatedBy.system,
  ),
);

class StrengthGoalHistoryList extends StatelessWidget {
  final ThemeData theme;
  final bool shrinkWrap;
  final DataDisplaySizesList sizes;
  final Units? units;
  final ScrollController? scrollController;

  const StrengthGoalHistoryList({
    super.key,
    this.shrinkWrap = false,
    required this.theme,
    required this.sizes,
    this.units,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUnits =
        units ??
        context.watch<ProfileCubit>().state.system?.units ??
        Units.metric;

    return BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
      builder: (context, state) {
        final history = state.strengthGoals
            .where((g) => g.id != state.activeStrengthGoal?.id)
            .toList();
        final isInitialLoading = state.isLoading && history.isEmpty;

        if (!isInitialLoading && history.isEmpty) {
          return NotFoundList(
            sizes: sizes,
            message: 'Empty history',
            icon: Icons.history,
          );
        }

        final hasMore =
            state.strengthGoals.length < state.strengthGoalPagination.total;
        final showLoadingMore =
            state.isLoading &&
            !isInitialLoading &&
            history.isNotEmpty &&
            hasMore;

        return Skeletonizer(
          enabled: isInitialLoading,
          child: ListView.builder(
            controller: scrollController,
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
            itemCount: isInitialLoading
                ? 3
                : history.length + (showLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (isInitialLoading) {
                return StrengthGoalHistoryCard(
                  theme: theme,
                  sizes: sizes,
                  units: effectiveUnits,
                  goal: _skeletonHistoryGoal,
                  isSkeleton: true,
                );
              }

              if (index == history.length) {
                return Skeletonizer(
                  enabled: true,
                  child: StrengthGoalHistoryCard(
                    theme: theme,
                    sizes: sizes,
                    units: effectiveUnits,
                    goal: _skeletonHistoryGoal,
                    isSkeleton: true,
                  ),
                );
              }

              return StrengthGoalHistoryCard(
                theme: theme,
                sizes: sizes,
                units: effectiveUnits,
                goal: history[index],
              );
            },
          ),
        );
      },
    );
  }
}
