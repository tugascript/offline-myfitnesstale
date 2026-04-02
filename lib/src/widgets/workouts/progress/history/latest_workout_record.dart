import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../cubits/states/workout_record_state.dart';
import '../../../../cubits/workout_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_record_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_elevated_button.dart';
import 'workout_record_head.dart';

class LatestWorkoutRecord extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final int workoutId;
  final int workoutVersion;

  const LatestWorkoutRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.workoutId,
    required this.workoutVersion,
  });

  @override
  State<LatestWorkoutRecord> createState() => _LatestWorkoutRecordState();
}

class _LatestWorkoutRecordState extends State<LatestWorkoutRecord> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutRecordCubit>().getLatestWorkoutRecord(
          widget.workoutId,
        );
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
  final int workoutId;
  final int workoutVersion;
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

          context.push(
            '/workouts/$workoutId/history/$workoutVersion/records/${workoutRecord?.id}',
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
  final int workoutId;
  final int workoutVersion;

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
              SizedBox(height: sizes.spacing),
              SizedBox(
                width: double.infinity,
                child: AppElevatedButton(
                  isLoading: isLoading,
                  theme: theme,
                  sizes: sizes,
                  isDense: true,
                  onPressed: () => context.push(
                    '/workouts/$workoutId/active',
                  ),
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
                    '/workouts/$workoutId/history/$workoutVersion/records/create',
                  ),
                  label: 'Create Record',
                  icon: Icons.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
