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
import '../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/layout/delete_icon_button.dart';
import '../../../core/widgets/layout/edit_icon_button.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../max_strength_label.dart';
import '../relative_date_label.dart';
import '../exercise_record_reps.dart';

class LatestExerciseRecordCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final ExerciseDto exercise;
  final ExerciseRecordDto? exerciseRecord;
  final VoidCallback onEdit;

  const LatestExerciseRecordCard({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.exercise,
    required this.exerciseRecord,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
            enabled: isLoading || exerciseRecord == null,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Latest Record",
                        style: TextStyle(
                          fontSize: sizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EditIconButton(
                          key: const ValueKey('latest-exercise-record-edit'),
                          sizes: sizes,
                          isLoading: isLoading,
                          onEdit: onEdit,
                        ),
                        SizedBox(width: sizes.quarterSpacing),
                        DeleteIconButton(
                          key: const ValueKey('latest-exercise-record-delete'),
                          sizes: sizes,
                          isLoading: isLoading,
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => ConfirmationDialog(
                                title: 'Delete Exercise Record',
                                content: 'Are you sure you want to delete this exercise record? This action cannot be undone.',
                                confirmLabel: 'DELETE',
                                isDestructive: true,
                                onConfirm: () async {
                                  if (exerciseRecord != null) {
                                    await context
                                        .read<ExerciseRecordCubit>()
                                        .deleteExerciseRecord(
                                          exerciseRecord!.id,
                                        );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: ExerciseRecordReps(
                            units: units,
                            fontSize: sizes.subtitleFontSize,
                            reps: exerciseRecord?.reps ?? 0,
                            weight: exerciseRecord?.weight ?? 0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.spacing),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RelativeDateLabel(
                            units: units,
                            date: exerciseRecord?.recordDate ?? DateTime.now(),
                            fontSize: sizes.subtitleFontSize,
                          ),
                          SizedBox(width: sizes.spacing),
                          MaxStrengthLabel(
                            units: units,
                            maxStrength: exerciseRecord?.maxStrength ?? 0,
                            fontSize: sizes.subtitleFontSize,
                          ),
                        ],
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
  }
}
