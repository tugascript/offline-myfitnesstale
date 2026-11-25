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

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/sizes/screen_size.dart';
import '../../../core/widgets/layout/app_text_button.dart';
import '../../../core/widgets/layout/empty_card.dart';
import '../../../core/widgets/not_found_list.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import './strength_goal_history_list.dart';

class StrengthGoalHistory extends StatefulWidget {
  final ThemeData theme;
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;
  final Units units;

  const StrengthGoalHistory({
    super.key,
    required this.theme,
    required this.breakPoint,
    required this.sizes,
    required this.units,
  });

  @override
  State<StrengthGoalHistory> createState() => _StrengthGoalHistoryState();
}

class _StrengthGoalHistoryState extends State<StrengthGoalHistory> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final cubit = context.read<ExerciseRecordCubit>();
    final state = cubit.state;
    final isNearBottom =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent * 0.9;
    final hasMore =
        state.strengthGoals.length < state.strengthGoalPagination.total;

    if (isNearBottom && hasMore && !state.isGoalsLoading) {
      cubit.getStrengthGoals(
        exerciseId: state.strengthGoalPagination.exerciseId,
        skipInProgress: state.strengthGoalPagination.skipInProgress,
        limit: state.strengthGoalPagination.limit,
        offset: state.strengthGoals.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal History',
          style: TextStyle(
            fontSize: widget.sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: widget.sizes.spacing),
        BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
          builder: (context, state) {
            final history = state.strengthGoals
                .where((g) => g.id != state.activeStrengthGoal?.id)
                .toList();

            if (!state.isGoalsLoading &&
                history.isEmpty &&
                state.goalsError != null) {
              return EmptyCard(
                sizes: widget.sizes,
                emoji: '⚠️',
                emptyText: 'Could not load strength goals history',
                actions: [
                  AppTextButton(
                    key: const ValueKey('strength-goal-history-retry'),
                    isLoading: false,
                    sizes: widget.sizes,
                    isDense: true,
                    label: 'Retry',
                    icon: Icons.refresh,
                    onPressed: () {
                      final pagination = state.strengthGoalPagination;
                      context.read<ExerciseRecordCubit>().getStrengthGoals(
                        exerciseId: pagination.exerciseId,
                        skipInProgress: pagination.skipInProgress,
                        limit: pagination.limit,
                        offset: 0,
                      );
                    },
                  ),
                ],
              );
            }

            if (!state.isGoalsLoading && history.isEmpty) {
              return NotFoundList(
                height: widget.breakPoint.height / 3,
                sizes: widget.sizes,
                message: 'Empty history',
                icon: Icons.history,
              );
            }

            return SizedBox(
              height: widget.breakPoint.height / 2,
              child: StrengthGoalHistoryList(
                theme: widget.theme,
                sizes: widget.sizes,
                units: widget.units,
                scrollController: _scrollController,
              ),
            );
          },
        ),
      ],
    );
  }
}
