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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/repositories/exercises/inputs/exercise_record_input.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_modal.dart';
import '../../../view_models/exercise_record_cubit.dart';
import '../../../view_models/states/exercise_record_state.dart';
import './exercise_record_form.dart';

class CreateExerciseRecordModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final int exerciseId;

  const CreateExerciseRecordModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
        builder: (context, state) {
          return ExerciseRecordForm(
            theme: theme,
            sizes: sizes,
            units: units,
            exerciseId: exerciseId,
            isLoading: state.isLoading,
            submitLabel: "CREATE EXERCISE RECORD",
            initialDate: DateTime.now(),
            initialWeight: 0,
            initialReps: 1,
            onSubmit:
                ({
                  required int exerciseId,
                  required int weight,
                  required int reps,
                  required DateTime date,
                }) async {
                  await context
                      .read<ExerciseRecordCubit>()
                      .createExerciseRecord(
                        ExerciseRecordInput(
                          exerciseId: exerciseId,
                          weight: weight,
                          reps: reps,
                          recordDate: date,
                        ),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
          );
        },
      ),
    );
  }
}
