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
import './editors/edit_exercise_record_modal.dart';
import '../exercise_record_reps.dart';

class ExerciseRecordCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final ExerciseDto exercise;
  final ExerciseRecordDto record;

  const ExerciseRecordCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.exercise,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(vertical: sizes.margins / 2),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                ExerciseRecordReps(
                  units: units,
                  fontSize: sizes.fontSize,
                  reps: record.reps,
                  weight: record.weight,
                ),
                MaxStrengthLabel(
                  units: units,
                  maxStrength: record.maxStrength,
                  fontSize: sizes.subtitleFontSize,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                RelativeDateLabel(
                  units: units,
                  date: record.recordDate,
                  fontSize: sizes.fontSize,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EditIconButton(
                      sizes: sizes,
                      small: true,
                      isLoading: false,
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (context) => EditExerciseRecordModal(
                            theme: theme,
                            sizes: sizes,
                            isLoading: false,
                            exercise: exercise,
                            units: units,
                            record: record,
                          ),
                        );
                      },
                    ),
                    DeleteIconButton(
                      sizes: sizes,
                      small: true,
                      isLoading: false,
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                            title: "Delete Exercise Record",
                            content: "Are you sure you want to delete this exercise record?",
                            confirmLabel: "Delete",
                            isDestructive: true,
                            onConfirm: () async {
                              await context
                                  .read<ExerciseRecordCubit>()
                                  .deleteExerciseRecord(record.id);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
