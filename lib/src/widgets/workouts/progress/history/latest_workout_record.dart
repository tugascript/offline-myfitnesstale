import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../cubits/states/workout_record_state.dart';
import '../../../../cubits/workout_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_record_dto.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/formatters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/muscles_wrap.dart';
import '../../../common/total_numeric_string.dart';
import '../../../layout/app_elevated_button.dart';

class LatestWorkoutRecord extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final int workoutId;

  const LatestWorkoutRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.workoutId,
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
          );
        }

        return _LatestWorkoutRecord(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: state.isLoading,
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
  final WorkoutRecordDto? workoutRecord;

  const _LatestWorkoutRecord({
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.workoutRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.padding,
            vertical: sizes.padding * 2,
          ),
          child: Skeletonizer(
            enabled: isLoading || workoutRecord == null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: sizes.fontSize * 1.2,
                          ),
                          Text(
                            " ${Formatters.formatDate(
                              units,
                              workoutRecord?.startedAt ?? DateTime.now(),
                            )}",
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (workoutRecord?.completedAt != null)
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: sizes.fontSize * 1.2,
                            ),
                            Text(
                              " ${Formatters.formatDate(
                                units,
                                workoutRecord!.completedAt!,
                              )}",
                              style: TextStyle(
                                fontSize: sizes.fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TotalNumericString(
                        leading: Icon(Icons.scale, size: sizes.fontSize * 1.2),
                        name: 'Volume',
                        total: units == Units.metric
                            ? Converters.gramsToKg(
                                workoutRecord?.totalVolume ?? 0,
                              ).round()
                            : Converters.gramsToLbs(
                                workoutRecord?.totalVolume ?? 0,
                              ).round(),
                        fontSize: sizes.fontSize,
                      ),
                    ),
                    Expanded(
                      child: TotalNumericString(
                        leading: Icon(Icons.timer, size: sizes.fontSize * 1.2),
                        name: 'Rest',
                        total: workoutRecord?.totalRestSecs ?? 0,
                        fontSize: sizes.fontSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TotalNumericString(
                        leading: Icon(Icons.repeat, size: sizes.fontSize * 1.2),
                        name: 'Sets',
                        total: workoutRecord?.totalSets ?? 0,
                        fontSize: sizes.fontSize,
                      ),
                    ),
                    Expanded(
                      child: TotalNumericString(
                        leading:
                            Icon(Icons.repeat_one, size: sizes.fontSize * 1.2),
                        name: 'Reps',
                        total: workoutRecord?.totalReps ?? 0,
                        fontSize: sizes.fontSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MusclesWrap(
                        leading: Text(
                          '💪',
                          style:
                              TextStyle(fontSize: sizes.subtitleFontSize * 1.2),
                        ),
                        title: 'Primary Muscles',
                        sizes: sizes,
                        muscles: workoutRecord?.muscles.primary ?? {},
                        theme: theme,
                      ),
                    ),
                    if (workoutRecord?.muscles.secondary.isNotEmpty ?? false)
                      Expanded(
                        child: MusclesWrap(
                          leading: Text(
                            '🥈',
                            style: TextStyle(
                              fontSize: sizes.subtitleFontSize * 1.2,
                            ),
                          ),
                          title: 'Secondary Muscles',
                          sizes: sizes,
                          muscles: workoutRecord!.muscles.secondary,
                          theme: theme,
                        ),
                      ),
                  ],
                )
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

  const _EmptyWorkoutRecord({
    required this.sizes,
    required this.theme,
    required this.isLoading,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    '/workouts/$workoutId/history/create',
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
