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

import '../../../../data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/layout/delete_icon_button.dart';
import '../../view_models/workout_plan_record_cubit.dart';
import './workout_plan_record_head.dart';

class LatestWorkoutPlanRecordCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final bool isMutating;
  final int? workoutPlanId;
  final int? workoutPlanVersion;
  final WorkoutPlanRecordDto? workoutPlanRecord;

  const LatestWorkoutPlanRecordCard({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    this.isMutating = false,
    required this.workoutPlanId,
    required this.workoutPlanVersion,
    required this.workoutPlanRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: isLoading || workoutPlanRecord == null
            ? null
            : () {
                if (workoutPlanId != null &&
                    workoutPlanRecord!.workoutPlanId != workoutPlanId) {
                  return;
                }

                final targetPlanId =
                    workoutPlanId ?? workoutPlanRecord!.workoutPlanId;
                if (workoutPlanRecord!.status == ProgressStatus.inProgress) {
                  context.push('/workout-plans/$targetPlanId/active');
                } else {
                  context.push('/workout-plans/$targetPlanId');
                }
              },
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.padding,
              vertical: sizes.padding * 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        "Latest Record",
                        style: TextStyle(
                          fontSize: sizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isLoading && workoutPlanRecord != null) ...[
                          DeleteIconButton(
                            key: const ValueKey(
                              'latest-workout-plan-record-delete',
                            ),
                            sizes: sizes,
                            isLoading: isLoading || isMutating,
                            onDelete: () {
                              final cubit = context
                                  .read<WorkoutPlanRecordCubit>();
                              final recordId = workoutPlanRecord!.id;
                              showDialog(
                                context: context,
                                builder: (_) => ConfirmationDialog(
                                  title: 'Delete Workout Plan Record',
                                  content: 'Are you sure you want to delete this workout plan record? This action cannot be undone.',
                                  confirmLabel: 'Delete',
                                  isDestructive: true,
                                  onConfirm: () {
                                    cubit.deleteWorkoutPlanRecord(recordId);
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(width: sizes.quarterSpacing),
                        ],
                        Icon(
                          Icons.arrow_forward_ios,
                          size: sizes.titleFontSize,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                WorkoutPlanRecordHead(
                  sizes: sizes,
                  theme: theme,
                  units: units,
                  isLoading: isLoading,
                  workoutPlanRecord: workoutPlanRecord,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
