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
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../view_models/states/workout_plan_record_state.dart';
import '../../view_models/workout_plan_record_cubit.dart';
import './workout_plan_record_head.dart';

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
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
      builder: (context, state) {
        if (!state.isLoading && state.latestWorkoutPlanRecord == null) {
          return _EmptyWorkoutPlanRecord(
            sizes: widget.sizes,
            theme: widget.theme,
            isLoading: state.isLoading,
            workoutPlanId: widget.workoutPlanId,
            workoutPlanVersion: widget.workoutPlanVersion,
          );
        }

        return _LatestWorkoutPlanRecord(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: state.isLoading,
          workoutPlanId: widget.workoutPlanId,
          workoutPlanVersion: widget.workoutPlanVersion,
          workoutPlanRecord: state.latestWorkoutPlanRecord,
        );
      },
    );
  }
}

class _LatestWorkoutPlanRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final int? workoutPlanId;
  final int? workoutPlanVersion;
  final WorkoutPlanRecordDto? workoutPlanRecord;

  const _LatestWorkoutPlanRecord({
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.workoutPlanId,
    required this.workoutPlanVersion,
    required this.workoutPlanRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          if (workoutPlanRecord == null) {
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
                    Text(
                      "Latest Record",
                      style: TextStyle(
                        fontSize: sizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: sizes.titleFontSize,
                      color: Colors.grey,
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

class _EmptyWorkoutPlanRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isLoading;
  final int? workoutPlanId;
  final int? workoutPlanVersion;

  const _EmptyWorkoutPlanRecord({
    required this.sizes,
    required this.theme,
    required this.isLoading,
    required this.workoutPlanId,
    required this.workoutPlanVersion,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "📋",
                style: TextStyle(
                  fontSize: sizes.titleFontSize * 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: sizes.spacing),
              Text(
                "No workout plan records",
                style: TextStyle(
                  fontSize: sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (workoutPlanId != null) ...[
                SizedBox(height: sizes.spacing),
                SizedBox(
                  width: double.infinity,
                  child: AppElevatedButton(
                    isLoading: isLoading,
                    theme: theme,
                    sizes: sizes,
                    isDense: true,
                    onPressed: () =>
                        context.push('/workout-plans/$workoutPlanId/active'),
                    label: 'Start Plan',
                    icon: Icons.play_arrow,
                  ),
                ),
              ] else ...[
                SizedBox(height: sizes.spacing),
                SizedBox(
                  width: double.infinity,
                  child: AppElevatedButton(
                    isLoading: isLoading,
                    theme: theme,
                    sizes: sizes,
                    isDense: true,
                    onPressed: () => context.push('/workout-plans'),
                    label: 'Browse Plans',
                    icon: Icons.view_list,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
