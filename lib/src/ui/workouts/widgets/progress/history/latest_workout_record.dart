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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/repositories/workouts/dtos/workout_record_dto.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_elevated_button.dart';
import '../../../view_models/states/workout_record_state.dart';
import '../../../view_models/workout_record_cubit.dart';
import './workout_record_head.dart';

class LatestWorkoutRecord extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final int? workoutId;
  final int? workoutVersion;

  const LatestWorkoutRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    this.workoutId,
    this.workoutVersion,
  });

  @override
  State<LatestWorkoutRecord> createState() => _LatestWorkoutRecordState();
}

class _LatestWorkoutRecordState extends State<LatestWorkoutRecord> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutRecordCubit>().getLatestWorkoutRecord(widget.workoutId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
      builder: (context, state) {
        if (!state.isLoading && state.latestWorkoutRecord == null) {
          return _EmptyWorkoutRecord(
            sizes: widget.sizes,
            theme: widget.theme,
            isLoading: state.isLoading,
            workoutId: widget.workoutId,
            workoutVersion: widget.workoutVersion,
          );
        }

        return _LatestWorkoutRecord(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: state.isLoading,
          workoutId: widget.workoutId,
          workoutVersion: widget.workoutVersion,
          workoutRecord: state.latestWorkoutRecord,
        );
      },
    );
  }
}

class _LatestWorkoutRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final int? workoutId;
  final int? workoutVersion;
  final WorkoutRecordDto? workoutRecord;

  const _LatestWorkoutRecord({
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.workoutId,
    required this.workoutVersion,
    required this.workoutRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          if (workoutRecord == null) {
            return;
          }

          final targetWorkoutId = workoutId ?? workoutRecord!.workoutId;
          context.push(
            '/workouts/$targetWorkoutId/history/${workoutRecord!.version}/records/${workoutRecord?.id}',
          );
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
                WorkoutRecordHead(
                  sizes: sizes,
                  theme: theme,
                  units: units,
                  isLoading: isLoading,
                  workoutRecord: workoutRecord,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyWorkoutRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isLoading;
  final int? workoutId;
  final int? workoutVersion;

  const _EmptyWorkoutRecord({
    required this.sizes,
    required this.theme,
    required this.isLoading,
    required this.workoutId,
    required this.workoutVersion,
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
                "🏋️",
                style: TextStyle(
                  fontSize: sizes.titleFontSize * 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: sizes.spacing),
              Text(
                "No workout records",
                style: TextStyle(
                  fontSize: sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (workoutId != null) ...[
                SizedBox(height: sizes.spacing),
                SizedBox(
                  width: double.infinity,
                  child: AppElevatedButton(
                    isLoading: isLoading,
                    theme: theme,
                    sizes: sizes,
                    isDense: true,
                    onPressed: () =>
                        context.push('/workouts/$workoutId/active'),
                    label: 'Start Workout',
                    icon: Icons.play_arrow,
                  ),
                ),
                SizedBox(height: sizes.spacing / 2),
                SizedBox(
                  width: double.infinity,
                  child: AppElevatedButton(
                    isLoading: isLoading,
                    theme: theme,
                    sizes: sizes,
                    isDense: true,
                    isSecondary: true,
                    onPressed: () => context.push(
                      '/workouts/$workoutId/history/${workoutVersion ?? 1}/records/create',
                    ),
                    label: 'Create Record',
                    icon: Icons.add,
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
                    onPressed: () => context.push('/workouts'),
                    label: 'Browse Workouts',
                    icon: Icons.fitness_center,
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
