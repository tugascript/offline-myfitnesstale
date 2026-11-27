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

import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_text_button.dart';
import '../../../../core/widgets/layout/empty_card.dart';
import '../../../view_models/states/workout_record_state.dart';
import '../../../view_models/workout_record_cubit.dart';
import './empty_workout_record.dart';
import './latest_workout_record_card.dart';

class LatestWorkoutRecord extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final int? workoutId;
  final int? workoutVersion;
  final bool? isCardio;

  const LatestWorkoutRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    this.workoutId,
    this.workoutVersion,
    this.isCardio,
  });

  @override
  State<LatestWorkoutRecord> createState() => _LatestWorkoutRecordState();
}

class _LatestWorkoutRecordState extends State<LatestWorkoutRecord> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutRecordCubit>().getLatestWorkoutRecord(
      workoutId: widget.workoutId,
      skipSkipped: true,
    );
  }

  @override
  void didUpdateWidget(covariant LatestWorkoutRecord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workoutId != widget.workoutId) {
      context.read<WorkoutRecordCubit>().getLatestWorkoutRecord(
        workoutId: widget.workoutId,
        skipSkipped: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
      builder: (context, state) {
        final record = state.latestWorkoutRecord;
        final matchingRecord =
            (widget.workoutId != null && record?.workoutId != widget.workoutId)
            ? null
            : record;

        if (!state.isLoadingLatest && state.latestError != null) {
          return EmptyCard(
            sizes: widget.sizes,
            emoji: '⚠️',
            emptyText: 'Could not load latest workout record',
            actions: [
              AppTextButton(
                key: const ValueKey('latest-workout-record-retry'),
                isLoading: false,
                sizes: widget.sizes,
                isDense: true,
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: () {
                  context.read<WorkoutRecordCubit>().getLatestWorkoutRecord(
                    workoutId: widget.workoutId,
                    skipSkipped: true,
                  );
                },
              ),
            ],
          );
        }

        if (!state.isLoadingLatest && matchingRecord == null) {
          return EmptyWorkoutRecord(
            sizes: widget.sizes,
            isLoading: false,
            workoutId: widget.workoutId,
            workoutVersion: widget.workoutVersion,
          );
        }

        return LatestWorkoutRecordCard(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: state.isLoadingLatest,
          workoutId: widget.workoutId,
          workoutVersion: widget.workoutVersion,
          isCardio: widget.isCardio,
          workoutRecord: matchingRecord,
        );
      },
    );
  }
}
