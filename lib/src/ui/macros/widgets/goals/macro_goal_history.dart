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

import '../../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/layout/app_text_button.dart';
import '../../../core/widgets/layout/empty_card.dart';
import '../../view_models/macro_tracking_cubit.dart';

const List<MacroGoalDto> _skeletonHistoryGoals = [
  MacroGoalDto(
    id: -1,
    name: 'Previous Macro Goal',
    targetCalories: 2200,
    targetProtein: 165,
    targetCarbs: 220,
    targetFat: 70,
    targetWaterIntakeMl: 2500,
    isActive: false,
    phase: WeightGoalPhase.maintain,
  ),
  MacroGoalDto(
    id: -2,
    name: 'Earlier Macro Goal',
    targetCalories: 2000,
    targetProtein: 150,
    targetCarbs: 200,
    targetFat: 65,
    targetWaterIntakeMl: 2500,
    isActive: false,
    phase: WeightGoalPhase.maintain,
  ),
];

class MacroGoalHistory extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final List<MacroGoalDto> goals;
  final int? activeGoalId;
  final bool isLoading;
  final bool hasLoaded;
  final bool hasError;
  final VoidCallback? onRetry;

  const MacroGoalHistory({
    super.key,
    required this.sizes,
    required this.goals,
    this.activeGoalId,
    this.isLoading = false,
    this.hasLoaded = true,
    this.hasError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final history = goals.where((g) => g.id != activeGoalId).toList();
    final showSkeleton =
        isLoading || (!hasLoaded && !hasError && history.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Goal History',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        if (showSkeleton && history.isEmpty)
          Skeletonizer(
            enabled: true,
            child: _buildHistoryList(
              context,
              _skeletonHistoryGoals,
              isSkeleton: true,
            ),
          )
        else if (!isLoading && hasError && history.isEmpty)
          EmptyCard(
            sizes: sizes,
            emoji: '⚠️',
            emptyText: 'Could not load macro goal history',
            actions: [
              if (onRetry != null)
                AppTextButton(
                  key: const ValueKey('macro-goal-history-retry'),
                  isLoading: false,
                  sizes: sizes,
                  isDense: true,
                  label: 'Retry',
                  icon: Icons.refresh,
                  onPressed: onRetry,
                ),
            ],
          )
        else if (history.isEmpty)
          Center(
            child: Text(
              'No past macro goals.',
              style: TextStyle(fontSize: sizes.fontSize, color: Colors.grey),
            ),
          )
        else
          Skeletonizer(
            enabled: isLoading,
            child: _buildHistoryList(context, history, isSkeleton: isLoading),
          ),
      ],
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<MacroGoalDto> items, {
    required bool isSkeleton,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: sizes.spacing / 2),
      itemBuilder: (context, index) {
        final g = items[index];

        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: Text(
              '${g.goalType == MacroGoalType.calorieCycling ? 'Daily Average: ' : ''}'
              '${g.targetCalories} kcal • P: ${g.targetProtein}g C: ${g.targetCarbs}g F: ${g.targetFat}g',
              style: TextStyle(
                fontSize: sizes.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${g.goalType == MacroGoalType.calorieCycling ? 'Calorie Cycling • ' : ''}'
              'Water: ${g.targetWaterIntakeMl ?? 0}ml • ${g.name}',
              style: TextStyle(
                fontSize: sizes.fontSize * 0.9,
                color: Colors.grey[600],
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey,
                size: sizes.buttonIconSize,
              ),
              onPressed: isSkeleton
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmationDialog(
                          title: 'Delete Past Goal',
                          content:
                              'Are you sure you want to delete this past goal?',
                          onConfirm: () {
                            context.read<MacroTrackingCubit>().deleteMacroGoal(
                              g.id,
                            );
                          },
                        ),
                      );
                    },
            ),
          ),
        );
      },
    );
  }
}
