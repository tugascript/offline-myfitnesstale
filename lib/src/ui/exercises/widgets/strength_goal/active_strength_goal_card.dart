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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../data/repositories/exercises/dtos/strength_goal_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/json_data.dart';
import '../../../../routing/routes.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_outlined_button.dart';
import '../../../core/widgets/layout/delete_icon_button.dart';
import '../../../core/widgets/layout/edit_icon_button.dart';
import '../../../core/widgets/progress_status_badge.dart';
import '../../../home/view_models/profile_cubit.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import '../max_strength_label.dart';
import '../relative_date_label.dart';
import '../records/editors/create_exercise_record_modal.dart';
import 'edit_strength_goal_modal.dart';
import 'empty_active_strength_goal_card.dart';

final _skeletonStrengthGoal = StrengthGoalDto(
  id: 0,
  name: 'Loading Strength Goal...',
  targetReps: 8,
  targetWeight: 100000,
  targetMaxStrength: 126667,
  exerciseId: 0,
  status: ProgressStatus.inProgress,
  startDate: DateTime(2026, 1, 1),
  exercise: const ExerciseDto(
    id: 0,
    name: 'Loading Exercise Name...',
    description: '',
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    createdBy: CreatedBy.system,
  ),
);

class ActiveStrengthGoalCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units? units;

  const ActiveStrengthGoalCard({
    super.key,
    required this.theme,
    required this.sizes,
    this.units,
  });

  String _formatWeight(Units effectiveUnits, int grams) {
    final value = effectiveUnits == Units.imperial
        ? Converters.gramsToLbs(grams)
        : Converters.gramsToKg(grams);
    final suffix = effectiveUnits == Units.imperial ? 'lb' : 'kg';
    return '${Formatters.formatWeight(value)} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUnits =
        units ??
        context.watch<ProfileCubit>().state.system?.units ??
        Units.metric;

    return BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
      builder: (context, state) {
        final goal = state.activeStrengthGoal;
        final isSkeleton = state.isLoading && goal == null;

        if (!state.isLoading && goal == null) {
          return EmptyActiveStrengthGoalCard(
            theme: theme,
            sizes: sizes,
            isLoading: state.isLoading,
          );
        }

        final displayGoal = goal ?? _skeletonStrengthGoal;
        final weightString = _formatWeight(
          effectiveUnits,
          displayGoal.targetWeight,
        );

        return Card(
          margin: EdgeInsets.zero,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizes.padding,
                vertical: sizes.padding * 2,
              ),
              child: Skeletonizer(
                enabled: isSkeleton,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Latest Active Goal',
                            style: TextStyle(
                              fontSize: sizes.titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isSkeleton && goal != null) ...[
                          EditIconButton(
                            sizes: sizes,
                            isLoading: state.isLoading,
                            onEdit: () {
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
                          SizedBox(width: sizes.quarterSpacing),
                          DeleteIconButton(
                            key: const ValueKey(
                              'active-strength-goal-delete-btn',
                            ),
                            sizes: sizes,
                            isLoading: state.isLoading,
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => ConfirmationDialog(
                                  title: 'Delete Strength Goal',
                                  content: 'Are you sure you want to delete this strength goal?',
                                  confirmLabel: 'Delete',
                                  isDestructive: true,
                                  onConfirm: () {
                                    context
                                        .read<ExerciseRecordCubit>()
                                        .deleteStrengthGoal(goal.id);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    if (displayGoal.exercise != null) ...[
                      SizedBox(height: sizes.halfSpacing),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_gymnastics,
                            size: sizes.iconSubtitleFontSize,
                          ),
                          Flexible(
                            child: Text(
                              ' ${displayGoal.exercise!.name}',
                              style: TextStyle(
                                fontSize: sizes.subtitleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (displayGoal.name != null &&
                        displayGoal.name!.trim().isNotEmpty) ...[
                      SizedBox(height: sizes.halfSpacing),
                      Text(
                        displayGoal.name!,
                        style: TextStyle(
                          fontSize: displayGoal.exercise != null
                              ? sizes.fontSize
                              : sizes.subtitleFontSize,
                          fontWeight: displayGoal.exercise != null
                              ? FontWeight.w600
                              : FontWeight.bold,
                        ),
                      ),
                    ],
                    SizedBox(height: sizes.spacing),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: sizes.spacing,
                        runSpacing: sizes.halfSpacing,
                        children: [
                          RelativeDateLabel(
                            units: effectiveUnits,
                            date: displayGoal.startDate,
                            fontSize: sizes.fontSize,
                            prefix: 'Started: ',
                            fontWeight: FontWeight.w600,
                          ),
                          ProgressStatusBadge(
                            status: displayGoal.status,
                            sizes: sizes,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sizes.spacing),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.repeat_one, size: sizes.fontSize * 1.2),
                            Text(
                              ' ${displayGoal.targetReps} ',
                              style: TextStyle(
                                fontSize: sizes.fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(Icons.close, size: sizes.fontSize),
                            Text(
                              ' ',
                              style: TextStyle(fontSize: sizes.fontSize),
                            ),
                            Icon(Icons.scale, size: sizes.fontSize * 1.2),
                            Text(
                              ' $weightString',
                              style: TextStyle(
                                fontSize: sizes.fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        MaxStrengthLabel(
                          units: effectiveUnits,
                          maxStrength: displayGoal.targetMaxStrength,
                          fontSize: sizes.fontSize,
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.spacing),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: AppElevatedButton(
                              key: const ValueKey(
                                'active-strength-goal-records-add-btn',
                              ),
                              isLoading: state.isLoading,
                              sizes: sizes,
                              label: 'Add a Record',
                              icon: Icons.add,
                              isDense: true,
                              onPressed: isSkeleton || goal == null
                                  ? null
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) =>
                                            CreateExerciseRecordModal(
                                              theme: theme,
                                              sizes: sizes,
                                              units: effectiveUnits,
                                              exerciseId:
                                                  displayGoal.exerciseId,
                                            ),
                                      );
                                    },
                              theme: theme,
                            ),
                          ),
                        ),
                        SizedBox(width: sizes.spacing),
                        Expanded(
                          child: AppOutlinedButton(
                            key: const ValueKey(
                              'active-strength-goal-records-btn',
                            ),
                            isLoading: state.isLoading,
                            theme: theme,
                            sizes: sizes,
                            label: 'Records',
                            icon: Icons.history,
                            isDense: true,
                            filled: true,
                            color: theme.colorScheme.secondary,
                            onPressed: isSkeleton || goal == null
                                ? null
                                : () {
                                    context.push(
                                      Routes.exerciseRecords.name.replaceFirst(
                                        ':id',
                                        displayGoal.exerciseId.toString(),
                                      ),
                                    );
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
