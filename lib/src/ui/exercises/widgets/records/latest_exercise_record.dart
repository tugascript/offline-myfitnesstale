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
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import '../progress/exercise_progress_error_card.dart';
import './editors/update_exercise_record_card.dart';
import './empty_exercise_record.dart';
import './latest_exercise_record_card.dart';

class LatestExerciseRecord extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final ExerciseDto exercise;

  const LatestExerciseRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.exercise,
  });

  @override
  State<LatestExerciseRecord> createState() => _LatestExerciseRecordState();
}

class _LatestExerciseRecordState extends State<LatestExerciseRecord> {
  bool _editOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<ExerciseRecordCubit>().getLatestExerciseRecord(
      widget.exercise.id,
    );
  }

  @override
  void didUpdateWidget(covariant LatestExerciseRecord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _editOpen = false;
      context.read<ExerciseRecordCubit>().getLatestExerciseRecord(
        widget.exercise.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
      builder: (context, state) {
        final isLoading = state.isLatestLoading;
        final record =
            state.latestExerciseRecord?.exerciseId == widget.exercise.id
            ? state.latestExerciseRecord
            : null;

        if (!isLoading && state.latestError != null && record == null) {
          return ExerciseProgressErrorCard(
            theme: widget.theme,
            sizes: widget.sizes,
            message: state.latestError!.description,
            onRetry: () {
              context.read<ExerciseRecordCubit>().getLatestExerciseRecord(
                widget.exercise.id,
              );
            },
          );
        }

        if (!isLoading && record == null) {
          return EmptyExerciseRecord(
            sizes: widget.sizes,
            theme: widget.theme,
            exerciseName: widget.exercise.name,
            units: widget.units,
            exerciseId: widget.exercise.id,
          );
        }

        if (_editOpen && record != null) {
          return UpdateExerciseRecordCard(
            theme: widget.theme,
            sizes: widget.sizes,
            units: widget.units,
            isLoading: state.isLoading,
            exercise: widget.exercise,
            record: record,
            onClose: () {
              setState(() {
                _editOpen = false;
              });
            },
          );
        }

        return LatestExerciseRecordCard(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: isLoading,
          isMutating: state.isLoading,
          exercise: widget.exercise,
          exerciseRecord: record,
          onEdit: () {
            setState(() {
              _editOpen = true;
            });
          },
        );
      },
    );
  }
}
