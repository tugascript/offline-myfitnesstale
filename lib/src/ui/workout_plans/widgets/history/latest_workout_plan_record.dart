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
import '../../../core/widgets/layout/app_text_button.dart';
import '../../../core/widgets/layout/empty_card.dart';
import '../../view_models/states/workout_plan_record_state.dart';
import '../../view_models/workout_plan_record_cubit.dart';
import './empty_workout_plan_record.dart';
import './latest_workout_plan_record_card.dart';

class LatestWorkoutPlanRecord extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final int? workoutPlanId;
  final int? workoutPlanVersion;

  const LatestWorkoutPlanRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    this.workoutPlanId,
    this.workoutPlanVersion,
  });

  @override
  State<LatestWorkoutPlanRecord> createState() =>
      _LatestWorkoutPlanRecordState();
}

class _LatestWorkoutPlanRecordState extends State<LatestWorkoutPlanRecord> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutPlanRecordCubit>().getLatestWorkoutPlanRecord(
      widget.workoutPlanId,
    );
  }

  @override
  void didUpdateWidget(covariant LatestWorkoutPlanRecord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workoutPlanId != widget.workoutPlanId) {
      context.read<WorkoutPlanRecordCubit>().getLatestWorkoutPlanRecord(
        widget.workoutPlanId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
      builder: (context, state) {
        final record = state.latestWorkoutPlanRecord;
        final matchingRecord =
            (widget.workoutPlanId != null &&
                record?.workoutPlanId != widget.workoutPlanId)
            ? null
            : record;

        if (!state.isLoadingLatest && state.latestError != null) {
          return EmptyCard(
            sizes: widget.sizes,
            emoji: '⚠️',
            emptyText: 'Could not load latest workout plan record',
            actions: [
              AppTextButton(
                key: const ValueKey('latest-workout-plan-record-retry'),
                isLoading: false,
                sizes: widget.sizes,
                isDense: true,
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: () {
                  context
                      .read<WorkoutPlanRecordCubit>()
                      .getLatestWorkoutPlanRecord(widget.workoutPlanId);
                },
              ),
            ],
          );
        }

        if (!state.isLoadingLatest && matchingRecord == null) {
          return EmptyWorkoutPlanRecord(
            sizes: widget.sizes,
            isLoading: false,
            workoutPlanId: widget.workoutPlanId,
          );
        }

        return LatestWorkoutPlanRecordCard(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: state.isLoadingLatest,
          workoutPlanId: widget.workoutPlanId,
          workoutPlanVersion: widget.workoutPlanVersion,
          workoutPlanRecord: matchingRecord,
        );
      },
    );
  }
}
