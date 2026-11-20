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
import '../../view_models/exercise_record_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import './empty_exercise_progress_record.dart';
import './exercise_progress_error_card.dart';
import './latest_exercise_progress_record_card.dart';

class LatestExerciseProgressRecord extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final Future<void> Function(int exerciseId) onOpenExerciseRecords;

  const LatestExerciseProgressRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.onOpenExerciseRecords,
  });

  @override
  State<LatestExerciseProgressRecord> createState() =>
      _LatestExerciseProgressRecordState();
}

class _LatestExerciseProgressRecordState
    extends State<LatestExerciseProgressRecord> {
  bool _refetchTriggered = false;
  bool _waitingForPostFrame = false;

  @override
  void initState() {
    super.initState();
    context.read<ExerciseRecordCubit>().getLatestExerciseRecord();
  }

  void _retryLoad() {
    _refetchTriggered = false;
    context.read<ExerciseRecordCubit>().getLatestExerciseRecord();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
      builder: (context, state) {
        final isLoading = state.isLatestLoading;
        final isScoped = state.latestExerciseId != null;
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isScoped) {
          _refetchTriggered = false;
          _waitingForPostFrame = false;
        } else if (!isLoading && isCurrentRoute && !_refetchTriggered) {
          _refetchTriggered = true;
          _waitingForPostFrame = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _waitingForPostFrame = false;
            context.read<ExerciseRecordCubit>().getLatestExerciseRecord();
          });
        }

        final effectiveLoading = isLoading || _waitingForPostFrame;
        final record = effectiveLoading || isScoped
            ? null
            : state.latestExerciseRecord;

        if (!effectiveLoading &&
            state.latestError != null &&
            (isScoped || record == null)) {
          return ExerciseProgressErrorCard(
            theme: widget.theme,
            sizes: widget.sizes,
            message: state.latestError!.description,
            onRetry: _retryLoad,
          );
        }

        if (!effectiveLoading && record == null) {
          return EmptyExerciseProgressRecord(
            sizes: widget.sizes,
            theme: widget.theme,
            isLoading: effectiveLoading,
          );
        }

        return LatestExerciseProgressRecordCard(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: effectiveLoading,
          exerciseRecord: record,
          onOpenExerciseRecords: widget.onOpenExerciseRecords,
        );
      },
    );
  }
}
