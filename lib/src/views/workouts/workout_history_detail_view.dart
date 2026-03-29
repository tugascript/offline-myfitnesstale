import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/states/workout_record_state.dart';
import '../../cubits/states/workout_state.dart';
import '../../cubits/workout_cubit.dart';
import '../../cubits/workout_record_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/workout_set_record_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workouts/progress/history/detail/workout_record_head_card.dart';
import '../../widgets/workouts/progress/history/detail/workout_record_sets.dart';

class WorkoutHistoryDetailView extends StatefulWidget {
  static const routeName =
      '/workouts/:workoutId/history/:version/:workoutRecordId';

  final int workoutId;
  final int workoutRecordId;
  final int version;

  const WorkoutHistoryDetailView({
    super.key,
    required this.workoutId,
    required this.workoutRecordId,
    required this.version,
  });

  @override
  State<WorkoutHistoryDetailView> createState() =>
      _WorkoutHistoryDetailViewState();
}

class _WorkoutHistoryDetailViewState extends State<WorkoutHistoryDetailView> {
  @override
  void initState() {
    super.initState();

    final workoutCubit = context.read<WorkoutCubit>();
    if (workoutCubit.state.selectedWorkout?.id != widget.workoutId) {
      workoutCubit.getWorkout(widget.workoutId);
    }

    final workoutRecordCubit = context.read<WorkoutRecordCubit>();
    if (workoutRecordCubit.state.selectedWorkoutRecord?.id !=
        widget.workoutRecordId) {
      workoutRecordCubit.getWorkoutRecord(
        widget.workoutRecordId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, workoutState) {
            return ResponsiveScaffold(
              title: workoutState.selectedWorkout?.name ?? 'Workout Details',
              body: BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
                builder: (context, workoutRecordState) {
                  final Map<int, List<WorkoutSetRecordDto>> setRecordsMap =
                      workoutRecordState.selectedWorkoutRecord?.setRecords
                              ?.fold<Map<int, List<WorkoutSetRecordDto>>>(
                            {},
                            (map, s) => map
                              ..update(
                                s.workoutSetId,
                                (value) => value..add(s),
                                ifAbsent: () => [s],
                              ),
                          ) ??
                          {};

                  return Column(
                    children: [
                      WorkoutRecordHeadCard(
                        sizes: sizes,
                        theme: theme,
                        units: profileState.system?.units ?? Units.metric,
                        isLoading: workoutRecordState.isLoading,
                        workoutRecord: workoutRecordState.selectedWorkoutRecord,
                      ),
                      SizedBox(height: sizes.spacing),
                      WorkoutRecordSets(
                        sizes: sizes,
                        theme: theme,
                        units: profileState.system?.units ?? Units.metric,
                        data: [], // TODO: fix me
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
