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
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/exercises/dtos/strength_goal_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../routing/routes.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/layout/app_icon_button.dart';
import '../../../core/widgets/layout/delete_icon_button.dart';
import '../../../core/widgets/layout/edit_icon_button.dart';
import '../../../core/widgets/layout/list_card.dart';
import '../../../core/widgets/progress_status_badge.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../exercise_record_reps.dart';
import '../max_strength_label.dart';
import '../records/editors/create_exercise_record_modal.dart';
import '../relative_date_label.dart';
import 'edit_strength_goal_modal.dart';

class StrengthGoalHistoryCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final StrengthGoalDto goal;
  final bool isSkeleton;

  const StrengthGoalHistoryCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.goal,
    this.isSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasExercise = goal.exercise != null;
    final hasName = goal.name != null && goal.name!.trim().isNotEmpty;
    final displayDate = goal.completedAt ?? goal.startDate;

    return ListCard(
      key: isSkeleton ? null : ValueKey('strength-goal-history-${goal.id}'),
      margin: sizes.margins / 2,
      padding: sizes.padding,
      children: [
        if (hasExercise || hasName) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasExercise
                          ? Icons.sports_gymnastics
                          : Icons.emoji_events_outlined,
                      size: hasExercise
                          ? sizes.subtitleFontSize * 1.2
                          : sizes.iconSubtitleFontSize,
                    ),
                    Flexible(
                      child: Text(
                        hasExercise
                            ? ' ${goal.exercise!.name}'
                            : ' ${goal.name!}',
                        style: TextStyle(
                          fontSize: sizes.subtitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sizes.halfSpacing),
              ProgressStatusBadge(status: goal.status, sizes: sizes),
            ],
          ),
          if (hasExercise && hasName) ...[
            SizedBox(height: sizes.halfSpacing),
            Text(
              goal.name!,
              style: TextStyle(
                fontSize: sizes.fontSize,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: sizes.spacing),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RelativeDateLabel(
                    units: units,
                    date: displayDate,
                    fontSize: sizes.fontSize,
                  ),
                  if (!hasExercise && !hasName) ...[
                    SizedBox(width: sizes.halfSpacing),
                    ProgressStatusBadge(status: goal.status, sizes: sizes),
                  ],
                ],
              ),
            ),
            ExerciseRecordReps(
              units: units,
              fontSize: sizes.fontSize,
              reps: goal.targetReps,
              weight: goal.targetWeight,
            ),
            MaxStrengthLabel(
              units: units,
              maxStrength: goal.targetMaxStrength,
              fontSize: sizes.fontSize,
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppIconButton(
              key: isSkeleton
                  ? null
                  : ValueKey('strength-goal-history-add-record-${goal.id}'),
              sizes: sizes,
              small: true,
              isLoading: isSkeleton,
              color: theme.colorScheme.primary,
              icon: Icons.add,
              tooltip: 'Add a Record',
              onPressed: isSkeleton
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (ctx) => CreateExerciseRecordModal(
                          theme: theme,
                          sizes: sizes,
                          units: units,
                          exerciseId: goal.exerciseId,
                        ),
                      );
                    },
            ),
            AppIconButton(
              key: isSkeleton
                  ? null
                  : ValueKey('strength-goal-history-records-${goal.id}'),
              sizes: sizes,
              small: true,
              isLoading: isSkeleton,
              color: theme.colorScheme.secondary,
              icon: Icons.history,
              tooltip: 'Records',
              onPressed: isSkeleton
                  ? null
                  : () {
                      context.push(
                        Routes.exerciseRecords.name.replaceFirst(
                          ':id',
                          goal.exerciseId.toString(),
                        ),
                      );
                    },
            ),
            EditIconButton(
              key: isSkeleton
                  ? null
                  : ValueKey('strength-goal-history-edit-${goal.id}'),
              sizes: sizes,
              small: true,
              isLoading: isSkeleton,
              onEdit: () {
                if (isSkeleton) return;
                showDialog(
                  context: context,
                  builder: (ctx) => EditStrengthGoalModal(
                    theme: theme,
                    sizes: sizes,
                    existingGoal: goal,
                  ),
                );
              },
            ),
            DeleteIconButton(
              key: isSkeleton
                  ? null
                  : ValueKey('strength-goal-history-delete-${goal.id}'),
              sizes: sizes,
              small: true,
              isLoading: isSkeleton,
              onDelete: () {
                if (isSkeleton) return;
                showDialog(
                  context: context,
                  builder: (ctx) => ConfirmationDialog(
                    title: 'Delete Past Goal',
                    content: 'Are you sure you want to delete this historical goal record?',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                    onConfirm: () {
                      context.read<ExerciseRecordCubit>().deleteStrengthGoal(
                        goal.id,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
